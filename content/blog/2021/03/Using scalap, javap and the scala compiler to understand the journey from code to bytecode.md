---
title: "Using scalap, javap and the scala compiler to understand the journey from code to bytecode"
date: "2021-03-25T09:00:00+01:00"
author: "Jannik Arndt"
keywords: [ "Programming", "Scala", "Scalac", "Scalap", "Javap", "Scala Compiler", "JVM", "Bytecode", "JAR" ]
tags: [ "Scala", "Programming", "JVM" ]
slug: "using_scalap_javap_and_the_scala_compiler"
toc: true
showToc: true
TocOpen: true
draft: false
comments: false
---

Do you know what happens after you compile? Let's take a look at what the Scala compiler tells us, and what `scalap` and `javap` can reveal about `.class` files.


<!--more-->

## Creating a Minimal Example with `sbt`

First, we'll need something very small to compile, to still understand _all_ of the output. 

{{< filename title="build.sbt" >}}

```scala
name := "scala-start"
version := "1"
scalaVersion := "2.13.5"
scalacOptions := Seq("-target:11")
```

{{< filename title="project/build.properties" >}}

```scala
sbt.version=1.4.9
```

{{< filename title="src/main/scala/Main.scala" >}}

```scala
object Main {
    def main(args: Array[String]) = {
        println("Hello.")
    }
}
```

run 
```shellsession
$ sbt package
```

The result is in `target/scala-2.13/scala-start_2.13-1.jar`. You can look at/unpack the contents via

```shell
$ jar -xvf target/scala-2.13/scala-start_2.13-1.jar             
 inflated: META-INF/MANIFEST.MF
 inflated: Main$.class
 inflated: Main.class
```

To run it via `java`, you need to add both the `jar` and the `scala-library.jar` to the classpath. If you use `sbt stage`, it gets copied next to the output, but you can also reference the one that is already present on your machine (in this example installed via Homebrew):

```shell
$ java -cp "/usr/local/Cellar/scala/2.13.5/libexec/lib/*:." Main  
Hello.
```

## Creating a Really Minimal Example (without `sbt`)

To go even more minimal, you can work with a single scala-file:

{{< filename title="Main.scala" >}}

```scala
object Main {
    def main(args: Array[String]) = {
        println("Hello.")
    }
}
```

Compile and run it via

```shell
scala Main.scala 
Hello.
```

or

```shell
$ scalac Main.scala 
$ scala Main       
Hello.
```

The second version will create two `class` files (that you also found inside the `jar` earlier):

* `Main.class`
* `Main$.class` (the object)

## Running `scalap` and `javap`

Now that you have `class`-files, you can take them apart with

```shell
$ scalap Main Main$
```
```scala
object Main extends scala.AnyRef {
  def this() = { /* compiled code */ }
  def main(args: scala.Array[scala.Predef.String]): scala.Unit = { /* compiled code */ }
}

package Main$;
final class Main$ extends scala.AnyRef {
  def this(): scala.Unit;
  def main(scala.Array[java.lang.String]): scala.Unit;
}
object Main$ {
  final val MODULE$: Main$;
}
```

You can also use `javap`, since it's just class-files:

```shell
$ javap Main Main$
```
```java
Compiled from "Main.scala"
public final class Main {
  public static void main(java.lang.String[]);
}
Compiled from "Main.scala"
public final class Main$ {
  public static final Main$ MODULE$;
  public static {};
  public void main(java.lang.String[]);
}
```

## Excursion: Scala 3 / dotty

If you compile with the Scala 3 compiler (dotty), the result of `scalap` will be slightly different:

```shell
$ /usr/local/Cellar/dotty/3.0.0-RC1/bin/scalac Main.scala
$ scalap Main Main$
```
```scala
package Main;
final class Main extends scala.AnyRef {
}
object Main {
  def main(scala.Array[java.lang.String]): scala.Unit;
}
package Main$;
final class Main$ extends scala.AnyRef with java.io.Serializable {
  def main(scala.Array[java.lang.String]): scala.Unit;
  def writeReplace(): scala.Any;
  def this(): scala.Unit;
}
object Main$ {
  final val MODULE$: Main$;
}
```

…while the `javap` output stays _almost_ the same (except for `implements java.io.Serializable`).

```shell
$ javap Main Main$
```
```java
Compiled from "Main.scala"
public final class Main {
  public static void main(java.lang.String[]);
}
Compiled from "Main.scala"
public final class Main$ implements java.io.Serializable {
  public static final Main$ MODULE$;
  public static {};
  public void main(java.lang.String[]);
}
```

## Printing just before JVM Bytecode Generation

The Scala compiler allows you to get a preview with the `print` flag:

```shell
$ scalac -print:true Main.scala
```
```scala
[[syntax trees at end of                   cleanup]] // Main.scala
package <empty> {
  object Main extends Object {
    def main(args: Array[String]): Unit = scala.Predef.println("Hello.");
    def <init>(): Main.type = {
      Main.super.<init>();
      ()
    }
  }
}
```

The "cleanup" refers to the phase of the compiler. You can see them with

