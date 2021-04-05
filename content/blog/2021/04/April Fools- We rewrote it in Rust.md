---
title: "April Fools': “We rewrote it in Rust” or How To Fake A GitHub Repo"
date: "2021-04-05T02:00:00+01:00"
author: "Jannik Arndt"
keywords: [ "Git", "GitHub" ]
tags: [ "Git" ]
slug: "how_to_fake_a_github_repo"
showToc: false
TocOpen: true
draft: false
comments: false
---


We recently had another team rewrite their service in Rust, with a massive boost in performance. So naturally, for April Fools' I made a big announcement that _our_ team followed suit:

![rust_1.png](/blog/2021/04/rust/slack1.png)

But, at _good_ prank isn't just "I thought this was true, but it wasn't". It's "I though it was a joke, but for a brief moment doubted that". The "Oh, no, he _didn't_"-moment.

Alas, one more line was necessary:

![1617575296.png](/blog/2021/04/rust/slack2.png)

The proof. With a link. A Call-To-Action. Click it! Marvel at it!

## Creating fake commits

Creating a GitHub repo that looks like Rust isn't hard. You can look at a few open-source projects and copy what you need (respecting the license, of course).

That gives you the language-overview:

{{< figure src="/blog/2021/04/rust/languages.png" alt="languages overview" width="40%" >}}

And a proper `Cargo.yaml`, prominently featuring dependencies that seem to make sense:

![the cargo.yaml](/blog/2021/04/rust/cargo.png)

I committed using the `--date` flag:

```shell
$ git commit -a -m "Initial template & infra for booking3" \
--date="7 days ago at 08:46" 
```

and checked the log:

```shell
$ git log                                                                               
commit 983e4977983ee134771885f6c08881513c4faef1 (HEAD -> main)
Author: Jannik Arndt <jannik@jannikarndt.de>
Date:   Mon Mar 22 08:46:00 2021 +0100

    Initial template & infra for booking3
```

Looks good. For a preview, I created a repo in my personal account and pushed it:

```shell
$ git remote add origin https://github.com/JannikArndt/booking3.git
$ git push --set-upstream origin main
```


{{< figure src="/blog/2021/04/rust/firstpush.png" >}}

TWO MINUTES AGO? How could that be?!

`git` has different formats for the log: `oneline`, `short`, `medium`, `full`, `fuller`, `reference`, `email` and `raw`. The default is `medium`.

Only the `fuller` format shows the whole truth:

```shell
$ git log --pretty=fuller
commit 983e4977983ee134771885f6c08881513c4faef1 (HEAD -> main, origin/main)
Author:     Jannik Arndt <jannik@jannikarndt.de>
AuthorDate: Mon Mar 22 08:46:00 2021 +0100
Commit:     Jannik Arndt <jannik@jannikarndt.de>
CommitDate: Tue Mar 30 22:47:39 2021 +0200

    Initial template & infra for booking3
```

There's an `AuthorDate` and a `CommitDate`!

Okay, let's try again. 

## Faking AuthorDate _and_ CommitDate

A quick googling later I arrived at

```shell
$ GIT_COMMITTER_DATE="2021-03-20T11:43:11" \
git commit -a -m "Initial template & infra for booking3" \
--date="2021-03-20T11:43:11"
```

Force-push aaaannd


{{< figure src="/blog/2021/04/rust/secondpush.png" >}}

Nice 👍 

## Faking the Author — and Committer

Next I needed commits from the whole team to make this look realistic. Following the `ENV`-vars:

```shell
$ GIT_COMMITTER_DATE="2021-03-23T11:43:11" \
GIT_COMMITTER_NAME="Cristina" \
GIT_COMMITTER_EMAIL="cristina@moia.io" \
git commit -a -m "Change deployment to booking3" --date="2021-03-23T11:43:11"
```

Of course _not_. 

{{< figure src="/blog/2021/04/rust/coauthor.png" >}}

GitHub _does_ make a difference between the author and the committer. So to fully fake someone else's commit:

```shell
$ GIT_COMMITTER_DATE="2021-03-23T11:43:11" \
GIT_COMMITTER_NAME="Cristina" \
GIT_COMMITTER_EMAIL="cristina@moia.io" \
git commit -a -m "Change deployment to booking3" --date="2021-03-23T11:43:11" \
--author="Cristina <cristina@moia.io>"
```

It worked 😎

Since I had a few commits left to do and I don't enjoy typing, I refactored my command a little:

```shell
$ DATE="2021-03-23T11:43:11"; \
NAME="Cristina"; \
MAIL=cristina@moia.io; \
GIT_COMMITTER_DATE=$DATE GIT_COMMITTER_NAME=$NAME GIT_COMMITTER_EMAIL=$MAIL \
git commit --author="$NAME <$MAIL>" --date=$DATE -m "<the message>"
```

## Fine-Tuning

I also tried `--allow-empty`, and while the messages appear in the history, they _don't_ change the appearance on the first view, since they don't touch any files. Obviously.

I also tried to balance the amount of lines to generate a more realistic "Pulse" in the "Insights" section:

{{< figure src="/blog/2021/04/rust/insights.png" >}}


(I still remembered from when I found the _other_ teams Rust-repo that I looked at this to find out who was leading this effort.)

Next I needed the green little checkmark to fabricate a successful CI/CD:

{{< figure src="/blog/2021/04/rust/cicd.png" >}}


It hurts a little to spin up a fresh Ubuntu just for a green checkmark, but I didn't find a quicker way:

```yaml
name: deployment

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-20.04
    steps:
      - run: echo "April Fools!"
```

I also thought about creating and merging PRs, but those are way harder to forcibly overwrite (and I don't know the GitHub API well enough to automate that on the spot).

## Result

After about two hours of hacking, I was satisfied.

![the finished result](/blog/2021/04/rust/finished.png)

The reactions were rewarding: People dug into the code, found, commented on and appreciated all the details and even opened new Pull-Requests.

However, one thing nobody noticed…

## Learnings

After figuring out _how_, creating fake commits for my co-workers turned out surprisingly easy. Or for anyone else, for that matter:

{{< figure src="/blog/2021/04/rust/linus.png" alt="Fake Commit by Linus" >}}

That's not great. What you can do about it is _verified_ commits. Since we use the "Squash and merge" button, all commits on master are done through the GitHub UI and therefore verified by our logins:

{{< figure src="/blog/2021/04/rust/verified.png" >}}


To also have this for commits you create locally, you can sign commits via GPG

```shell
$ git config --global commit.gpgsign true
```

and [tell GitHub what your public key is](https://docs.github.com/en/github/authenticating-to-github/signing-commits).

{{< figure src="/blog/2021/04/rust/signed.png" >}}

