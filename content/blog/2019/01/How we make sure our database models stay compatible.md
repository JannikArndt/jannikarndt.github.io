+++
title = "How we make sure our database models stay compatible"
draft = false
date = "2019-01-13T14:00:00+01:00"
keywords = [ "Programming", "Scala", "Lessons Learned", "Tutorial", "How-To", "ScalaCheck", "Compatibly", "DynamoDB", "Database" ]
slug = "compatible_datanase_models"
toc = false

[params]
  author = "Jannik Arndt"
+++

It is good practice for model classes that are used to communicate with other systems to build intermediate models to decouple internal and external logic. This way internal refactoring doesn't require changing the interface but can be made compatible by changing a mapping-logic. In addition, the impact of changes in other services on internal logic can be minimized.

Protobuf is a good solution to define interfaces between services. We use [ScalaPB](https://scalapb.github.io) to generate case classes from the Protobuf definitions. Then a set of macros map these to our internal model. Any change that is not compatible will not compile. 

While this gives you confidence that you don't break anything, on the downside it makes _intended changes_ quite a lot of work.

For our database model-classes we've tried another approach: We've created _tests_ that fail if a change is not compatible. [ScalaCheck](https://www.scalacheck.org)-generators help us create all possible values for a version which are then written into a file and checked against all future versions of the model classes.

This article will guide you through the steps the create these tests.

<!--more-->