```shell
$ scalac -Vphases // or -Xshow-phases         
    phase name  id  description
    ----------  --  -----------
        parser   1  parse source into ASTs, perform simple desugaring
         namer   2  resolve names, attach symbols to named trees
packageobjects   3  load package objects
         typer   4  the meat and potatoes: type the trees
superaccessors   5  add super accessors in traits and nested classes
    extmethods   6  add extension methods for inline classes
       pickler   7  serialize symbol tables
     refchecks   8  reference/override checking, translate nested objects
        patmat   9  translate match expressions
       uncurry  10  uncurry, translate function values to anonymous classes
        fields  11  synthesize accessors and fields, add bitmaps for lazy vals
     tailcalls  12  replace tail calls by jumps
    specialize  13  @specialized-driven class and method specialization
 explicitouter  14  this refs to outer pointers
       erasure  15  erase types, add interfaces for traits
   posterasure  16  clean up erased inline classes
    lambdalift  17  move nested functions to top level
  constructors  18  move field definitions into constructors
       flatten  19  eliminate inner classes
         mixin  20  mixin composition
       cleanup  21  platform-specific cleanups, generate reflective calls
    delambdafy  22  remove lambdas
           jvm  23  generate JVM bytecode
      terminal  24  the last phase during a compilation run
```

You can also get the output after a specific compiler phase with

```shell
$ scalac -Vprint:24 Main.scala
```
```scala
[[syntax trees at end of                   pickler]] // Main.scala
package <empty> {
  object Main extends scala.AnyRef {
    def <init>(): Main.type = {
      Main.super.<init>();
      ()
    };
    def main(args: Array[String]): Unit = scala.Predef.println("Hello.")
  }
}
```

You can also specify ranges:
```shell
$ scalac -Vprint:1-5 Main.scala
```
or all the steps with underscore:
```shell
$ scalac -Vprint:_ Main.scala
```

You can find more information about the compiler-flags 
* by running `scalac`, `scalac -V`, `scalac -X`, etc
* [in the docs](https://docs.scala-lang.org/overviews/compiler-options/index.html)
* [on this website](https://blog.ssanj.net/posts/2019-06-14-scalac-2.13-options-and-flags.html)
* [at the source of truth aka _the code_](https://github.com/scala/scala/blob/2.13.x/src/compiler/scala/tools/nsc/settings/ScalaSettings.scala)


## The Bytecode

The final step is to see the actual bytecode:

```shell
$ javap -private -c -s -l Main
```
```java
Compiled from "Main.scala"
public final class Main {
  public static void main(java.lang.String[]);
    descriptor: ([Ljava/lang/String;)V
    Code:
       0: getstatic     #17                 // Field Main$.MODULE$:LMain$;
       3: aload_0
       4: invokevirtual #19                 // Method Main$.main:([Ljava/lang/String;)V
       7: return
}
```

You can also use a tool such as [jclasslib](https://github.com/ingokegel/jclasslib) to inspect the bytecode.

## The Java Code

Okay, Bytecode was _not_ the final step, you can take one further and convert it back to Java code! I use [cfr](https://github.com/leibnitz27/cfr) for that, and add the `scala-library` to the classpath:

```shell
$ java -jar cfr.jar Main Main$ --extraclasspath /usr/local/Cellar/scala/2.13.5/libexec/lib/scala-library.jar
```
```java
/*
 * Decompiled with CFR 0.151.
 */
import scala.reflect.ScalaSignature;

@ScalaSignature(bytes="\u0006\u0005... (this is 'pickled scala')")
public final class Main {
    public static void main(String[] stringArray) {
        Main$.MODULE$.main(stringArray);
    }
}
/*
 * Decompiled with CFR 0.151.
 */
import scala.Predef$;

public final class Main$ {
    public static final Main$ MODULE$ = new Main$();

    public void main(String[] args) {
        Predef$.MODULE$.println("Hello.");
    }

    private Main$() {
    }
}
```

## Errors you can run into


### NoClassDefFoundError: scala/Predef$

```shell
Exception in thread "main" java.lang.NoClassDefFoundError: scala/Predef$
	at Main$.main(Main.scala:3)
	at Main.main(Main.scala)
Caused by: java.lang.ClassNotFoundException: scala.Predef$
	at java.base/jdk.internal.loader.BuiltinClassLoader.loadClass(BuiltinClassLoader.java:606)
	at java.base/jdk.internal.loader.ClassLoaders$AppClassLoader.loadClass(ClassLoaders.java:168)
	at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:522)
```

=> your `jar` is missing the `scala-library`. Either package it (using `sbt stage` for example) or add it to the classpath. Either way you probably want to use

```
$ java -cp "path/to/scala/lib/*:path/to/your/jar" NameOfTheMainClass
```

for example

```
$ java -cp "/usr/local/Cellar/scala/2.13.5/libexec/lib/*:target/scala-2.13/scala-start_2.13-1.jar" Main
```

### NoClassDefFoundError: scala/Function0

```shell
Error: Unable to initialize main class Main
Caused by: java.lang.NoClassDefFoundError: scala/Function0
```

This is the same as above, but you used the 
```scala
object Main extends App {
  println("Hello.")
}
```
code, which gives a slightly nicer error message. The solution is the same: put the `scala-library` and your `jar` in the classpath.

### No such file or class on classpath: Main

```shell
$ scala Main       
No such file or class on classpath: Main
```

The `scala` command can do two things:
* run something from a `*.class` file if you provide a _name_
* compile and run something if you provide a _file name_

Solution: Either run `$ scala Main.scala` or `$ scalac Main.scala` _first_ and _then_ `$ scala Main`.

### class/object Main not found.

```shell
$ scalap Main      
class/object Main not found.
$ scalap Main.scala 
class/object Main.scala not found.
```

The `scalap` tool actually needs compiled classes. Run `$ scalac Main.scala` first.