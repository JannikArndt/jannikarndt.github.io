+++
title = "Lessons learned in 2016"
draft = false
date = "2017-01-03T10:12:00+01:00"
keywords = [ "Programming" ]
slug = "lessons_learned_in_2016"

[params]
  author = "Jannik Arndt"
+++

## #1
### Do not fix your code.

Rather understand why nothing kept you from creating this bug. Make your code so easy that this bug would have been obvious the first time.

<!--more-->

## #2
### Automate early.

You know, CI/CD. Or just clean-up-scripts. Or a complete infrastructure-as-code. Remember: A script to setup something is the best documentation!

## #3 
### A function must not do more than one thing.

If a function name contains “and” there's still work to do. Build small pieces.

## #4 
### Side effects are the root of all evil.

If you need side effects (like database or file outputs), let it be the _only_ thing a function does.

## #5 
### It's all about data.

Business logic is just a concept to change data.

## #6 
### A system is defined by its input and output.

Every description of anything should focus on these two things first. 

