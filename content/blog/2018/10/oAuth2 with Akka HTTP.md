+++
title = "oAuth2 with Akka HTTP"
draft = false
date = "2018-10-28T13:00:00+01:00"
keywords = [ "Programming", "Scala", "akka", "Akka HTTP", "oAuth2", "App", "Tutorial", "How-To" ]
slug = "oauth2-akka-http"
toc = true

[params]
  author = "Jannik Arndt"
+++

This is a basic example how to implement oAuth2 using Akka HTTP and Scala. It provides three endpoints. From the clients point of view:

* `/` — publicly accessible, returns “Welcome!”,
* `/auth` — provide your `username` and `password`, receive an `access_token` in return,
* `/api` — secured by oAuth, send the `access_token` in a header to gain access.

From the server's point of view:

* `/` — publicly accessible, do nothing,
* `/auth` — receive basic auth credentials, verify they're in the list of known credentials, create an `access_token`, return it,
* `/api` — receive `authorization` header, check if `access_token` is in list of valid tokens.

Since oAuth tokens are short lived, the server also has to invalidate expired tokens.

<!--more-->

## `build.sbt`

This minimal example requires the following imports in your `build.sbt`:

```scala
name := "oAuth-example"
scalaVersion := "2.12.7"
version := "1.0"

libraryDependencies ++= Seq(
  "com.typesafe.akka" %% "akka-http" % "10.1.5",
  "com.typesafe.akka" %% "akka-stream" % "2.5.17",
  "de.heikoseeberger" %% "akka-http-json4s" % "1.22.0",
  "org.json4s" %% "json4s-native" % "3.6.1",
  "com.typesafe.scala-logging" %% "scala-logging" % "3.9.0",
  "org.slf4j" % "slf4j-simple" % "1.7.25"
)
```

## Start a `WebServer`

The basic `WebServer` can be started using the following code:

```scala
import akka.http.scaladsl.server._
import com.typesafe.scalalogging.StrictLogging

object Main {
  def main(args: Array[String]): Unit = {
    val port: Int = sys.env.getOrElse("PORT", "8080").toInt
    WebServer.startServer("0.0.0.0", port)
  }
}

object WebServer extends HttpApp with StrictLogging {

  override protected def routes: Route =
    pathEndOrSingleSlash {
      get {
        complete("Welcome!")
      }
    }
}
```

You can test it in the console:

```zsh
➜ ~ curl --request GET --url http://localhost:8080
Welcome!
```

## Basic Auth

Next, we'll add the `auth` endpoint:

```scala
path("auth") {
  authenticateBasic(realm = "auth", BasicAuthAuthenticator) { user =>
    post {
      // do stuff with user
    }
  }
}
```

