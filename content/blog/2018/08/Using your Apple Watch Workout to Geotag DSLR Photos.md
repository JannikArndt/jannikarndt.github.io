+++
title = "Using your Apple Watch Workout to Geotag DSLR Photos"
draft = false
date = "2018-08-05T16:00:00+01:00"
keywords = [ "Apple", "Apple Watch", "Outdoor Walk", "Geotag", "GPS", "Route", "Photography", "exiftool" ]
slug = "using_your_apple_watch_workout_to_geotag_dslr_photos"

[params]
  author = "Jannik Arndt"
+++

I want my photos to have location info in them, and Nikon wants _way too much_ money for that. So I'll do this: Let my Apple Watch track where I go, using the _Outdoor Walk_, export the route as GPX and use _exiftool_ to tag all my images. Here's how I do that.

<!--more-->

## Export GPX

Apples apps don't come with an export option, so I use the wonderful little app called [RunGap](http://www.rungap.com). An in-app-purchase for 2.29€ allows my to export a GPX file of my workout:

<p>
<a href="/blog/2018/08/RunGap1.png"><img src="/blog/2018/08/RunGap1.png" alt="" width="45%"></a>
<a href="/blog/2018/08/RunGap2.png"><img src="/blog/2018/08/RunGap2.png" alt="" width="45%"></a>
</p>

There's also a great website that let's you analyse the contents of that file:

<a href="https://www.j-berkemeier.de/ShowGPX.html" target="_blank"><img src="/blog/2018/08/ShowGPX.png" alt=""></a>

## Write GPS into EXIF

Next, I use _the_ software to edit EXIF data, written in Perl, first published in 2003, still state of the art today: [_exiftool_](http://owl.phy.queensu.ca/~phil/exiftool/). You can install it via

```bash
brew install exiftool
```

(on a mac, of course).

Then the command is pretty straightforward:

```bash
➜ ~ exiftool -geotag=myRoute.gpx ~/Pictures/UntaggedPictures/
    1 directories scanned
   83 image files updated
```

…and it's done!

The _exiftool_ can do _way_ more, by the way, they have a [page dedicated just for geotagging](https://www.sno.phy.queensu.ca/~phil/exiftool/geotag.html). But for starters, this does the job pretty well!