# CLAUDE.md — jannikarndt.de

This file gives Claude context for working on Jannik Arndt's personal website. Read it at the start of any session.

---

## What This Site Is

Personal website and blog for **Jannik Arndt** at https://www.jannikarndt.de. It features:
- Technical blog posts (primarily Scala, iOS/Swift, DevOps — mostly 2016–2022)
- Photography (Hamburg, travel)
- Opinion pieces on software engineering and company culture
- A brief bio/timeline on the About page
- Travel writing (2025 onwards, based in Palermo)

The owner is a former Scala/backend engineer (MOIA, airfocus) who now teaches yoga, builds iOS apps, and does contracting work. Currently based in Hamburg. The site reflects that full arc, which means the content ranges from deeply technical to very personal.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Static site generator | Hugo (version: `latest` in CI) |
| Theme | PaperMod — forked at github.com/JannikArndt/hugo-PaperMod, installed as git submodule |
| Deployment | GitHub Actions → CapRover CLI → Docker/Nginx on jannikarndt.de |
| Container | `nginx:alpine` — serves `/usr/share/nginx/html` on port 80 |
| CapRover config | `captain-definition` (schema v2) in repo root |
| Domain | jannikarndt.de (base URL: `https://www.jannikarndt.de/`) |

**Key config files:**
- `config.yaml` — main Hugo config (base URL, theme, params, social icons, menu)
- `.github/workflows/deploy.yml` — CI/CD pipeline (triggers on push to `master`)
- `Dockerfile` — Docker image definition
- `captain-definition` — CapRover deployment config

**Theme submodule:**
```
git submodule update --init --recursive
```
When cloning, always initialise submodules or the theme won't be present.

---

## Directory Structure

```
/
├── config.yaml                    # Main Hugo config
├── content/
│   ├── about.md                   # About/CV page (custom layout)
│   ├── archive.md                 # Archive listing
│   ├── search.md                  # Search page (Fuse.js)
│   └── blog/
│       └── YYYY/MM/               # Posts organised by year/month
├── layouts/
│   ├── _default/about.html        # Custom about page template
│   ├── 404.html                   # Custom 404 (features Quinn the dog)
│   ├── partials/toc.html          # Sticky ToC for desktop
│   └── shortcodes/filename.html   # Shortcode for code file labels
├── assets/css/extended/
│   ├── custom.css                 # Panorama scroll, video container, figure shadows
│   └── syntax.css                 # Code syntax highlighting overrides
├── static/
│   ├── cv.pdf                     # CV (1MB)
│   ├── jannik.jpg                 # Profile photo
│   ├── jannik_square.jpg          # Square crop for social
│   ├── quinn_digging.mp4          # Used on 404 page
│   ├── favicons/                  # All favicon variants
│   └── opengraphimages/           # Pre-generated OG images
├── themes/PaperMod/               # Theme (git submodule)
├── Dockerfile
└── captain-definition
```

---

## How to Add a New Post

1. Create `content/blog/YYYY/MM/title-slug.md`
2. Add front matter:

```toml
+++
title = "Your Title Here"
date = "YYYY-MM-DDTHH:MM:SS+01:00"
draft = false
tags = [ "Tag1", "Tag2" ]
toc = false

[params]
  author = "Jannik Arndt"
+++

Your content here.
<!--more-->

Rest of post.
```

3. Images: place in the same directory or a subdirectory, reference with relative paths.
4. Preview locally: `hugo serve`
5. Deploy: push to `master` branch. GitHub Actions handles the rest.

**Notes:**
- Older posts use TOML front matter (`+++ ... +++`), newer ones sometimes use YAML (`--- ... ---`). Either works.
- `<!--more-->` sets the summary break for list views.
- `toc = true` enables the sticky table of contents (defined in `layouts/partials/toc.html`).
- `buildDrafts: false` in config — posts with `draft = true` won't appear in production.

---

## Custom Shortcodes

### `filename`
Labels a code block with a filename. Use immediately before a fenced code block.

```
{{< filename title="build.sbt" >}}
```

