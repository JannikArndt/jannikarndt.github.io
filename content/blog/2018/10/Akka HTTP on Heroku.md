+++
title = "Akka HTTP on Heroku"
draft = false
date = "2018-10-27T19:00:00+01:00"
keywords = [ "Programming", "Scala", "akka", "Akka HTTP", "Heroku", "Deployment", "App", "Tutorial", "How-To" ]
tags = [ "Scala", "Programming", "Akka HTTP" ]
slug = "akka_http_on_heroku"
toc = true

[params]
  author = "Jannik Arndt"
+++

Getting a Akka HTTP-based backend up and running on Heroku for free can be done in less then 30 minutes — if you know the tricks.

<!--more-->

## Setup

First, [create a new app on Heroku](https://dashboard.heroku.com/new-app). The easiest way to deploy something is to push it to the attached git repository, as explained on the _Deploy_ page:

<a href="/blog/2018/10/heroku1.png"><img src="/blog/2018/10/heroku1.png" alt=""></a>

Next, setup you local `sbt` project. My way would be

```shell
$ sbt new jannikarndt/scala.g8
```

Do the `git` thing:

```shell
$ git init
$ git add .
$ git commit -m "Template"  
```

and next, connect the repository to Heroku. If you haven't already, install their cli first:

```shell
$ brew install heroku/brew/heroku
...
$ heroku login
heroku: Enter your login credentials
Email: your@mail.com
Password: ************
Logged in as your@mail.com
$ heroku git:remote -a yourproject
set git remote heroku to https://git.heroku.com/yourproject.git
```

## `plugins.sbt` and `build.sbt`

To create a build that can be run on Heroku, you need the `sbt-native-packager` in your `project/plugins.sbt`:

```scala
addSbtPlugin("com.typesafe.sbt" % "sbt-native-packager" % "1.3.12")
```

You also have to _enable_ the plugin in the `build.sbt`:

```scala
enablePlugins(JavaAppPackaging)
```

This enables the `stage` command. Otherwise you'll end up with weird errors:

```scala
sbt> stage
[error] Not a valid command: stage (similar: last-grep, set, last)
[error] Not a valid project ID: stage
[error] Expected ':'
[error] Not a valid key: stage (similar: state, target, tags)
[error] stage
[error]      ^
sbt> compile stage
[error] Expected whitespace character
[error] Expected '/'
[error] compile stage
[error]         ^
```

Next, you need to define the `Main` class to be run. This is also done in your `build.sbt`:

```scala
mainClass in Compile := Some("Main")
```

Note: If you use packages, you'll need to write the full identifier, i.e. `com.mycompany.myproject.Main` or something similar.

If you get this part wrong, `sbt stage` will warn you:

```scala
sbt> stage
[info] Wrote /target/scala-2.12/yourproject_2.12-1.0.pom
[info] Packaging /target/scala-2.12/yourproject_2.12-1.0.jar ...
[info] Done packaging.
[warn] You have no main class in your project. No start script will be generated.
[warn] You have no main class in your project. No start script will be generated.
[success] Total time: 0 s, completed Oct 27, 2018 6:13:13 PM
```

but on Heroku it will actually crash the app:

```apache
heroku[web.1]: State changed from starting to crashed
app[web.1]: Error: Main method not found in class Main, please define the main method as:
app[web.1]: public static void main(String[] args)
app[web.1]: or a JavaFX application class must extend javafx.application.Application
```

The final `build.sbt` should look something like this:

```scala
name := "yourproject"
scalaVersion := "2.12.7"
version := "1.0"
maintainer := "you"
mainClass in Compile := Some("Main")

enablePlugins(JavaAppPackaging)

libraryDependencies ++= Seq(
  "com.typesafe.akka" %% "akka-http" % "10.1.5",
  "com.typesafe.akka" %% "akka-stream" % "2.5.17"
)
```

## `Main.scala`

Now that you've managed to create a build and reference the correct `mainClass`, there's only two caveats left: Binding the server. First, on Heroku you can **not** bind to `localhost`, you have to write `0.0.0.0` instead. Secondly, the port changes with every start of the app and is given as a parameter (`-Dhttp.port=36803`) and environment variable (`$PORT`). The code for this:

```scala
val port: Int = sys.env.getOrElse("PORT", "8080").toInt
WebServer.startServer("0.0.0.0", port)
```

A complete example for a WebServer would be

```scala
import akka.http.scaladsl.server._

object Main {
  def main(args: Array[String]): Unit = {
    val port: Int = sys.env.getOrElse("PORT", "8080").toInt
    WebServer.startServer("0.0.0.0", port)
  }
}

object WebServer extends HttpApp {

  override protected def routes: Route =
    pathEndOrSingleSlash {
      get {
        complete("It works")
      }
    }
}

```

## Deploy

After you tested locally running

```shell
$ sbt compile stage
```

(because that's exactly the command that will be run on Heroku's server) and maybe `sbt run` or `sbt reStart`, you can finally deploy.

Since you already connected our git to the remote repository, all you have to do is `push`:

```shell
$ git push --set-upstream heroku master
Enumerating objects: 13, done.
Counting objects: 100% (13/13), done.
Delta compression using up to 4 threads
Compressing objects: 100% (6/6), done.
Writing objects: 100% (7/7), 1.25 KiB | 1.25 MiB/s, done.
Total 7 (delta 3), reused 0 (delta 0)
remote: Compressing source files... done.
remote: Building source:
remote:
remote: -----> Scala app detected
remote: -----> Installing JDK 1.8... done
remote: -----> Running: sbt compile stage
...
remote:        [info] Done compiling.
remote:        [success] Total time: 4 s, completed Oct 27, 2018 5:44:33 PM
...
remote:        [info] Done packaging.
remote:        [success] Total time: 3 s, completed Oct 27, 2018 5:44:36 PM
remote: -----> Dropping ivy cache from the slug
remote: -----> Dropping sbt boot dir from the slug
remote: -----> Dropping compilation artifacts from the slug
remote: -----> Discovering process types
remote:        Procfile declares types     -> (none)
remote:        Default types for buildpack -> web
remote:
remote: -----> Compressing...
remote:        Done: 71.9M
remote: -----> Launching...
remote:        Released v10
remote:        https://yourproject.herokuapp.com/ deployed to Heroku
remote:
remote: Verifying deploy... done.
To https://git.heroku.com/yourproject.git
   ca5c7c5..4a5a138  master -> master
```

Now head to your url and start building the rest!