+++
title = "talend does not work"
draft = false
date = "2017-01-07T11:20:00+01:00"
keywords = [ "Data Engineering", "talend" ]
tags = [ "Programming" ]
slug = "talend_does_not_work"

[params]
  author = "Jannik Arndt"
+++

I cannot believe that googleing “talend does not work” does not find *anything* helpful. With this entry I try to fill that void in the internet.
<!--more-->

## Fail 1: Download

You can download `talend` on their [website](https://info.talend.com/prodevaltedi.html) — except you can't. After filling out all the information (pro-tip: store them in LastPass to insert them the next couple of times) you have to accept the terms of use—except you can't!

<img src="/blog/2017/01/talend1.png" width="50%"  alt=""> 

There is no event listener. What the...?

There's a trick: Select the "Phone"-field and `alt + tab` until you arrive at the checkbox, then hit `space`.

Next: Enjoy your modern webbrowser prohibiting a site to cross-reference `http` from `https`

<img src="/blog/2017/01/talend2.png" width="50%"  alt=""> 

But there is a download-link hidden inside the plethora of error messages:

<img src="/blog/2017/01/talend3.png" width="50%"  alt=""> 

If you're looking for these, here you go:

    https://www.opensourceetl.net/eval/621/TalendToolsStudio-20160704_1411-V6.2.1-installer-mac-dlm.dmg
    https://www.opensourceetl.net/eval/621/TalendToolsStudio-20160704_1411-V6.2.1-linux-x64-installer.run
    https://www.opensourceetl.net/eval/621/TalendToolsStudio-20160704_1411-V6.2.1-installer-win-dlm.exe

They won't help you, because they might be offline. If not, you get one of the greatest tools of all times—not.

## Fail 2: The Download-Tool

Pretty simple: You start it, it does nothing:

<img src="/blog/2017/01/talend4.png" width="50%"  alt=""> 

Reminds me of “A Sharepoint that *does* throw errors is a good Sharepoint”.

## Fail 3: The ZIP-File

Okay, while you wait for the download tool to do *anything*, you can also try out the ZIP-download-option. This link surprisingly worked! And it contains a `Talend-Studio-macosx-cocoa.app` file!

An unsigned one, of course, because why make things easy? The common advise you find on the internet is to turn off `Gatekeeper`, Apples system tool to prevent you from running malicious code (i.e. from developers who do not pay apple 100$/year). The easy way to get around this is to *right-click* a file and then click *open*. One would suspect this to do the exact same thing as double clicking the file, but watch and learn: It gives you an extra button:

<img src="/blog/2017/01/talend5.png" width="50%"  alt=""> 

And the next thing you see is: “The Talend-Studio-macosx-cocoa executable launcher was unable to locate its companion share library”.

<img src="/blog/2017/01/talend6.png" width="50%"  alt=""> 

WHAT?

This is a hard one: You need to right-click the app, choose `Show package contents`, navigate to `Contents:MacOS:Talend-Studio-macosx-cocoa` and execute *that*. Voilà! It starts!