### `figure` (Hugo built-in)
Embeds an image with styling options.
```
{{< figure src="image.png" width="80%" class="right" >}}
```

### `rawhtml`
Embeds raw HTML. Note: not defined as a shortcode file — relies on Hugo's `unsafe: true` goldmark renderer setting. Use sparingly.

---

## Writing Style Guide

This is the most important section for generating content in Jannik's voice.

### Voice and Personality

Jannik writes conversationally but precisely. He treats the reader as a capable peer, not a student. He doesn't over-explain, but he doesn't skip steps either. His sense of humour is dry and self-aware — he'll mention his own mistakes and laugh at them.

**Characteristic moves:**
- **Short punchy sentences for emphasis**, mixed with longer technical ones.
  > "Neat." / "Yeah, doesn't explain much, does it?" / "We eventually gave up."
- **Self-deprecation about his own choices:**
  > "I went ahead and chose the wrong way [...] I read none of those, but I now know how to use the `--force`"
- **Dry sarcasm for failing tools:**
  > "I cannot believe that googling 'talend does not work' does not find *anything* helpful. With this entry I try to fill that void in the internet."
- **Rhetorical questions immediately answered:**
  > "So, what to make of this? Easy: ..."
- **Italics for emphasis:** `_very_ comprehensive`, `_not_ great`, `_actual_ content`
- **™ for ironic self-description:** `*professional programmer*™`
- **Ends posts abruptly or with a single dry line** — no "In conclusion..." summaries.

### Structure Patterns

- Opens with context or problem statement, not the solution
- Uses `## The catch` for important caveats (sometimes repeated ironically)
- Uses numbered lists for sequences, bullet lists for options
- Code blocks are liberally used; the `filename` shortcode labels them
- Photography posts are mostly visual — one or two sentences of context, then photos
- Opinion posts build an argument step by step, then conclude with a plain statement

### Tone by Post Type

| Post Type | Technical | Personal/Warm | Sarcasm |
|-----------|-----------|---------------|---------|
| Tutorial | High | Low | Low |
| Opinion | Medium | Medium | High |
| Photography | None | High | None |
| Year-review | Low | High | Medium |
| Travel | Low | High | Low |

### What He Doesn't Do

- No hype language ("amazing", "game-changing", "revolutionary")
- No long introductions explaining what he's about to say
- No "In this post we will..." framing
- No hedging on opinions — he states things directly and defends them
- Doesn't pad technical posts with background history of a technology
- Rarely uses emoji (the ones that appear feel spontaneous, not deliberate)

### Vocabulary Patterns

Uses: "neat", "marvellous", "wonderful" (genuine), "let me spare you the details", "the catch", "eventually gave up", "as opposed to"
Avoids: "leverage", "utilize", "seamlessly", "robust", "at the end of the day"

### Example: How He'd Start a Technical Post

Bad (not his style):
> "In this blog post, I will explain how to set up a Raspberry Pi headlessly. This is a common task for developers who want to use their Pi without a monitor. We will cover the following topics: ..."

Good (his style):
> "You buy a Raspberry Pi, you want to use it over SSH from your MacBook. You don't have an HDMI cable anyway. Here's how."

### Example: How He'd Write an Opinion

Bad:
> "There are many perspectives on company growth. In this post I will explore several viewpoints..."

Good:
> "Growth is celebrated. More users, more revenue, more headcount. What nobody tells you is what it does to the people who were there first."

---

## Persona Analysis

Understanding who reads the site and what they need.

### Head Hunter / Recruiter
**What they see:** Clean career timeline on `/about`, strong Scala/AWS/product background, Chapter Lead at MOIA, iOS development.
**What worries them:** Abrupt exit from employment in 2024. "iOS Apps, Yoga & Travel" as the current entry. No recent technical posts. The "Why growth is so bad" (2022) post could read as a disgruntled employee.
**What they need:** The about page to frame the career transition as intentional, not a burnout exit. The tagline should reflect current reality without sounding unemployable.
**Verdict:** Impressive track record undermined by unclear current positioning.

