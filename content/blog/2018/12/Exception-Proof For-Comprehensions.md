+++
title = "Exception-Proof For-Comprehensions"
draft = false
date = "2018-12-04T21:00:00+01:00"
keywords = [ "Programming", "Scala", "Exception", "Bugfixing", "Lessons Learned", "Tutorial", "How-To" ]
slug = "exception_proof_for_comprehensions"
toc = false

[params]
  author = "Jannik Arndt"
+++

I recently created a _wonderful_ bug.

<!--more-->

Have a look at this code and tell me: Do you need to look out for exceptions?

```scala
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future
import scala.util.{Failure, Success}

object Main extends App {

  val myFuture: Future[Int] = for {
    foo <- doFoo()
    bar <- doBar()
  } yield foo + bar
  
  def doFoo(): Future[Int] = ???

  def doBar(): Future[Int] = ???

  myFuture onComplete {
    case Success(value)     => println(s"It's a $value")
    case Failure(exception) => println(s"Something went wrong: $exception")
  }
}
```

Nahhh, probably not, because

```scala
Future{
  throw new Throwable
}
```

is the same as

```scala
Future.apply(throw new Throwable)
```

is the same as

```scala
Future.unit.map(_ => throw new Throwable)
```

is the same as

```scala
Future.successful(()).transform(_ map (_ => throw new Throwable))
```

and this `transform` [is defined as](https://github.com/scala/scala/blob/2.12.x/src/library/scala/concurrent/Future.scala#L257)

```scala
def transform[S](f: Try[T] => Try[S])(implicit executor: ExecutionContext): Future[S]
```

and therefore the `map` [is defined as](https://github.com/scala/scala/blob/2.12.x/src/library/scala/util/Try.scala#L105)

```scala
def map[U](f: T => U): Try[U]
```

and `Try` [has the constructor](https://github.com/scala/scala/blob/2.12.x/src/library/scala/util/Try.scala#L207-L216)

```scala
object Try {
  /** Constructs a `Try` using the by-name parameter.  This
   * method will ensure any non-fatal exception is caught and a
   * `Failure` object is returned.
   */
  def apply[T](r: => T): Try[T] =
    try Success(r) catch {
      case NonFatal(e) => Failure(e)
    }
}
```

and _there we finally have our try-catch-block!_ So we don't have to care about exceptions in `Future`s, right?

## The Catch

While the conclusion is correct, and exceptions inside futures will be caught, _not all the code is inside a future!_

The `for` comprehension de-sugared is the same as

```scala
doFoo().flatMap(foo => doBar().map(bar => foo + bar))
```

and although `doFoo()` _returns_ a `Future`, there can be parts that are _not_ inside that `Future`:

```scala
def doFoo(): Future[Int] = {
  throw new Throwable
  Future(3)
}
```

BÄM! Now there's no `try` around the `throw` and the `Throwable` will bubble to the top and kill your program.

## The Solution

Obviously, when returning a `Future` you shouldn't throw exceptions. But if you're the caller and don't have any influence on this, this will save you:

```scala
val myFuture: Future[Int] = for {
  _   <- Future.unit
  foo <- doFoo()
  bar <- doBar()
} yield foo + bar
```

It's pretty much the same way the standard library does it: Start with something successful and `map` your way from there!

De-sugared, this would be

```scala
Future.unit.flatMap(_ => doFoo().flatMap(foo => doBar().map(bar => foo + bar)))
```

What a mess, just to be on the safe side.