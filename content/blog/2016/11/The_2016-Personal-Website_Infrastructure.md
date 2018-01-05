+++
title = "The 2016-Personal-Website Infrastructure"
draft = false
date = "2016-11-20T13:37:00+01:00"
keywords = [ "Web", "Hugo" ]
slug = "The_2016-Personal-Website_Infrastructure"
toc = true

[params]
  author = "Jannik Arndt"
+++

Since I bought my personal domain name around 2003, I went through several web-solutions, 
using static html pages, php pages, a custom designed php cms, finally Wordpress and now, as of yesterday, I am back to static html. The 2016-flavour however, which is another attempt of separation of presentation and content (a concept I highly endorse as a LaTeX user).
<!--more-->

My main reason was though, that I was spending more time updating Wordpress, its plugins and themes than acutal content.

Since quite a lot of research, trial-and-error and configuration have lead to the current model, in this post I will share the details with anyone willing to upgrade her website to a 2016-system (with only one and a half months left).

## From plain text to html

The basis is a bunch of `markdown`-files, `go`-templates and the [hugo](http://gohugo.io/)-templating engine. I have tried and failed hugo before, in October, because there was [no easy way](https://gohugo.io/templates/debugging/) to debug anything, and my preferred way of learning is through debugging, as opposed to reading the [docs](https://gohugo.io/templates/go-templates/). My inability to take any given template as it is makes it worse.

This time however I found a [template](http://themes.gohugo.io/theme/creative/) I was quite pleased with. The starting point is the following directory-structure:

``` none
master
├─ content (empty)
├─ public (where the results are generated into)
├─ static 
|  ├─ favicons (for iOS, Android and MS)
|  ├─ img 
|  |  └─ header.jpg
|  └─ favicon.ico
├─ themes
|  └─ hugo-creative-theme (git clone git@github.com:digitalcraftsman/hugo-creative-theme.git)
|     ├─ layouts (where to go-magic happens)
|     |  ├─ partials (layout of individual sections)
|     |  |  └─ ...
|     |  └─ index.html (coarse structure)
|     └─ static (for css, js, etc)
└─ config.toml (acutal content)
```

I fought long and hard to press my content into to `config.toml`, I'll spare you the details and refere to the [actual file](https://github.com/JannikArndt/jannikarndt.github.io/blob/source/config.toml). What I really like is being able to create a custom structure for each content element, for example a software reference consist of

``` toml
[[params.services.list]]
    icon = "http://jannikarndt.github.io/Canal/bridge.png"
    title = "Canal"
    description = "A free and open-source COBOL editor and analysis tool"
    link = "http://jannikarndt.github.io/Canal/"
```

whereas a publication looks like this:

``` toml
[[params.publications.years.entry]]
    text = "Jannik Arndt: “Musicista — A Framework for Computational Musicology”. Masterarbeit, 2014."
    link = "http://www.jannikarndt.de/publikationen/musicista/"
```

All software entries are displayed via the following [template](https://github.com/JannikArndt/jannikarndt.github.io/blob/source/themes/hugo-creative-theme/layouts/partials/services.html)

```html
<div class="row">
    {{ range .Site.Params.services.list }}
    <a href="{{ .link }}" target="_blank">
        <div class="col-lg-3 col-md-6 text-center">
            <div class="service-box">
                <img src="{{ .icon }}" width="50%" />
                <h3>{{ .title }}</h3>
                {{ with .description }}
                    <p class="text-muted">{{ . }}</p>
                {{ end }}
            </div>
        </div>
    </a>
    {{ end }}
</div>
```

while [publications](https://github.com/JannikArndt/jannikarndt.github.io/blob/source/themes/hugo-creative-theme/layouts/partials/publications.html) use

```html
<div class="row">
    {{ range .Site.Params.publications.years }}
    <div class="col-lg-10">
    <h2>{{ .year }}</h2>
        {{ range .entry }}
                <p class="text-muted">
                    {{ .text | markdownify  }}
                    {{ if .link }}
                        <a href="{{ .link }}"><i class="fa fa-external-link"></i></a>
                    {{ end }}
                </p>
        {{ end }}
    </div>
    {{ end }}
</div>
```

The hugo-engine itselft supports my trial-and-error-approach wonderfully by offering the `hugo serve` command, which creates a webserver and updates the generated pages instantly if anything changes.

## Deployment (1)

I have gathered a little experience with hugo deployment on [github pages](https://pages.github.com) while working on [NiceToKnowIT](http://nicetoknow.github.io/IT/), and there is also an [extensive guide](https://gohugo.io/tutorials/github-pages-blog/) on the hugo site. The problem is

1. github pages requires the content at the root of a repository
2. hugo creates the content into the `public` folder
3. both are non-negotiable

The workaround is to “embed” the gh-pages repository (or branch) in the `public` folder of the source repository. Apparently there are [two ways](http://stackoverflow.com/questions/31769820/differences-between-git-submodule-and-subtree) to do this, `submodule` and `subtree`. I went ahead and chose the wrong way ([1](https://blogs.atlassian.com/2013/05/alternatives-to-git-submodule-git-subtree/), [2](https://codingkilledthecat.wordpress.com/2012/04/28/why-your-company-shouldnt-use-git-submodules/), [3](https://ayende.com/blog/4746/the-problem-with-git-submodules), [4](http://somethingsinistral.net/blog/git-submodules-are-probably-not-the-answer/), [5](http://slopjong.de/2013/06/04/git-why-submodules-are-evil/), I read none of those, but I now know how to use the `--force`): `submodule`. The steps are easy:

- delete `public` folder
- `git submodule add -b master git@github.com:JannikArndt/jannikarndt.github.io.git public``
- `add`, `commit`, `push`
- `cd` into `public`
- `add`, `commit`, `push`
- if it worked: never touch a running system. else: use the `--force`.

`subtree` is on my todo list, promise.

If everything worked you now have

- a repository with two branches:
    - `source` for the complete thing
    - `master` for the generated website (`master` for the account-pages, `gh-pages` for repository pages)
- a website at https://jannikarndt.github.io

## Deployment (2)

The next step is to combine the website with my url. My first approach was `RedirectMatch` in the `.htaccess` file:

``` apache
RedirectMatch 301 ^/$ https://jannikarndt.github.io
```

The idea: I still want to access the old wordpress and a file static files such as papers.
The problem: This matches `www.jannikarndt.de/` but not `www.jannikarndt.de`. Yep. The slash __does__ make a difference.

While experimenting with my `.htaccess` file I also developed an aversion against paying for a domain and then only redirecting it. But, as the *professional programmer*&trade; I am I __really__ don't want redundancy, except if automatically generated from a single source. So I decided to dive into uncharted waters and set up a deployment service. (I know, as opposed to starting an FTP client…)

Github offers several [integrations](https://github.com/integrations), one of which is [DeployHQ](https://www.deployhq.com). They offer 10 builds a day for free, which, for now, should suffice, a *very* clean and easy-to-use website and a *hook*, which triggers deployment after every push. 

Marvellous! Now I can leave a new version of my website with a single blog entry to rot until the next big thing (IoT + machine learning = personal website?) comes along.