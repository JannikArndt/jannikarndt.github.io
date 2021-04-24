---
title: "def and var in traits on Scala 2.12, 2.13 and 3.0.0"
date: "2021-04-24T16:00:00+02:00"
author: "Jannik Arndt"
keywords: [ "Programming", "Scala", "Scalac", "Scalap", "Javap", "Scala Compiler", "JVM", "Bytecode", "JAR" ]
tags: [ "Scala", "Programming", "JVM" ]
slug: "def_and_var_in_trait"
showToc: false
TocOpen: true
draft: false
comments: false
---

Scala `trait`s should define `def`s, because 
>“A val can override a def, but a def cannot override a val”

(via [Alvin Alexander](https://alvinalexander.com/scala/fp-book/def-vs-val-abstract-members-traits-classes-override/) via [StackOverflow](https://stackoverflow.com/questions/13126104/is-there-any-advantage-to-definining-a-val-over-a-def-in-a-trait)). 

But it's interesting to look at how the _compiler_ treats that. 
Alvin Alexander [did that](https://alvinalexander.com/scala/all-wanted-to-know-about-def-val-var-fields-in-traits/), but only for Scala 2.12.8. 
Let's have a look at 2.12, 2.13 and the just released 3.0 (formerly known as dotty).

<!--more-->

## Getting the scalac versions

You can install different versions of the Scala compiler via brew:

```shell
$ brew install scala@2.12
$ brew install scala # currently for 2.13
$ brew install dotty # currently Scala 3.0.0-RC2
```

>Note: you can only have _one_ `scala` and `scalac` on your path, so you want to keep the versions you _don't_ use unlinked (or "keg-only" in brew-speak).

You can access the versions via 

```shell
$ /usr/local/Cellar/scala@2.12/2.12.13/bin/scalac -version # one dash only!
Scala compiler version 2.12.13 -- Copyright 2002-2020, LAMP/EPFL and Lightbend, Inc.

$ /usr/local/Cellar/scala/2.13.5/bin/scalac --version      
Scala compiler version 2.13.5 -- Copyright 2002-2020, LAMP/EPFL and Lightbend, Inc.

$ /usr/local/Cellar/dotty/3.0.0-RC3/bin/scalac --version
Scala compiler version 3.0.0-RC3 -- Copyright 2002-2021, LAMP/EPFL
```

## At the end of scalac

As you might know, the compiler works in multiple steps ("phases")., and it can output the result after each step. The `-Xshow-phases` option prints out  an overview of the compile-phases:

{{< figure class="large" src="/blog/2021/04/def_var_trait/phases.png" >}}

<details>
<summary>Here they are written out, if you want to read through them:
</summary>

### Scala 2.12.13

```shell
$ /usr/local/Cellar/scala@2.12/2.12.13/bin/scalac -Xshow-phases
    phase name  id  description
    ----------  --  -----------
        parser   1  parse source into ASTs, perform simple desugaring
         namer   2  resolve names, attach symbols to named trees
packageobjects   3  load package objects
         typer   4  the meat and potatoes: type the trees
        patmat   5  translate match expressions
superaccessors   6  add super accessors in traits and nested classes
    extmethods   7  add extension methods for inline classes
       pickler   8  serialize symbol tables
     refchecks   9  reference/override checking, translate nested objects
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

### Scala 2.13.5

```shell
/usr/local/Cellar/scala/2.13.5/bin/scalac -Xshow-phases        
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

### Scala 3.0.0-RC3 aka dotty

```shell
/usr/local/Cellar/dotty/3.0.0-RC3/bin/scalac -Xshow-phases  
typer
inlinedPositions
sbt-deps
extractSemanticDB
posttyper
prepjsinterop
sbt-api
SetRootTree
pickler
inlining
postInlining
staging
pickleQuotes
{firstTransform, checkReentrant, elimPackagePrefixes, cookComments, checkStatic, betaReduce, inlineVals, expandSAMs, initChecker}
{elimRepeated, protectedAccessors, extmethods, uncacheGivenAliases, byNameClosures, hoistSuperArgs, specializeApplyMethods, refchecks}
{elimOpaque, tryCatchPatterns, patternMatcher, explicitJSClasses, explicitOuter, explicitSelf, elimByName, stringInterpolatorOpt}
{pruneErasedDefs, inlinePatterns, vcInlineMethods, seqLiterals, intercepted, getters, specializeFunctions, liftTry, collectNullableFields, elimOuterSelect, resolveSuper, functionXXLForwarders, paramForwarding, genericTuples, letOverApply, arrayConstructors}
erasure
{elimErasedValueType, pureStats, vcElideAllocations, arrayApply, addLocalJSFakeNews, elimPolyFunction, tailrec, completeJavaEnums, mixin, lazyVals, memoize, nonLocalReturns, capturedVars}
{constructors, instrumentation}
{lambdaLift, elimStaticThis, countOuterAccesses}
{dropOuterAccessors, flatten, renameLifted, transformWildcards, moveStatic, expandPrivate, restoreScopes, selectStatic, junitBootstrappers, collectSuperCalls, repeatableAnnotations}
genSJSIR
genBCode
```

</details>

## Compile results

and the result is

```shell
$ /usr/local/Cellar/dotty/3.0.0-RC3/bin/scalac -Xprint:all Main.scala
[…]
result of Main.scala after MegaPhase{dropOuterAccessors, flatten, renameLifted, transformWildcards, moveStatic, expandPrivate, restoreScopes, selectStatic, collectSuperCalls, repeatableAnnotations}:
```
```scala
package <empty> {
  @scala.annotation.internal.SourceFile("Main.scala") class MyClass extends 
    Object
  , MyTrait {
    def <init>(): Unit = 
      {
        super()
        this.id = 1
        ()
      }
    private val id: Int
    def id(): Int = this.id
  }
  @scala.annotation.internal.SourceFile("Main.scala") trait MyTrait() extends 
    Object
   {
    def id(): Int
  }
}
```

## Example Code

I combined the function, abstract value and concrete value into one example:

```scala
trait MyTrait {
    def id1: Int     // function
    val id2: Int     // abstract value
    val id3: Int = 3 // concrete value
}

class MyClass extends MyTrait {
    val id1 = 1
    val id2 = 2
    override val id3 = 3
}
```

## Results

Here are the results:

{{< figure class="large" src="/blog/2021/04/def_var_trait/lastphase.png" >}}

Let's unpack this:

### 1. Scala 2.12 and 2.13 have the same output:

```scala
package <empty> {
  abstract trait MyTrait extends Object {
    <accessor> <sub_synth> protected[this] def MyTrait$_setter_$id3_=(x$1: Int): Unit;
    def id1(): Int;
    <stable> <accessor> def id2(): Int;
    <stable> <accessor> <sub_synth> def id3(): Int;
    def /*MyTrait*/$init$(): Unit = {
      MyTrait.this.MyTrait$_setter_$id3_=((3: Int));
      ()
    }
  };
  class MyClass extends Object with MyTrait {
    override <accessor> protected[this] def MyTrait$_setter_$id3_=(x$1: Int): Unit = ();
    private[this] val id1: Int = _;
    <stable> <accessor> def id1(): Int = MyClass.this.id1;
    private[this] val id2: Int = _;
    <stable> <accessor> def id2(): Int = MyClass.this.id2;
    private[this] val id3: Int = _;
    override <stable> <accessor> def id3(): Int = MyClass.this.id3;
    def <init>(): MyClass = {
      MyClass.super.<init>();
      MyClass.super./*MyTrait*/$init$();
      MyClass.this.id1 = 1;
      MyClass.this.id2 = 2;
      MyClass.this.id3 = 3;
      ()
    }
  }
}
```

In the `trait`, the function

```scala
def id1: Int
```
becomes
```scala
def id1(): Int;
```

the abstract `val` 
```scala
val id2: Int
```
becomes
```scala
<stable> <accessor> def id2(): Int;
```

and the concrete `val`
```scala
val id3: Int = 3
```
needs the most work:
```scala
<stable> <accessor> <sub_synth> def id3(): Int;
<accessor> <sub_synth> protected[this] def MyTrait$_setter_$id3_=(x$1: Int): Unit;
def /*MyTrait*/$init$(): Unit = {
  MyTrait.this.MyTrait$_setter_$id3_=((3: Int));
  ()
}
```
(The constructor would not be present if the `trait` only contained `id1` and `id2`.)

What do `<stable> <accessor> <sub_synth>` mean _exactly_? I have no idea. Neither does Google.

In the `class` we have private `val`s for all three:
```scala
private[this] val id1: Int = _;
<stable> <accessor> def id1(): Int = MyClass.this.id1;

private[this] val id2: Int = _;
<stable> <accessor> def id2(): Int = MyClass.this.id2;

private[this] val id3: Int = _;
override <stable> <accessor> def id3(): Int = MyClass.this.id3;
```

and the `MyTrait$_setter_$id3_` from the `trait` is overridden:
```scala
override <accessor> protected[this] def MyTrait$_setter_$id3_=(x$1: Int): Unit = ();
```

So in summary: So far, there's not _much_ of a difference. 

### 2. Scala 3 has syntax-highlighting!

After the compile-phases-output was so ugly, it's nice to see that the output of the phases is actually colored.

### 3. There's an annotation

```scala
@scala.annotation.internal.SourceFile("Main.scala")
```

points to the source file. Neat. 

### 4. `<stable> <accessor> <sub_synth>` are gone

I guess now I'll never find out what they were…

This also means that all fields in the `trait` are now exactly the same:

```scala
def id1(): Int
def id2(): Int
def id3(): Int
```

and the setter-function for `id3` goes from

```scala
<accessor> <sub_synth> protected[this] def MyTrait$_setter_$id3_=(x$1: Int): Unit;
```

to 

```scala
def MyTrait$_setter_$id3_$eq(x$0: Int): Unit
```

In the `class`, the three are also very much alike:

```scala
private val id1: Int
def id1(): Int = this.id1

private val id2: Int
def id2(): Int = this.id2

private var id3: Int
override def id3(): Int = this.id3
```

## Bytecode deep-dive

Let's take one step further and take the actual Bytecode apart, using `javap -c`:

{{< figure class="large" src="/blog/2021/04/def_var_trait/bytecode.png" >}}

Observations:
* Scala 2.12 and 2.13 result in the _exact_ same Bytecode
* Scala 3 places the constructor first
* The `MyTrait$_setter_$id3_$eq(int)` actually contains some setting-code now!
  ```
  public void MyTrait$_setter_$id3_$eq(int);
    Code:
       0: aload_0
       1: iload_1
       2: putfield      #25                 // Field id3:I
       5: return
  ```
  as compared to 
  ```
  public void MyTrait$_setter_$id3_$eq(int);
    Code:
       0: return
  ```
* the `scala.runtime.Statics$#releaseFence()` has a single jvm-operation (`invokestatic`) resulting from it.


## Next Level: JVM 17

The compiler can also target a specific version of the Java platform, using the `-target:8` (`-Xtarget` for Scala 3) or `-release` option. However, for this simple example, there were no differences in the bytecode.

## Summary

So, what to make of this? Easy: Using `def` or `val` in traits is purely a _developer ergonomics_ decision, _not_ a runtime difference.