### Colleague / Fellow Developer
**What they find:** Genuine, practical technical content. Real-world stance ("we eventually gave up on Pentaho"). Deep dives into Scala internals, event sourcing, git. No hand-wavy tutorials.
**Issues:** Most posts are 2017–2021. Several are now factually wrong (Heroku free tier gone, Apple-native Charts exist). Visitors should know posts are time-stamped opinions, not maintained docs.
**Verdict:** Great reference site for JVM/Scala patterns. Would benefit from a note that tutorials reflect the time they were written.

### Yoga Student
**What they find:** Almost nothing. One mention of yogawithjannik.com in the homepage bio.
**What they need:** Either yoga content here, or a clear signpost to yogawithjannik.com.
**Verdict:** Wrong site. Should be redirected immediately. The yoga audience is completely unserved here.

### Parents / Family
**What they find:** A readable, personal site. The 2025 Palermo posts are warm and accessible. The about timeline tells the life story clearly. Hamburg photography is nice.
**Issues:** Most of the blog is impenetrable to non-technical readers.
**Verdict:** The recent travel posts work perfectly for this audience. They scroll the archive, see Hamburg, see Palermo, feel updated.

### Journalist / Profile Writer
**What they find:** Strong quotes, unusual arc (musicology + CS → big data → yoga teacher), opinionated takes. "Two-Speed IT" and "Why growth is so bad" are publishable perspectives.
**Issues:** The homepage tagline doesn't match 2025 reality. No clear narrative about who Jannik is *now*. Is this a tech blog? A portfolio? A travel diary?
**Verdict:** Interesting subject, but the site needs a clearer "this is who I am today" statement to support a profile.

### Admirer (fan of the writing)
**What they find:** A distinctive voice. Opinionated but self-aware. Technical depth without gatekeeping. The 2021–2022 posts are the strongest.
**Issues:** Long gap between mid-2022 and 2025. Travel posts are enjoyable but lighter than the tech/opinion essays. Wants more.
**Verdict:** Come back for the "Lessons Learned" format. The voice is strong enough to carry any topic.

### Hater / Critic
**Lines of attack:** "He left real engineering to do yoga in Sicily." "His Heroku tutorial is dangerously wrong now." "He thinks he knows why companies fail but he's never run one." "He teaches people how to spoof git commits."
**Counter:** All posts are clearly dated. The site is a learning log, not a manual. The April Fools git post has unambiguous satirical context.
**Verdict:** The opinion posts invite pushback — that's fine. The main real vulnerability is outdated tutorials being found by search without clear deprecation notices.

### iOS App User (Zettl, future apps)
**What they find:** A link to zettl.jannikarndt.de from the about page. Almost no iOS content on the main site.
**What they need:** An apps section if iOS becomes a business.
**Verdict:** Under-represented. Worth addressing if the iOS work grows.

---

## Issues Register

Things that are known to be outdated, wrong, or worth addressing. Work through these in future sessions.

### High Priority — Config / Meta

| # | Issue | File | Line |
|---|-------|------|------|
| 1 | ~~Tagline updated to "Software Engineer, Yoga Teacher, Life Enthusiast"~~ ✓ done | `config.yaml` | 47, 86 |
| 2 | ~~Twitter icon updated to X, URL updated to x.com~~ ✓ done | `config.yaml` | 89–91 |
| 3 | ~~Xing reinstated~~ ✓ done (still relevant in Germany) | `config.yaml` | 95–97 |
| 4 | CV PDF at `/cv.pdf` — verify it reflects current status (last updated?) | `static/cv.pdf` | — |

### Medium Priority — Outdated Technical Posts

| # | Post | Issue |
|---|------|-------|
| 5 | ~~Disclaimer added~~ ✓ done | `2016/11/The_2016-Personal-Website_Infrastructure.md` | |
| 6 | ~~Disclaimer added~~ ✓ done | `2018/10/Akka HTTP on Heroku.md` | |
| 7 | ~~Disclaimer added~~ ✓ done | `2018/01/How to install Tasmota on a Sonoff device without opening it.md` | |
| 8 | ~~Disclaimer added~~ ✓ done | `2018/01/How to use a Raspberry Pi 3 with Apple Home.md` | |
| 9 | ~~Disclaimer added~~ ✓ done | `2021/08/Comparing Charts in SwiftUI.md` | |

