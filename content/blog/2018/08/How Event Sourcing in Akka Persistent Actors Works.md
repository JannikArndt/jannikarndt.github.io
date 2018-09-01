+++
title = "How Event Sourcing in Akka Persistent Actors Works"
draft = false
date = "2018-08-31T17:00:00+01:00"
keywords = [ "Programming", "Scala", "akka", "event sourcing", "persistent actor", "akka persistence" ]
slug = "event_sourcing_in_akka_persistent_actors"
toc = false

[params]
  author = "Jannik Arndt"
+++

While the [Akka](https://doc.akka.io/docs/) documentation is incredibly well written, it has surprisingly few images. Since _I_ visualize concepts to remember them, here is my take on how [Event Sourcing in Akka Persistence] works:

<a href="/blog/2018/08/AkkaPersistence.svg"><img src="/blog/2018/08/AkkaPersistence.svg" alt=""></a>

<!--more-->

The text I took this from is

> A persistent actor receives a (non-persistent) __command__ which is first __validated__ if it can be applied to the current state. Here validation can mean anything, from simple inspection of a command message’s fields up to a conversation with several external services, for example. If validation succeeds, __events are generated from the command__, representing the effect of the command. These __events are then persisted__ and, after successful persistence, used to __change the actor’s state__. When the persistent actor needs to be __recovered, only the persisted events are replayed__ of which we know that they can be successfully applied. In other words, events cannot fail when being replayed to a persistent actor, in contrast to commands. Event sourced actors may also process commands that do not change application state such as query commands for example.

<https://doc.akka.io/docs/akka/2.5/persistence.html#event-sourcing>, emphasis mine