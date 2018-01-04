+++
title = "Lessons learned in 2017"
draft = false
date = "2017-11-11T17:00:00+01:00"
keywords = [ "Programming" ]
slug = "lessons_learned_in_2017"

[params]
  author = "Jannik Arndt"
+++



## #1
### Conway’s Law.

> "organizations which design systems ... are constrained to produce designs which are copies of the communication structures of these organizations."

So true.

<!--more-->

## #2
### Dev-Ops is awesome.

But also a lot of work that’s hard to anticipate.

## #3
### Clearly defined interfaces clearly need to be tested.

We didn’t test ours, and it took other dev _forever_ to track down a bug in _our_ system.

## #4
### Deal with the bugs you have, not the ones you _might_ encounter.

Your software will _never_ handle all possibilities. Invest the time into good monitoring, rather than anticipating _every_ possibility.

## #5
### How to set up a robust environment.

1. Set up a dev, test and production stage.
2. Set up continuous deployment into all stages.
3. Set up a monitoring system.
4. Start coding.

## #6
### Your system doesn’t need _every_ bit of new technology.

And it probably doesn’t have “Big Data”.

## #7
### MonolithFirst
As Martin Fowler [writes](https://martinfowler.com/bliki/MonolithFirst.html):

> you shouldn't start a new project with microservices, even if you're sure your application will be big enough to make it worthwhile
