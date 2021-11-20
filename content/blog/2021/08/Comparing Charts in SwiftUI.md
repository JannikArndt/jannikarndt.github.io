---
title: "Comparison of Chart Libraries for SwiftUI"
date: "2021-08-29T11:30:00+02:00"
author: "Jannik Arndt"
keywords: [ "Blog", "SwiftUI", "iOS" ]
tags: [ "swift", "swiftui", "iOS", "charts" ]
slug: "comparison_of_chart_libraries_for_swiftui"
toc: true
showToc: true
TocOpen: true
draft: false
comments: false
cover:
  image: "opengraphimages/Generating Open Graph Images for my Blog.png"

---

I want to add charts to my SwiftUI iOS App, [Zettl](https://zettl.jannikarndt.de). For that, I am going to compare the following libraries:

* [ivanschuetz/SwiftCharts](https://github.com/ivanschuetz/SwiftCharts)
* [denniscm190/stock-charts](https://github.com/denniscm190/stock-charts)
* [spacenation/swiftui-charts](https://github.com/spacenation/swiftui-charts)
* [AppPear/ChartView](https://github.com/AppPear/ChartView)
* [danielgindi/Charts](https://github.com/danielgindi/Charts/)

<!--

plus I will try to implement them myself, based on the following tutorials:

* [Drawing Charts in SwiftUI](https://itnext.io/drawing-charts-in-swiftui-a5a87ac8cf9)
* [Charts in SwiftUI - Part 1: Bar Chart](https://blckbirds.com/post/charts-in-swiftui-part-1-bar-chart/)
* [Build Animated Pie and Donut Charts in SwiftUI](https://betterprogramming.pub/build-animated-pie-and-donut-charts-in-swiftui-9b74b95f8b39)
* [Create Charts in SwiftUI (Line, Bar, Pie) - Xcode 12, Swift 5, 2020 iOS Development](https://youtu.be/F-dt0vOQ4Vg)
--> 

<!--more-->

## Requirements

My needs are

* *bar charts* for categorial data. Extra: I need images as labels.
* *line charts* for time-scale data. With multiple lines. Bonus points if I don't have to care about the time distribution, i.e. can enter timestamps and they are spread correctly.
* *pie charts* for relative comparisons. Here, the magic lies in good annotations.


{{< figure src="/blog/2021/08/charts/requirements.png" >}}

## SwiftCharts

{{< figure src="/blog/2021/08/charts/swiftcharts.PNG" width="200px" class="right" >}}

* URL: https://github.com/ivanschuetz/SwiftCharts
* License: Apache 2
* [Maturity](https://github.com/ivanschuetz/SwiftCharts/graphs/contributors):
    * Created May 2015 ✅ 
    * ~2 backup contributors, 32 in total
    * Last big changes 2019 😬 
    * Last commit to main: 8 days ago 👍 


### Supported Chart Types

* Bar Charts ✅ 
* Line Charts ✅ (didn't check)
* Donut Charts ✅ (didn't check)
* more

### Code

* [Bar Chart](https://github.com/JannikArndt/SwiftUI-Charts-Playground/blob/main/ChartsPlayground/SwiftCharts/SwiftChartsBarChart.swift)

### Result

* integration of UIView in SwiftUI sucks
* Docs don't help a lot
* Examples are very complex

{{< rawhtml >}}
<div class="clearright"></div>
{{< /rawhtml >}}

------

## Stock-Charts

{{< figure src="/blog/2021/08/charts/stock-bar.PNG" width="200px" class="right" >}}



* URL: https://github.com/denniscm190/stock-charts
* License: MIT
* [Maturity](https://github.com/denniscm190/stock-charts/graphs/contributors):
    * Created April 2021 ⛲ 
    * Single-dev-project 👨‍💻 
    * Ongoing development ✅ 
    * Last commit to main: 20 days ago 👍 
    * Demo App: https://github.com/denniscm190/trades-demo



### Supported Chart Types

* Bar Charts => as "Capsule" Charts, for _one_ value only ❌
* Line Charts: without axis, only for this one specific use-case 🆗
* Pie Charts: ❌



### Code

* [Bar Chart](https://github.com/JannikArndt/SwiftUI-Charts-Playground/blob/main/ChartsPlayground/StockCharts/StockChartsBarChart.swift)
* [Line Chart](https://github.com/JannikArndt/SwiftUI-Charts-Playground/blob/main/ChartsPlayground/StockCharts/StockChartsLineChart.swift)

{{< figure src="/blog/2021/08/charts/stock-line.PNG" width="200px" class="right" >}}

### Result

* Super easy to integrate
* But very limited to this one use case
* The code offers some good inspiration to base upon


{{< rawhtml >}}
<div class="clearright"></div>
{{< /rawhtml >}}


--------

## SwiftUI Charts

{{< figure src="/blog/2021/08/charts/spacenation-bar.PNG" width="200px" class="right" >}}

* URL: https://github.com/spacenation/swiftui-charts
* License: MIT
* [Maturity](https://github.com/spacenation/swiftui-charts/graphs/contributors)
    * Created Nov 2019 ✅ 
    * Single-dev-project 👨‍💻
    * Last big change in Oct 2020 😬  
    * 2 open PRs
* Bug: Data is ordered in reverse
* Naming conflict: This package uses the same name as (the much older) https://github.com/danielgindi/Charts. To import both, I forked it to https://github.com/JannikArndt/swiftui-charts, changed the name and cherry-picked the open PRs.

### Supported Chart Types
* Bar Charts, also stacked, not no axis or labels 😬 
* Very simple line charts 🆗 
* No pie charts ❌

{{< figure src="/blog/2021/08/charts/spacenation-line.PNG" width="200px" class="right" >}}

### Code

* [Bar Chart](https://github.com/JannikArndt/SwiftUI-Charts-Playground/blob/main/ChartsPlayground/SwiftUiCharts/SwiftUiChartsBarChart.swift)
* [Line Chart](https://github.com/JannikArndt/SwiftUI-Charts-Playground/blob/main/ChartsPlayground/SwiftUiCharts/SwiftUiChartsLineChart.swift)

### Result

* Easy to integrate
* But quite buggy
* No axis-options


{{< rawhtml >}}
<div class="clearright"></div>
{{< /rawhtml >}}


--------


## AppPear/ChartView

{{< figure src="/blog/2021/08/charts/apppear-bar.PNG" width="200px" class="right" >}}

* URL: https://github.com/AppPear/ChartView
* License: MIT
* [Maturity](https://github.com/AppPear/ChartView/graphs/contributors)
    * Created continuously between Jun 2019 and today ✅ 
    * Version 2 is currently in beta
    * Only small contributions from others

### Supported Chart Types

* Bar Charts ✅ (no axis though)
* Line Charts ✅ (with multiple lines, no axis)
* Pie Charts ✅ (no labels)


### Code

* [Bar Chart](https://github.com/JannikArndt/SwiftUI-Charts-Playground/blob/main/ChartsPlayground/AppPear/AppPearBarChart.swift)
* [Line Chart](https://github.com/JannikArndt/SwiftUI-Charts-Playground/blob/main/ChartsPlayground/AppPear/AppPearLineChart.swift)
* [Pie Chart](https://github.com/JannikArndt/SwiftUI-Charts-Playground/blob/main/ChartsPlayground/AppPear/AppPearPieChart.swift)

{{< figure src="/blog/2021/08/charts/apppear-line.PNG" width="200px" class="right" >}}

### Result

* Nice library for that particular style, but cannot be changed to view axis / labels / more things

{{< figure src="/blog/2021/08/charts/apppear-pie.PNG" width="200px" >}}

{{< rawhtml >}}
<div class="clearright"></div>
{{< /rawhtml >}}


--------


## danielgindi/Charts

{{< figure src="/blog/2021/08/charts/charts-bar.PNG" width="200px" class="right" >}}

* URL: https://github.com/danielgindi/Charts
* License: Apache 2
* [Maturity](https://github.com/danielgindi/Charts/graphs/contributors)
    * Created Mar 2015 🕸 
    * Ongoing maintenance by second dev
    * 4 devs with larger contributions

### Supported Chart Types

* Bar Charts ✅ (even horizontal, with every option you can think of)
* Line Charts ✅ 
* Pie Charts ✅ 

### Code

* [Bar Chart](https://github.com/JannikArndt/SwiftUI-Charts-Playground/blob/main/ChartsPlayground/Charts/ChartsBarChart.swift)
* [Line Chart](https://github.com/JannikArndt/SwiftUI-Charts-Playground/blob/main/ChartsPlayground/Charts/ChartsLineChart.swift)
* [Pie Chart](https://github.com/JannikArndt/SwiftUI-Charts-Playground/blob/main/ChartsPlayground/Charts/ChartsPieChart.swift)

{{< figure src="/blog/2021/08/charts/charts-line.PNG" width="200px" class="right" >}}

### Result

* By far the most comprehensive library
* No docs, references the [Android docs](https://weeklycoding.com/mpandroidchart-documentation/), but [good amount of demos](https://github.com/danielgindi/Charts/tree/master/ChartsDemo-iOS/Swift/Demos)
* Many third-party tutorials, for example [this one](https://github.com/StewartLynch/Charts-SwiftUI) that explains the integration into SwiftUI
* The amount of options is a little overwhelming, and the defaults are _insane_, so you _have_ to go through the options.

{{< figure src="/blog/2021/08/charts/charts-pie.PNG" width="200px" >}}

{{< rawhtml >}}
<div class="clearright"></div>
{{< /rawhtml >}}


--------

## Conclusion

I was close to building my own version of the required charts, until I tried `danielgindi/Charts`. While it is a heavyweight, I will give it a shot.

You can try out the demo-app with all five libraries here: https://github.com/JannikArndt/SwiftUI-Charts-Playground.

{{< figure src="/blog/2021/08/charts/demoapp.PNG" width="200px" >}}