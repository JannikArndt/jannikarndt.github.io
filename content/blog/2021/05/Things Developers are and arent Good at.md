---
title: "Things Developers are and aren't Good at"
date: "2021-05-01T13:00:00+01:00"
author: "Jannik Arndt"
keywords: [ "Programming", "Developers" ]
tags: [ "Programming" ]
slug: "things_developers_are_and_arent_good_at"
toc: false
showToc: false
TocOpen: true
draft: false
comments: false
---

…in _my_ experience.

<!--more-->

## What we are Good at

### Splitting Big Problems into Smaller Problems

This is what we do all day: Splitting problems into steps, steps into functions, functions into input and output, in- and output into data structures. Then we solve these one by one and connect them. Voilà.

### Layers of Abstraction

The smaller problems are on a different layer, meaning they have a different level of detail. Since we (humans) can only keep a small number of things in our heads, this allows us to think about _all_ things that are relevant _for this layer_, and then combine layers to solve the bigger problem.

You don't usually think about how the operating system works if you design a website, because that problem is solved on a deeper layer.

### Reuse existing Solutions

Not only do you not think about the operating system or the HTTP server _while_ you build a website — usually you don't have to think about them _at all_, because others already did that. Many other layers are already solved, and you just put a new combination of solutions on top.

This doesn't work _perfectly_, as the existence and prevalence of the _Not Invented Here Syndrom_ shows. But the problem here is more of a nuance than a fundamental unwillingness.

### Write new Solutions

Like a cook mixes ingredients, we mix code as our everyday job. A lot. So we're fairly good at it.

### Think about Edge Cases

Making decisions explicit on code reveals cases when expectations are _not_ met. Some languages (like Scala) make it painfully obvious or even refuse to compile if you don't cover all cases. So we're trained at _finding_ edge-cases. Results vary on how well we handle them.

### Express Oneself

Eloquence does not help when writing code. Either you do what the compiler expects, or it doesn't work. This forces you to learn how to express the structures and logic in your head in a clear manner. That's why they call it "Programming Language".

Aside from "talking" to compilers, we also talk a lot to _other_ developers _about_ the nuances of how we write code. It helps to be able to express yourself there as well.

## What we are _not_ so Good at

Each of these come with a downside.

### Keeping the Big Picture in Mind

Too often we get lost in the details of a sub-sub-problem, that solves a slightly different sub-problem, that doesn't really help our main-problem. 

### Creating _Good_ Layers of Abstraction

Most abstractions are leaky. If you don't understand the thing they abstract, you will sooner or later be surprised. These surprises are called "bugs".

### Researching Existing Solutions

It is way easier to write new solutions than searching through all the existing ones. It's also very often perceived as _faster_, but that is only true for the first 80%. The second 80% take way more time than you anticipated.
We also seldomly solve just one problem, so existing solutions tend to solve more or less than what we need.
And we're not good at expressing _what exactly_ a thing solves.

### Understanding Old Solutions

Old code, code written by others, code written by an earlier version of yourself, code written in another language, it's all bad. Because we all know that _reading_ code is that much harder than writing it, and _even if_ you took the time to read it, you might still have solved the problem _slightly_ differently.

### Thinking about _All_ Edge Cases

That's the other type of bug. You underestimated the complexity of the whole thing.

### Expressing Oneself

Practising talking to a machine all day can make it really hard to talk to a human who is inaccurate, unsure or has feelings. The feedback loop is different, the errors you make aren't always obvious.



