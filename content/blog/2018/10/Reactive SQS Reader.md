+++
title = "How to Write and Test a Reactive Reader for AWS SQS Using akka, alpakka and Localstack"
draft = false
date = "2018-10-07T18:00:00+01:00"
keywords = [ "Programming", "Scala", "akka", "alpakka", "localstack", "reactive programming", "aws", "simple queue service", "message queue" ]
tags = [ "Scala", "Programming", "AWS" ]
slug = "reactive_sqs_reader"
toc = true

[params]
  author = "Jannik Arndt"
+++

This example show how to write a reactive reader for the AWS _Simple Queue Service_, using Scala and alpakka (respective akka streams).

<!--more-->

## SQS Basics

SQS is a AWS-managed message queue service. It can contain several queues. If a message is read from the queue, it is internally set to _invisible_ for [30 seconds](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html#configuring-visibility-timeout). If you don't delete it after these 30 seconds, it becomes visible again. This is great for resilient, distributed microservices: If one instance of a service dies in the middle of handling a message, the message will re-appear and be handled by another instance. It is important though that you do the deletion step _last_.

## This Project

You can find the complete source code on <https://github.com/JannikArndt/reactive-sqs>.

## Imports / build.sbt

Let's start with adding dependencies to our `build.sbt`:

```scala
name := "reactive-sqs"

scalaVersion := "2.12.7"

version := "1.0"

libraryDependencies ++= Seq(
  // https://mvnrepository.com/artifact/com.lightbend.akka/akka-stream-alpakka-sqs
  "com.lightbend.akka" %% "akka-stream-alpakka-sqs" % "0.20",

  // https://mvnrepository.com/artifact/com.typesafe.scala-logging/scala-logging
  "com.typesafe.scala-logging" %% "scala-logging" % "3.9.0",
  "org.slf4j" % "slf4j-simple" % "1.7.25",
  
  // https://mvnrepository.com/artifact/com.typesafe.akka/akka-testkit
  "com.typesafe.akka" %% "akka-testkit" % "2.5.16" % Test,
  // https://mvnrepository.com/artifact/org.scalatest/scalatest
  "org.scalatest" %% "scalatest" % "3.0.5" % Test,
  // https://mvnrepository.com/artifact/org.mockito/mockito-core
  "org.mockito" % "mockito-core" % "2.23.0"
)
```

Since the `com.amazonaws.aws-java-sdk-sqs`-library is included in `akka-stream-alpakka-sqs`, we only need that one. I'm also using `scala-logging`, and for tests the `akka-testkit`, `scalatest` and `mockito`.

## SqsService.scala

Next we'll write the `SqsService.scala`. Its job is to create a flow and handle the messages. As parameters I want to give it the `queueUrl`, a function to handle messages and the maximum amount of messages that are handled in parallel:

```scala
object SqsService {

  case class MyMessage(content: String)

  def create(queueUrl: String, maxMessagesInFlight: Int)
            (messageHandler: MyMessage => Unit) = ???
}
```

I can call this function from my `Main.scala`:

```scala
SqsService.create("http://localhost:4576/queue/myqueue", 20) { message =>
      println(s"Doing logic with ${message.content}")
    }
```

Since `alpakka` is running on `akka streams`, I will also have to provide an `ActorSystem()`.
The return value of my `create` function is dictated by `akka streams`: a tuple of a `KillSwitch` and a `Future[Done]`. These enable me to stop the stream and wait for its completion. So the complete `Main` is

```scala
import akka.Done
import akka.actor.ActorSystem
import akka.stream._

import scala.concurrent.duration._
import scala.concurrent.{Await, Future}
import scala.io.StdIn
import scala.language.postfixOps

object Main extends App {

  implicit val system = ActorSystem()

  val (killSwitch, completion): (KillSwitch, Future[Done]) =
    SqsService.create("http://localhost:4576/queue/myqueue", 20) { message =>
      println(s"Doing logic with ${message.content}")
    }

  println(s"Running service. Press enter to stop.")
  StdIn.readLine()

  killSwitch.shutdown()
  Await.ready(completion, 10 seconds)
  SqsService.stop()
  system.terminate()
}
```

## Creating an `SqsClient`

The first thing our `SqsService` needs to do is create an `AmazonSQSAsyncClient`. The _last_ thing it needs to do is to shut it down — otherwise it won't let you exit the program:

```scala
object SqsService extends StrictLogging {

  case class MyMessage(content: String)

  implicit private val sqsClient: AmazonSQSAsync =
    AmazonSQSAsyncClientBuilder
      .standard()
      .withRegion("eu-central-1")
      .build()

  def stop(): Unit = sqsClient.shutdown()

  def create(queueUrl: String, maxMessagesInFlight: Int)
            (messageHandler: MyMessage => Unit) = ???
}
```

## Creating the Flow

Next, we'll implement the `create` function to create a `Flow`. The basic stream is build by this:

```scala
source
  .via(flow)
  .toMat(sink)(Keep.both)
  .run()
```

As `source` we'll use

```scala
SqsSource(queueUrl).viaMat(KillSwitches.single)(Keep.right)
```

This combines a `SqsSource` that emits `sqs.model.Message`s with a `KillSwitch` and makes sure the `KillSwitch` is returned. The return type is `Source[Message, UniqueKillSwitch]`.

As sink we use `SqsAckSink(queueUrl, SqsAckSinkSettings(maxMessagesInFlight))`. It needs to receive the `queueUrl` because that's where it sends the `delete`-commands to delete/acknowledge the currently invisible message.

The `Flow` is created in two steps: Step one creates a flow from a function and defines attributes:

```scala
val flow = Flow
  .fromFunction(handleMessage(messageHandler))
  .withAttributes(ActorAttributes.supervisionStrategy(Supervision.resumingDecider))
```

The `supervisionStrategy` decides what happens if an exception is thrown inside the flow. The standard strategy is to complete the stream with failure, i.e. one bad message will crash the entire program. The `resumingDecider` simply ignores elements that result in exceptions. This means you need to implement error handling inside the `messageHandler`.

The function itself reads the `body` from the message and hands it to the `messageHandler` we defined in the `Main`. It then returns a tuple of the original message and a delete-action. This is the input needed by the `SqsAckSink`:

```scala
private def handleMessage(messageHandler: MyMessage => Unit) = { message: Message =>
    messageHandler(MyMessage(message.getBody))
    (message, MessageAction.Delete)
  }
```

Now there's only one thing left: The `run()` part, where the stream is _materialized_, needs an `ActorMaterializer`:

```scala
implicit val mat: ActorMaterializer = ActorMaterializer()
```

The complete code is

```scala
object SqsService extends StrictLogging {

  case class MyMessage(content: String)

  implicit private val sqsClient: AmazonSQSAsync =
    AmazonSQSAsyncClientBuilder
      .standard()
      .withRegion("eu-central-1")
      .build()

  def stop(): Unit = sqsClient.shutdown()

  def create(queueUrl: String, maxMessagesInFlight: Int)
            (messageHandler: MyMessage => Unit)
            (implicit system: ActorSystem): (KillSwitch, Future[Done]) = {

    implicit val mat: ActorMaterializer = ActorMaterializer()

    val source = SqsSource(queueUrl).viaMat(KillSwitches.single)(Keep.right)
    val sink = SqsAckSink(queueUrl, SqsAckSinkSettings(maxMessagesInFlight))
    val flow = Flow
      .fromFunction(handleMessage(messageHandler))
      .withAttributes(ActorAttributes.supervisionStrategy(Supervision.resumingDecider))

    source
      .via(flow)
      .toMat(sink)(Keep.both)
      .run()
  }

  private def handleMessage(messageHandler: MyMessage => Unit) = { message: Message =>
    messageHandler(MyMessage(message.getBody))
    (message, MessageAction.Delete)
  }
}
```

## Bonus Functions

The `AmazonSqsClient` has one big caveat: it _does not fail_ if the queue you're subscribing to doesn't exist. That's why I wrote two extra functions:

```scala
import scala.collection.JavaConverters._

def findAvailableQueues(queueNamePrefix: String): Seq[String] =
    sqsClient.listQueues(queueNamePrefix).getQueueUrls.asScala.toVector
```

This is just a Scala-wrapper around the library function. The second function calls a library function that _does_ fail if the queue doesn't exist:

```scala
def assertQueueExists(queueUrl: String): Unit =
  try {
    sqsClient.getQueueAttributes(queueUrl, Seq("All").asJava)
    logger.info(s"Queue at $queueUrl found.")
  } catch {
    case queueDoesNotExistException: QueueDoesNotExistException =>
      logger.error(s"The queue with url $queueUrl does not exist.")
      throw queueDoesNotExistException
  }
```

The advantage of `assertQueueExists` over checking if the url is contained in the list of all available queues is, that you don't need the permission to list all queues.

## Testing

Testing our `SqsService` has three challenges: It is using an AWS service, it is running asynchronously and message queues have a live of their own.

### Mocking AWS SQS

Luckily, others have had the need to test AWS services as well, and created [Localstack](https://github.com/localstack/localstack). It provides a Docker image that runs these services locally:

```shell
$ docker run -d --env SERVICES="sqs" --env TMPDIR="/tmp" \
    --name "localstack" \
    --publish 4576:4576 \
    --rm localstack/localstack
```

You list the services you want to use in the `SERVICES` variable and expose their respective port (`--publish`). The container is started in [_detached_ mode](https://docs.docker.com/engine/reference/run/#detached--d) (`-d`) and [cleans up](https://docs.docker.com/engine/reference/run/#clean-up---rm) after it is removed or the daemon exits (`--rm`).

If you want to access the Localstack-version of a service via the _aws_ cli, you can use the `--endpoint-url`:

```shell
$ aws --endpoint-url=http://localhost:4576 sqs send-message\
    --queue-url "http://localhost:4576/queue/myqueue"\
    --message-body "Hallo"
```

### Mocking the Function

Our test will basically be “is this function called if a message arrives in SQS?”. For this we need

* the Localstack-version of SQS running
* a seperate SQSClient
* a queue dedicated for this test
* a way to test if a function gets called
* a way to wait for the round trip (test => Sqs => tested code => test)

We use the AWS client library thats included in `alpakka` to create a client in our test class:

```scala
val awsSqsClient: AmazonSQSAsync = AmazonSQSAsyncClientBuilder
  .standard()
  .withEndpointConfiguration(new EndpointConfiguration("http://localhost:4576", "eu-central-1"))
  .build()
```

Note that the endpoint connects to the Localstack-version running in docker.

Next, we'll create a queue:

```scala
val queueUrl: String = awsSqsClient.createQueue("integrationtest").getQueueUrl
```

Since we're running on akka, with it's own `ExecutionContext`, and the `SqsClient` has it's own `ExecutionContext` as well, we should terminate both when the tests are done:

```scala
override def afterAll(): Unit = {
  awsSqsClient.shutdown()
  shutdown(system)
  super.afterAll()
}
```

We'll use _Mockito_ to verify that the function we'll give to our `SqsService` is actually called. Mockito needs a `class` to create a mock, so:

```scala
class TestClass {
  def testFunction(message: MyMessage): Unit = Unit
}

val mock: TestClass = mock[TestClass]
```

Since we're mocking the `testFunction`, we don't need to implement it.

It is good practice to put any values that appear in the test _input_ as well as the _output_ into a variable, so you can easily spot the expectation:

```scala
val messageBody = "Example Body"
```

Now we're ready to write the test!

```scala
"SqsService" should "receive a message" in {

  // Arrange
  SqsService.create(queueUrl, maxMessagesInFlight = 20)(mock.testFunction)
  
  // Act: Send message to SQS (synchronous)
  awsSqsClient.sendMessage(queueUrl, messageBody)
  
  // Assert
  verify(mock, Mockito.timeout(1000)).testFunction(MyMessage(messageBody))
}
```

The `Mockito.timeout(1000)` will [wait a second for the result](https://static.javadoc.io/org.mockito/mockito-core/2.2.9/org/mockito/verification/VerificationWithTimeout.html). Make sure to use `timeout` instead of `after`, because with `timeout` the test succeeds directly when the function is called, while after waits the full second.

### Dealing with Message Queues

Now the tests will _mostly_ work. However, since it depends on an outside component, namely the SQS, it _will_ fail, from time to time.

```markdown
[info] MainSpec:
[info] SqsService
[info] - should receive a message *** FAILED ***
[info]   org.mockito.exceptions.verification.WantedButNotInvoked: Wanted but not invoked:
[info] testClass.testFunction(
[info]     MyMessage(Example Body)
[info] );
[info] -> at MainSpec.$anonfun$new$1(MainSpec.scala:64)
```

It might also fail because the round trip takes longer on you CI-server or you broke the code. Try setting the timeout to around 100 ms to replicate the behavior. Now what's _really bad_ is that your _next_ test _will fail as well_:

```markdown
[info] MainSpec:
[info] SqsService
[info] - should receive a message *** FAILED ***
[info]   org.mockito.exceptions.verification.TooManyActualInvocations: testClass.testFunction(
[info]     MyMessage(Example Body)
[info] );
[info] Wanted 1 time:
[info] -> at MainSpec.$anonfun$new$1(MainSpec.scala:64)
[info] But was 2 times:
[info] -> at MainSpec.$anonfun$new$2(MainSpec.scala:58)
[info] -> at MainSpec.$anonfun$new$2(MainSpec.scala:58)
```

That's because the message from the previous test is still in the queue! Luckily, this can be worked around with `BeforeAndAfterEach`:

```scala
var queueUrl: String = ""

override def beforeEach(): Unit = {
  queueUrl = awsSqsClient.createQueue("integrationtest").getQueueUrl
  println("--- Created queue ---")
  super.beforeEach()
}

override def afterEach(): Unit = {
  awsSqsClient.deleteQueue(queueUrl)
  println("--- Deleted queue ---")
  super.afterEach()
}
```

This way, one failed test won't affect the next.