### Lower Priority — Opinion Posts to Review

| # | Post | Consideration |
|---|------|---------------|
| 10 | `2022/02/Why growth is so bad.md` | Kept as-is. Still reflects current thinking. |
| 11 | ~~`2017/05/Two Speed IT.md`~~ ✓ deleted | |
| 11b | ~~`2017/01/talend_does_not_work.md`~~ ✓ deleted | |
| 12 | `2021/04/April Fools- We rewrote it in Rust.md` | Detailed git commit forgery instructions. Educational/satirical intent is clear in context, but the instructions are complete enough to be misused out of context. |

### Technical Issues

| # | Issue | File |
|---|-------|------|
| 13 | `rawhtml` shortcode used in SwiftUI charts post but not defined in `layouts/shortcodes/` | `2021/08/Comparing Charts in SwiftUI.md` |
| 14 | 404 page video `quinn_digging.mp4` — verify path is served correctly | `layouts/404.html` |
| 15 | Minification disabled in config (`minifyOutput: false`) — consider enabling | `config.yaml` |

### Content Gaps / Opportunities

| # | Opportunity |
|---|------------|
| 16 | No post explaining current infrastructure (CapRover + Docker + GitHub Actions). The 2016 post is what search finds. |
| 17 | No yoga content on the main site despite it being half the current identity. |
| 18 | No iOS app showcase despite it being the stated career focus. |
| 19 | "Lessons Learned" annual series stopped after 2017 — these were among the strongest posts. |
| 20 | ~~About page updated: contractor work (NDA), iOS apps in development, back in Hamburg~~ ✓ done |

---

## Social Links Reference

Current state in `config.yaml`:

| Platform | URL | Status |
|----------|-----|--------|
| X (Twitter) | https://x.com/JannikArndt | Active |
| GitHub | https://github.com/JannikArndt | Active |
| LinkedIn | https://www.linkedin.com/in/jannikarndt | Active |
| Xing | https://www.xing.com/profile/Jannik_Arndt | Active (relevant in Germany) |
| Email | mailto:jannik@jannikarndt.de | Active |
| CV | /cv.pdf | Check if current |

---

## Deployment Notes

Pushes to `master` trigger the GitHub Actions workflow (`.github/workflows/deploy.yml`):
1. Checkout with submodules (`submodules: true` in checkout action)
2. Hugo build: `hugo --minify`
3. Node.js 20 setup
4. CapRover CLI install + deploy (uses secrets: `CAPROVER_SERVER`, `CAPROVER_PASSWORD`, `CAPROVER_APP`)

**Local dev:**
```bash
git submodule update --init --recursive
hugo serve
```
The site runs at http://localhost:1313.

**Branch policy:** Develop on feature branches. Merge to `master` to deploy.

---

## Open Graph Images

Pre-generated OG images live in `static/opengraphimages/`. They were generated with a fork of `tcardgen` (a Go CLI tool). The fork is at github.com/JannikArndt/tcardgen. The generation process is documented in the post `2021/05/Generating Open Graph Images for my Blog.md`.

---

## About Page Notes

`content/about.md` uses a custom layout (`layouts/_default/about.html`). It's a timeline table with HTML inside markdown (goldmark `unsafe: true` enabled). When editing, be careful with the HTML table syntax — it's fragile. Test with `hugo serve` before pushing.

---

## Known Good Patterns

**Post with sidebar ToC:**
```toml
toc = true
```

**Photography post (minimal text, images carry it):**
```toml
tags = [ "Photography", "Hamburg" ]
```
Then a one-line intro and `{{< figure >}}` shortcodes or markdown images.

**Code post with labeled files:**
```
{{< filename title="Main.scala" >}}
` ` `scala
// code here
` ` `
```

**Panorama image (triggers horizontal scroll on mobile):**
Add class `panorama` to the image — handled by `custom.css`.
