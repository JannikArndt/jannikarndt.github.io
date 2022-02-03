---
title: "Why growth is so bad"
date: "2022-02-03T11:30:00+02:00"
author: "Jannik Arndt"
keywords: [ "Blog", "Company Culture", "Agile" ]
tags: [ ]
slug: "why_growth_is_so_bad"
toc: false
draft: false
comments: false
cover:
  image: "opengraphimages/Generating Open Graph Images for my Blog.png"

---


Over the past year, many (including me) have left the company I worked for for more or less growth-related reasons. But what is it about growth that actually drives people away?

## Step 1: need for workforce / talent

The first growth isn't bad. You can only do so much in a day, and at some point, your company will need more people to solve all the tasks. Or specialized people, because you don't know _all_ about security, marketing, strategy, finances or a particular problem domain.

## Step 2: redundancy

Now you notice that you have a crucial area covered by _one_ person, and suddenly an incident happens where that person is sick, leaves for another job, or is run over by the proverbial truck. Suddenly you're _worse_ off than before, because not just the expertise but even the _base knowledge_ is gone. So you need redundancy. Spread the knowledge across multiple brains. Makes sense.

## Step 3: diversity

At this point you grow from ~20 to ~50 or maybe even ~100 people, and all seems fine. Along the way you have to split up teams because they grow too big. But splits are imperfect, you don't have two of _every_ role, so you need to hire more people for the new team. This works for a while. 
But along the way, you will notice that people aren't all the same. That's a good thing, mostly, but not always. Some people find fullfillment in their job, while others have a private life. Some are heavy talkers in meetings, while others would rather focus on few, precise words. Some people change. Some people weren't that into the job in the first place. Some people were hired very early and don't really fit into what the company has turned out to be.

At first, the teams themselves notice these differences. Their mostly fine, because individuals make up for their weaknesses with other qualities, and inside a team you usually know these trade-offs.

Next, management will start to notice. But they have a different perspective. At the scale of the company, small effects sum up. You need to tackle that.

## Step 4: processes

I know, cheap shot. But processes are _the_ countermeasure to proliferation —which is what diversity looks like on a larger scale— with a precise scope to keep the _good_ parts of the variety alive. Someone is sick? Just follow the process to let the company know. Someone breaks the code? Establish a review-process. Someone buys uncessessarily expensive stuff? Create a procurement policy. Someone is unhappy? Solve it with 1:1s, great people managers, hierarchies. Nobody remembers how or why something was created? Write guidelines on writing documentation, RFCs, decision logs.

Processes are an investment. They are well-known, established tools to make teams work together. 

Except for the individual they're not. They _are_ overhead. Every step that prevents a bad thing from happening is also an extra step to make good things happen. Every exception that makes sense now create an extra effort. Every meeting that helps align people is a (at least percieved) waste of time for those who were on track all along.

On average, processes might help, and improve things. But on an individual level, they suck. So why do we stick with them?

## Step 5: rationalization

The people affected by processes are usually not the ones who created them. Diets work better if they're from a magazine, sport is more effective if a trainer is in charge, rules of the game come from the instructions. Self-created rules are not effective, and effective rules are not self-created.

This makes it so hard to create _good_ processes.

Software Engineering is obsessed with processes (probably because they work so well for everything non-human). Waterfall, V-Model, Scrum, Kanban, Agile. They all provide processes for large, diverse teams. They accept the fact that a simple todo-list doesn't cut it anymore, and they take the growth as given. And they're well establish. 

It's hard to argue against this logical chain of steps to make a company successful. You _need_ many people, you _need_ to be robust, and humans _are_ diverse. This _requires_ processes, which _will_ suck the life out of those who care.

## Remedies

Some people and companies try different approaches. I don't know if they work.

### New frameworks

Just like Software Engineering moved from Waterfall to Agile and improved a lot with it, some companies actively try to shape their "way of working". My previous employer had an open-to-all comittee for a while that even had decision power, and introduced many wonderful things. But when the company grew, it became _the_ committee to do _anything_ cultural, so every idea had to be brought to the meeting. Changes that weren't blessed by this round were eyed extremely sceptical. At the same time, the meetings were flooded with (in my opinion) non-sensical topics that usually would have dissolved naturally, but now had found an outlet.

It's also no easy to see or calculate how a great culture contributes to a companies' bottom line.

### Shrinking

The —to me— most memorable way to shrink a company was when Basecamp [announced a new direction](https://world.hey.com/jason/changes-at-basecamp-7f32afc5) and [bought out 1/3 of their employees](https://www.platformer.news/p/-how-basecamp-blew-up) in April 2021. But companies have been closing departments forever, trying to reassign some and letting go of others.

Unfortunately, it's difficult to make this measure precise and targeted.

### Tooling

How cliché, I know. But in some cases tooling _does_ help with communication.

Robot vacuums have conquered the world, not because vacuuming is such a hard task, but because it frees couples from the discussions about who's turn it is.

Issue trackers give a way-out to not fix a smell _now_, in _this_ PR, but agree on deferring it.

BYOD (bring your own device) is so popular, because it enables people to _customize_ the part that don't need to be aligned between all employees.

CI/CD (continuous integration, continuous deployment) not only eliminates the "but it works on _my_ machine" problem, but gives _everyone_ some peace of mind — wheter it's a large company or a solo dev.

The point with all of these is not to eliminate communication, but to eliminate _unnecessary_ communication. To make room for the important stuff. 

## Conclusion

Maybe somewhere around Step #2 we can find ways to limit or slow growth. If you can automate tasks, instead of hiring someone for it, the team can stay small. If you find an external service for something instead of building it in-house, you don't need more capacity and expertise. If a company is _aware_ that growth comes at a cost, maybe it can be more open to different solutions. What do you think?