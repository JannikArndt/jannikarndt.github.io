---
title: "Generating Open Graph Images for my Blog"
date: "2021-05-02T14:00:00+01:00"
author: "Jannik Arndt"
keywords: [ "Blog", "Open Graph" ]
tags: [ "Programming" ]
slug: "generating_open_graph_images"
toc: false
showToc: false
TocOpen: true
draft: false
comments: false
---

<!--more-->

On a recent Google stroll, I found an _image_ about a GitHub repository:

{{< figure src="/blog/2021/05/opengraphimages/googlesearch.png" >}}

Neat, where does that come from?

{{< figure src="/blog/2021/05/opengraphimages/githubcode.png" >}}

Neat, it's generating them! Of course, there's a [blog post about it](https://github.blog/2019-04-17-custom-open-graph-images-for-repositories/).
And you can preview sites on [https://www.opengraph.xyz/](https://www.opengraph.xyz/url/https:%2F%2Fgithub.com%2Fbobbyconti%2FContacts-SwiftUI/):

{{< figure src="/blog/2021/05/opengraphimages/preview.png" >}}

To be honest: I have been bothered with see my _face_ whenever I share a blog post in Slack:

{{< figure src="/blog/2021/05/opengraphimages/slackpreview.png" >}}

So question: How do I generated them myself?

### Checking out `tcardgen`

A quick googeling later, I found https://github.com/Ladicle/tcardgen

{{< figure src="/blog/2021/05/opengraphimages/tcardgenpreview.png" >}}

```shell
go get github.com/Ladicle/tcardgen
```

A great, downloading half the internet again… 😅 

