---
title: "Generating Open Graph Images for my Blog"
date: "2021-05-02T14:00:00+01:00"
author: "Jannik Arndt"
keywords: [ "Blog", "Open Graph" ]
tags: [ "blog", "hugo", "website" ]
slug: "generating_open_graph_images"
toc: false
showToc: false
TocOpen: true
draft: false
comments: false
images:
- "opengraphimages/Generating Open Graph Images for my Blog.png"

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

After about 50 executions, 3h hours of tweaking and ending up with [my own fork](https://github.com/JannikArndt/tcardgen), I finally made _something_ work.

### Final structure

The command I run (after `go install` on my fork) is

```shell
tcardgen -f opengraph/font -c opengraph/template.config.yaml -o static/opengraphimages content/blog/2021/05/Generating\ Open\ Graph\ Images\ for\ my\ Blog.md
```

This requires the following files:

```
opengraph/
├── font
│   ├── My-favorite-font-Bold.ttf
│   ├── My-favorite-font-Medium.ttf
│   └── My-favorite-font-Regular.ttf
├── template.config.yaml
└── template.png
```

The config I use is

```yaml
template: opengraph/template.png
title:
  start:
    px: 100
    py: 172
  fgHexColor: "#7B8EA6"
  fontSize: 72
  fontStyle: Bold
  maxWidth: 700
  lineSpacing: 10
info:
  start:
    px: 100
    py: 120
  fgHexColor: "#A0A0A0"
  fontSize: 38
  fontStyle: Regular
  separator: " — "
tags:
  start:
    px: 120
    py: -475
```

I don't use categories, I _do_ use tags, but I don't want them, so I move them off the canvas.

The image I use looks like this:

{{< figure src="/blog/2021/05/opengraphimages/template.png" >}}

I _really_ bothers me that the template can be defined in the `template.config.yaml`, but the font-folder cannot. But I didn't find an easy way to add it, because I'm not a big fan of messing with `go` code.

Running the command creates an image in `static/opengraphimages`, which `hugo` automatically copies over to the output (`public`) folder.

Setting

```yaml
images:
- "opengraphimages/Generating Open Graph Images for my Blog.png"
```

in my front-matter adds the link to my page. 

### Next Steps

This workflow still requires running the waaaaayyyy too long command for every new post, and manually copying filenames. I would much rather

* have `hugo` generate the image automagically 🧙
* have `hugo` trigger another step which calls this ⏭
* have a service that _dynamically_ generates the image 🧑‍🎨
* use `svg` as `og:image` ✨ ([you can define a mime-type](https://ogp.me/#structured), but [this StackOverflow entry from 2014](https://stackoverflow.com/questions/21636503/use-svg-as-ogimage) says svg is not allowed)