This calls a `BasicAuthAuthenticator` function which goes through the list of `validBasicAuthCredentials` and compares `username` and `password`. Note that `p.verify(user.password)` does a _constant time comparison_ to make this [invulnerable against timing attacks](https://doc.akka.io/docs/akka-http/current/routing-dsl/directives/security-directives/index.html#credentials-and-timing-attacks):

```scala
case class BasicAuthCredentials(username: String, password: String)

private val validBasicAuthCredentials = Seq(BasicAuthCredentials("jannik", "p4ssw0rd"))

private def BasicAuthAuthenticator(credentials: Credentials) =
  credentials match {
    case p @ Credentials.Provided(_) =>
      validBasicAuthCredentials
        .find(user => user.username == p.identifier && p.verify(user.password))
    case _ => None
  }
```

Our code then creates an `access_token`, stores it in a list and returns it:

```scala
private val loggedInUsers = mutable.ArrayBuffer.empty[LoggedInUser]

case class oAuthToken(access_token: String = java.util.UUID.randomUUID().toString,
                      token_type: String = "bearer",
                      expires_in: Int = 3600)

case class LoggedInUser(basicAuthCredentials: BasicAuthCredentials,
                        oAuthToken: oAuthToken = new oAuthToken,
                        loggedInAt: LocalDateTime = LocalDateTime.now())
```

Inside the `/auth` route:

```scala
path("auth") {
  authenticateBasic(realm = "auth", BasicAuthAuthenticator) { user =>
    post {
      val loggedInUser = LoggedInUser(user)
      loggedInUsers.append(loggedInUser)
      complete(loggedInUser.oAuthToken)
    }
  }
}
```

To make this work with JSON, I also added the following lines:

```scala
import de.heikoseeberger.akkahttpjson4s.Json4sSupport._
implicit val formats: DefaultFormats.type = DefaultFormats
implicit val serialization: Serialization.type = native.Serialization
```

Try getting an `access_token` via

```zsh
➜  ~ curl --request POST --url http://localhost:8080/auth --header 'authorization: Basic amFubmlrOnA0c3N3MHJk'
{"access_token":"2e510027-0eb9-4367-b310-68e1bab9dc3d", "token_type":"bearer", "expires_in":3600}
```

## oAuth

The `/api` endpoint looks very similar:

```scala
path("api") {
  authenticateOAuth2(realm = "api", oAuthAuthenticator) { validToken =>
    complete(s"It worked! user = $validToken")
  }
}
```

It calls the `oAuthAuthenticator` function which looks through the list of `loggedInUsers`.

```scala
private def oAuthAuthenticator(credentials: Credentials): Option[LoggedInUser] =
  credentials match {
    case p @ Credentials.Provided(_) =>
      loggedInUsers.find(user => p.verify(user.oAuthToken.access_token))
    case _ => None
  }
```

You call this endpoint via

```zsh
➜  ~ curl --request GET --url http://localhost:8080/api --header 'authorization: Bearer 2e510027-0eb9-4367-b310-68e1bab9dc3d' 
"It worked! user = LoggedInUser(BasicAuthCredentials(jannik,p4ssw0rd),oAuthToken(2e510027-0eb9-4367-b310-68e1bab9dc3d,bearer,3600),2018-10-28T12:58:33.048)"
```

## Expire Sessions

For the final touches, we can hook into the `ActorSystem` to schedule a `cleanUpExpiredUsers()` function:

```scala
override def postHttpBinding(binding: Http.ServerBinding): Unit = {
  systemReference.get().scheduler.schedule(5 minutes, 5 minutes)(cleanUpExpiredUsers())(systemReference.get().dispatcher)
  super.postHttpBinding(binding)
}

private def cleanUpExpiredUsers(): Unit =
  loggedInUsers
    .filter(user => user.loggedInAt
                        .plusSeconds(user.oAuthToken.expires_in)
                        .isBefore(LocalDateTime.now()))
    .foreach(loggedInUsers -= _)
```

If you look inside the [HttpApp](https://github.com/akka/akka-http/blob/master/akka-http/src/main/scala/akka/http/scaladsl/server/HttpApp.scala#L87) you'll notice that the `ActorSystem` isn't initialized until `startServer()` is called. Therefore we can only access it afterwards. This is easily done by overriding [`postHttpBinding()`](https://github.com/akka/akka-http/blob/master/akka-http/src/main/scala/akka/http/scaladsl/server/HttpApp.scala#L140).

Since we store the time of login, we can simply add the `expires_in` to that an check if that `LocalDateTime` is in the past. If so, the session has expired and we remove the user from the `loggedInUsers` list.

## Complete Example

And now the complete example:

```scala
import java.time.LocalDateTime

import akka.http.scaladsl.Http
import akka.http.scaladsl.server._
import akka.http.scaladsl.server.directives.Credentials
import com.typesafe.scalalogging.StrictLogging
import org.json4s.native.Serialization
import org.json4s.{DefaultFormats, native}

import scala.collection.mutable
import scala.concurrent.duration._
import scala.language.postfixOps

object Main {
  def main(args: Array[String]): Unit = {
    val port: Int = sys.env.getOrElse("PORT", "8080").toInt
    WebServer.startServer("0.0.0.0", port)
  }
}

object WebServer extends HttpApp with StrictLogging {

  import de.heikoseeberger.akkahttpjson4s.Json4sSupport._

  implicit val formats: DefaultFormats.type = DefaultFormats
  implicit val serialization: Serialization.type = native.Serialization

  // TODO load from external source
  private val validBasicAuthCredentials = Seq(BasicAuthCredentials("jannik", "p4ssw0rd"))

  // TODO persist to make sessions survive restarts
  private val loggedInUsers = mutable.ArrayBuffer.empty[LoggedInUser]

  override def postHttpBinding(binding: Http.ServerBinding): Unit = {
    systemReference.get().scheduler.schedule(5 minutes, 5 minutes)(cleanUpExpiredUsers())(systemReference.get().dispatcher)
    super.postHttpBinding(binding)
  }

  override protected def routes: Route =
    pathEndOrSingleSlash {
      get {
        complete("Welcome!")
      }
    } ~
      path("auth") {
        authenticateBasic(realm = "auth", BasicAuthAuthenticator) { user =>
          post {
            val loggedInUser = LoggedInUser(user)
            loggedInUsers.append(loggedInUser)
            complete(loggedInUser.oAuthToken)
          }
        }
      } ~
      path("api") {
        authenticateOAuth2(realm = "api", oAuthAuthenticator) { validToken =>
          complete(s"It worked! user = $validToken")
        }
      }

  private def BasicAuthAuthenticator(credentials: Credentials): Option[BasicAuthCredentials] =
    credentials match {
      case p @ Credentials.Provided(_) =>
        validBasicAuthCredentials.find(user => user.username == p.identifier && p.verify(user.password))
      case _ => None
    }

  private def oAuthAuthenticator(credentials: Credentials): Option[LoggedInUser] =
    credentials match {
      case p @ Credentials.Provided(_) =>
        loggedInUsers.find(user => p.verify(user.oAuthToken.access_token))
      case _ => None
    }

  private def cleanUpExpiredUsers(): Unit =
    loggedInUsers
      .filter(user => user.loggedInAt.plusSeconds(user.oAuthToken.expires_in).isBefore(LocalDateTime.now()))
      .foreach(loggedInUsers -= _)

  case class BasicAuthCredentials(username: String, password: String)

  case class oAuthToken(access_token: String = java.util.UUID.randomUUID().toString,
                        token_type: String = "bearer",
                        expires_in: Int = 3600)

  case class LoggedInUser(basicAuthCredentials: BasicAuthCredentials,
                          oAuthToken: oAuthToken = new oAuthToken,
                          loggedInAt: LocalDateTime = LocalDateTime.now())

}
```

The next steps would be to fill the `validBasicAuthCredentials` from somewhere outside the code and store the `loggedInUsers` outside the runtime to make sessions survive restarts.