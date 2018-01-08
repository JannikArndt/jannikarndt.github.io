+++
title = "Best Reads of 2017"
draft = true
date = "2018-01-04T19:00:00+01:00"
keywords = [ "Programming", "Hacker News" ]
slug = "best_reads_of_2017"
toc = true

[params]
  author = "Jannik Arndt"
+++

In October 2016 I started reading [Hackernews](https://news.ycombinator.com/best) via the wonderful [Newsify](https://newsify.co) app. Everytime an article seemed worthy to remember and come back to, I starred it.

Now since 2017 has passed the time has come to revisit the list of starred items, re-evaluate them and create a “Best of 2017”.

<!--more-->

## Non-Tech

### “That Time I Turned a Routine Traffic Ticket into the Constitutional Trial of the Century”

* <http://www.thepublicdiscourse.com/2017/01/18093/>
* <https://news.ycombinator.com/item?id=13397145>

A wonderful text from a professor of the law about going to court because of a speeding ticket:

> In short, municipal officials and their private contractors have at their disposal the powers of both criminal and civil law and are excused from the due process duties of both criminal and civil law.

I took away from this not to follow something _everyone believes is the law_, but to actually ask twice.

---

### The story of when Dole Food had too many shares

* <https://www.bloomberg.com/view/articles/2017-02-17/dole-food-had-too-many-shares>
* <https://news.ycombinator.com/item?id=13669315>

---

### This Is What Happens to Your Body on a Thru-Hike

* <https://www.outsideonline.com/2125031/what-happens-your-body-thru-hike>
* <https://news.ycombinator.com/item?id=13710144>

This guy hiked 8 hours a day for 29 days, reducing his body fat from 13% to 5%.

---

### A 3D-printed House

* <http://apis-cor.com/en/about/news/first-house>
* <https://news.ycombinator.com/item?id=13798130>

---

### How to survive falling from an exploding Aircraft

* <http://www.greenharbor.com/fffolder/carkeet.html>
* <https://news.ycombinator.com/item?id=13839177>












## Explanations & Tech for Non-Techies

### Amazon Web Services in Plain English

* <https://www.expeditedssl.com/aws-in-plain-english>
* <https://news.ycombinator.com/item?id=13442022>

Because IAM. And there is [an Azure version](https://www.expeditedssl.com/azure-in-plain-english) as well.

---

### Blockchain Demo

* <https://anders.com/blockchain/>
* <https://news.ycombinator.com/item?id=13566951>

The best way to understand the idea of a blockchain.










## Tech

### Graphviz in the Browser

* <http://viz-js.com>
* <https://news.ycombinator.com/item?id=13333210>

Most useful for

```shell
$ terraform graph | pbcopy
```

or with [`sbt dependencyDot`](https://github.com/jrudolph/sbt-dependency-graph).

A HN user created a webservice in the spirit of “Graphviz as a service”, so you can do this:

```shell
$ open https://graphviz.gomix.me/graphviz\?layout\=dot\&format\=svg\&mode\=download\&graph\="$(terraform graph)"
```

---

### Script to make Windows 10 usable

* <https://gist.github.com/alirobe/7f3b34ad89a159e6daa1>
* <https://news.ycombinator.com/item?id=13344318>

Fortunately, I didn't touch a Windows machine all year :)

---


### Mastering Bash and Terminal

* <https://www.blockloop.io/mastering-bash-and-terminal/>
* <https://news.ycombinator.com/item?id=13400350>

Although I, of course, use [oh my zsh](http://ohmyz.sh) and have converted several others over the past year.

---

### Naughty Strings: A list of strings likely to cause issues as user-input data

* <https://github.com/minimaxir/big-list-of-naughty-strings>
* <https://news.ycombinator.com/item?id=13406119>

I should use this way more often…

---



### Redash – Connect to any data source, easily visualize and share your data

* <https://github.com/getredash/redash>
* <https://news.ycombinator.com/item?id=13597068>

I should definitely take another look at this.

---

### Martin Fowler: What do you mean by “Event-Driven”?

* <https://martinfowler.com/articles/201701-event-driven.html>
* <https://news.ycombinator.com/item?id=13593683>

Martin Fowler on the differences between Event Notification, Event-Carried State Transfer, Event-Sourcing and CQRS.

---

### Postmortem of GitLab's database outage of January 31

* <https://about.gitlab.com/2017/02/10/postmortem-of-database-outage-of-january-31/>
* <https://news.ycombinator.com/item?id=13619714>

What I like most:

> ky738: <br> RIP the engineer <br>

> > YorickPeterse: <br>
> > Still here, and doing just fine.

---

### Tracking users between different browsers

* <https://arstechnica.com/information-technology/2017/02/now-sites-can-fingerprint-you-online-even-when-you-use-multiple-browsers/>

---

### “remove password” commits on GitHub

* <https://github.com/search?utf8=✓&q=remove+password&type=Commits&ref=searchresults>
* <https://news.ycombinator.com/item?id=13650818>

Take-aways:

* A lot of people publish passwords.
  * => There are tools to prevent this, for example [talisman](https://github.com/thoughtworks/talisman/blob/master/README.md).
* Removing a password is not that hard, GitHub has a very good [explanation](https://help.github.com/articles/removing-sensitive-data-from-a-repository/).
* Many people still don't understand version control. It's our job to teach them.

---

### macOS command line commands

* <https://github.com/herrbischoff/awesome-osx-command-line>
* <https://news.ycombinator.com/item?id=13665593>

I probably use `open .` the most, because sometimes the Finder is just cleaner.

---

### How Wi-Fi works and why it sometimes doesn't

* <https://arstechnica.com/information-technology/2017/03/802-eleventy-what-a-deep-dive-into-why-wi-fi-kind-of-sucks/>
* <https://news.ycombinator.com/item?id=13790871>

---

### Writing good code: how to reduce the cognitive load of your code

* <https://chrismm.com/blog/writing-good-code-reduce-the-cognitive-load/?2>
* <https://news.ycombinator.com/item?id=13813774>

---

### pi-hole: Network-wide ad blocking

* <https://pi-hole.net>
* <https://news.ycombinator.com/item?id=13857887>

or the cloud-hosted alternative: <http://gomez.wtf/set-up-a-cheap-cloud-hosted-adblocker-in-an-hour-for-2-50-a-month/>