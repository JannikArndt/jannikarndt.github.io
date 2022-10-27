---
title: "Finding yourself on the Safe Browsing List — a Post Mortem"
date: "2022-08-05T11:30:00+02:00"
author: "Jannik Arndt"
keywords: [ "Blog", "Post Mortem", "Safe Browsing List" ]
tags: [ ]
slug: "safe_browsing_list"
toc: false
draft: false
comments: false
---

This week we woke up to customer reports that they couldn't reach their "Public Portal" (a way to share their roadmap) anymore. Instead, a red page with a huge warning told them "Deceptive site ahead". What had happened?

<!--more-->

Portal is a feature where customers can share their product roadmap, collect user feedback and link to other websites. These are hosted under a subdomain such as [https://airfocusportal.airfocus.site/](https://airfocusportal.airfocus.site/). Crucially, if the _only_ thing configured was a link, we would redirect to that directly.

<img src="/blog/2022/08/1659688767.png" alt="">

This was abused by someone who —in a trial— created such a redirect to a phishing site. We hadn't noticed it, but Google did. Which means the domain —first the subdomain, then the whole second-level-domain— gets added to the Safe Browsing list, which is used by all major browsers, effectively removing you from the internet.

Since this block is done by the browser, our uptime-monitoring did not catch it. There would have been a warning in the Google Search Console, from where it slowly made its way from our SEO and Marketing department towards the product team (as in "Any idea what this warning could be?"), but too slow.

At least in one regard we were lucky (or clever): Our main product is running on https://www.airfocus.com, a separate domain. This kept the blast radius low.

## Fixing and Hoping

Jumping from one "Learn more" to the next, we found the warning with the offending sub-domain in the Search Console. We quickly removed the entry and deactivated the feature. And now?
Google offers a button to request a review if you removed all problems — but what exactly does that do? Having read too many stories about automated moderation making horrible decision, we double- and triple checked that no other entry would redirect to something nefarious, before we risk a second strike.
Then we clicked and waited. And hoped. 2:20 hours later, our site was back.

## Learnings

In the 5 months I work at airfocus, we have never compromised on security. But abusing our service for something completely unrelated just wasn't on anyones radar. Apart from fixing the issue and re-evaluating every functionality, we also wanted to make sure to include this in our monitoring.
Fortunately, Google [provides a free API](https://developers.google.com/safe-browsing/v4/lookup-api) to check your sites against. Using that, we built a Kubernetes tool that automatically fetches all available ingresses, checks them against the API and adds a Prometheus metric and alert if a match is found: https://github.com/airfocusio/kube-google-safebrowsing 

## Bonus Surprise

In the process we also discovered that Google Mail will straight _reject_ any e-mail that contains a link to a site on the Safe Browsing list. That totally makes sense, but it also means that any customer-mail that would inform us about their portal being blocked would never even reach us, if it contained a link to the site. The internet works in surprising ways.

