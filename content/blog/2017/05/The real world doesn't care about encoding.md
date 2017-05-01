+++
title = "The real world doesn't care about encoding"
draft = false
date = "2017-05-01T11:45:00+01:00"
keywords = [ "Aircraft" ]
slug = "the_real_world_doesnt_care_about_encoding"

[params]
  author = "Jannik Arndt"
+++


Last week one of our programs failed looking up an airplane by its [registration](https://en.wikipedia.org/wiki/Aircraft_registration). That's not a surprise, since ac regs are a _horrible_ identifier. They change all the time. Also there is almost no naming rule at all. Wikipedia states

> When painted on the fuselage, the prefix and suffix are usually separated by a dash (for example, `YR-BMA`). When entered in a flight plan, the dash is omitted (for example, `YRBMA`). In some countries that use a number suffix rather than letters, like the United States (`N`), South Korea (`HL`), and Japan (`JA`), the prefix and suffix are connected without a dash.

<!--more-->

Okay, so the _only_ thing in common is a prefix and a main part, separated by a dash, but  that's often dropped. Nice! Also the both parts might consist of letters and numbers. And they vary in length. And most of the time, the prefix designates the country of registration, although there are exceptions, for example [Guernsey](https://en.wikipedia.org/wiki/Guernsey), which is not a part of Great Britain (`G–`) but its property, therefore having the registration `2–` They island has its own airline, [Aurigny](https://en.wikipedia.org/wiki/Aurigny), but all of their 10 aircraft [use the `G-`-Prefix](http://publicapps.caa.co.uk/modalapplication.aspx?catid=1&pagetype=65&appid=1&mode=summary&owner=Aurigny). 

<img src="/blog/2017/05/G-JOEY.jpg" alt=""> 
(https://en.wikipedia.org/wiki/Aurigny#/media/File:G-JOEY.jpg)

And then there are military aircraft. Since they are not affected by the [_Chicago Convention on International Civil Aviation_](https://en.wikipedia.org/wiki/Chicago_Convention_on_International_Civil_Aviation), they are free to do whatever they want. In the US, they use the base code (as in code of the military base), year they were ordered and a serial number. In Germany consists of the [aircraft type and a serial number](https://de.wikipedia.org/wiki/Flugbereitschaft_des_Bundesministeriums_der_Verteidigung#Gro.C3.9Fraumflugzeuge).  And this is where my error comes from:

We recently switched one of our source systems, and apparently the aircraft formerly entered as `10-27` now is `10+27`. That's weird, because the old source is more trustworthy (but incomplete), and you usually use dashes, not plus-signs. 

A quick Google-search turns up the [wikipedia page](https://de.wikipedia.org/wiki/Flugbereitschaft_des_Bundesministeriums_der_Verteidigung#Gro.C3.9Fraumflugzeuge) and an official [Luftwaffe page](http://www.luftwaffe.de/portal/a/luftwaffe/start/waff/tran/a310/mrt/!ut/p/z1/hU67DoIwFP0WB9beK77AreiCYmKCUehiKtSCqS2pFfx8MU4mGs92njnAIAOmeVtL7mqjuep5zqbHKEh2iR_6frIPlxgPN-tJGEYx4hQO_wKst_EHKEJaCsj7jdmPDbpYjSEFBuzCW_4gjbFOCUd48XoIecV1qcTWFPQtrIBJZU7v61SfRoEEZsVZWGHJ3fZy5Vxzm3voYdd1RBojlSCl8PBbozI3B9lHEJpr1uFootqEDp4qf9s7/dz/d5/L2dBISEvZ0FBIS9nQSEh/#Z7_B8LTL2922LV9D0I1MK599BACJ4), both in favour of the plus. Okay, but this is Germany, there surely is an official Behörde that clearly regulates all this! — Yes, there is! It's the [Luftfahrzeugrolle](https://de.wikipedia.org/wiki/Luftfahrzeugrolle) and their website states that [due to data protection reasons they cannot disclose anything](https://www.lba.de/DE/Technik/Verkehrszulassung/Hinweise/Auskuenfte.html). Marvellous! The information written in huge letters and visible for everyone is protected. Wait! It's written on the plane! And there are _a lot_ of people taking pictures of airplanes! Alas, the solution is:

<img src="/blog/2017/05/Luftwaffe_A310_10+27.jpg" alt=""> 
(https://commons.wikimedia.org/wiki/File:Luftwaffe_A310_10%2B27.jpg)

They use the iron cross as a separator! I give up…
