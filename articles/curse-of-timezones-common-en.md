---
title: The Curse of Timezones: Knowledge
published: false
description:
tags: [ "datetime", "timezone", "tzdb" ]
//cover_image: https://direct_url_to_image.jpg
---

"The curse of timezones" [^original-title] was originally published in Japanese at [Qiita](https://qiita.com/dmikurube/items/15899ec9de643e91497c) in 2018, and then revised at [Zenn](https://zenn.dev/dmikurube/articles/curse-of-timezones-common-ja) in 2021. This is an English translation by the same author in 2021.

[^original-title]: Its original title was "タイムゾーン呪いの書" in Japanese.

Introduction
-------------

Most of us have heard of the concept of time zones. Most software engineers have probably written some kind of programs related to time and timezones. Some countries such as Japan, however, have no time difference in the countries [^no-time-diff-for-now], nor no summer time (daylight saving time) [^no-summer-time-for-now]. Only one standard time is sufficient for them. They do not have many chances to look into this troublesome concept of timezones.

[^no-time-diff-for-now]: For now.
[^no-summer-time-for-now]: For now.

Many software engineers in such a country may think that they don't need think about troublesome timezones. However, they never know when they will get a chance to expand your software or service to other countries or regions. It would be very sad if wrong implementation of time processing becomes an obstacle to expand.

In 2018, politicians in Japan considered introducing summer time (daylight saving time) for the start of 2020. It was abandoned in the same year due to opposition from many people including software engineers [^give-up-summer-time-in-japan], but it may be introduced someday. In fact, this was not the only time in recent years that the introduction of summer time was considered in Japan. [^summer-time-in-japan-in-2008] Any country, even in Japan, always has the risk of a sudden change. It is always better to implement time processing properly.

[^give-up-summer-time-in-japan]: ["Japan to abandon daylight saving time for 2020 Olympics: Asahi" (September 27, 2018, Reuters)](https://www.reuters.com/article/us-olympics-2020-daylight-saving-idUSKCN1M719G)
[^summer-time-in-japan-in-2008]: ["Japan wary of daylight saving time" (July 26, 2008, Los Angeles Times)](http://archive.boston.com/news/world/articles/2008/07/26/japan_wary_of_daylight_saving_time/)

This article explains the "curse" that is always attached to dealing with time zones, the resentment that I suffered from time zones, from the perspective of software engineering, stepping into the darkness, and how to properly escape from this curse and how to fight against it head on.
In addition, I will introduce the author's subjective view on how to properly escape from this curse and how to fight back against it. I hope this article will help you to implement time and timezone processing in a "proper" way.

In other words, the author's curse.

As a reference implementation, this article occasionally refers to Java's [JSR 310: Date and Time API](https://jcp.org/en/jsr/detail?id=310), which confronts the issue of date/time and time zone head-on.

If you find any missing information or errors in the article, please send us your comments. If you find any missing or incorrect information in the article, please send us your comments. I have also referred to Wikipedia in some parts of the description, but it seems that the Japanese version of Wikipedia has some discrepancies with the English version. In such a case, I basically trust the English version. 

: There are probably many.
: Since the author also wants to know.
: Sometimes the link is to the Japanese version.

Time Difference, Standard Time, Time Zone
===========================

As long as we live on the earth, there is no escaping the "time difference" if we want the world to share the understanding that "1pm" is usually around noon. In some areas, "1:00 p.m." is the "time" that represents a certain moment in that area, but in other areas, it is "9:00 a.m." at the same moment. This is the source of the complication and the starting point. 

By the way, [Internet time](https://www.swatch.com/en-en/internet-time.html) ([Wikipedia](https://ja.wikipedia.org/wiki/%E3%82%B9%E3%82%A6%E3) %82%A9%E3%83%83%E3%83%81%E3%83%BB%E3%82%A4%E3%83%B3%E3%82%BF%E3%83%BC%E3%83%8D%E3%83%83%E3%83%88%E3%82%BF%E3%82%A4%E3%83%A0))? I'm not sure what happened to it.

However, if the time is defined as "the time when the sun is in the middle of the south at a certain point is the noon at that point", then in extreme cases, even a single step in the east-west direction will cause a slight time difference. For example, there will be a slight time difference between Shinagawa and Shinjuku, which are only a short distance apart.  

: Before the concept of standard time and time zones was popularized, clocks in a city were adjusted to the position of the sun visible in that city, so it was actually close to that. ([Wikipedia:Standard Time#History of Standard Time](https://ja.wikipedia.org/wiki/%E6%A8%99%E6%BA%96%E6%99%82#%E6%A8%99%E6%BA%96%E6%99%82%E3%81%AE%E6%AD%B4%E5 %8F%B2))

: Before 1887, when Japan Standard Time came into effect, there was a local time in Tokyo. Offsets such as `+09:18:59`, which sometimes appear when manipulating old dates and times, are an attempt to express the Tokyo local time as a time difference from UTC at that time. The following article has a more detailed explanation: ["A look into the history of Japan Standard Time over 18 minutes and 59 seconds" (December 12, 2018, M3 Tech Blog)](https://www.m3tech.blog/entry/timezone-091859)

That would be inconvenient in many ways, including legal, commercial, social, etc., so we decided to use the same time for areas of a certain size that are geographically close. The time (system) is called the "standard time" of the region, and the regions that use the same standard time are called "time zones. For example, the whole of Japan, which uses Japan Standard Time, is a time zone. 

The concept of "standard time" across a wide area was first introduced in England in 1847 as "railroad time" with the spread of railroads, and then spread to other countries through the International Meridian Conference in 1884. ([Wikipedia(en):Standard time](https://en.wikipedia.org/wiki/Standard_time#Great_Britain))

Normal time](https://ja.wikipedia.org/wiki/%E5%B8%B8%E7%94%A8%E6%99%82)" ([civil time](https://en.wikipedia.org/ wiki/Civil_time)). 

: While "standard time" is a different time from "daylight saving time", which will be discussed later, "normal time" refers to "the valid time used by people at that time in that area", whether it is standard time or daylight saving time.

Time zone boundaries generally follow political boundaries such as national, state and city borders. Of course, this is more convenient considering the role of time zones, but time zones and standard time are not defined by international treaties, but rather by the governments of countries and regions that declare, "This is the time we use in our region! This is because the governments of countries and regions have declared that they will use this time for their region. 

This is also the case with the so-called "date line," which is not an internationally defined date line.

Time zone definition and usage
-------------------------

As mentioned above, a "time zone" is generally defined as "a region that uses the same standard time" based on Standard Time.  For example, the U.S. states of Colorado and Arizona use the same standard time, "[Mountain Standard Time](https://ja.wikipedia.org/wiki/%E5%B1%B1%E5%B2%B3%E9%83%A8%E6%A8%99%E6%BA%96%E For example, the U.S. states of Colorado and Arizona use the same "Mountain Standard Time" (%99%82), but differ in their daylight saving time system.  And these two states are in the same time zone by this definition.

: "A time zone is an area that observes a uniform standard time for legal, commercial and social purposes." ([Wikipedia (en): Time zone](https://en. wikipedia.org/wiki/Time_zone))

: [Colorado](https://ja.wikipedia.org/wiki/%E3%82%B3%E3%83%AD%E3%83%A9%E3%83%89%E5%B7%9E) has adopted daylight saving time, and [Arizona](https://ja.wikipedia.org/ wiki/%E3%82%A2%E3%83%AA%E3%82%BE%E3%83%8A%E5%B7%9E) does not [adopt daylight saving time](https://ja.wikipedia.org/wiki/%E3%82%A2%E3%83%AA%E3%82%BE%E 3%83%8A%E6%99%82%E9%96%93).

However, the term "time zone" is actually used in a very diverse and ambiguous way. There are many examples, such as the time zone IDs in the Time Zone Database (tzdb), which will be discussed later, that separate cases such as Colorado and Arizona as different time zones. On the other hand, there are also examples of countries and regions that have different definitions of "standard time" due to their different political entities, but use the same standard time as far as time differences are concerned, and call them a single time zone.  In some cases, a specific time difference itself, such as `UTC+9` (see below), is also called a time zone.

For example, in Windows 95, the time zone was set to "(GMT+09:00) Tokyo, Osaka, Sapporo, Seoul, Yakutsk".

When dealing with time zones, keep in mind the ambiguity of this term.

UTC: Time Zone Standard
------------------------

In order for people in countries and regions around the world to communicate with each other about time, there must be a standard somewhere. It is a bit unrealistic to expect people from different parts of the world to talk about many different combinations of relative time differences between countries and regions.

One of the earliest international standards used was "[Greenwich Mean Time](https://ja.wikipedia.org/wiki/%E3%82%B0%E3%83%AA%E3%83%8B%E3%83%83%E3%82%B8%E6%A8%99%E6%BA%96%E6%99% 82)" ([GMT: Greenwich Mean Time](https://en.wikipedia.org/wiki/Greenwich_Mean_Time)).  GMT is the time based on the position of the sun as observed from Greenwich, London, and it has remained useful in the daily life of ordinary people who follow the sun, i.e., as "normal time. From another point of view, however, GMT is the time based on the rotation of the earth and observations. The earth's rotation is not always constant, and there are slight variations. It does not correspond to the physically exact "24 hours". 

There are also several "[Universal Time](https://ja.wikipedia.org/wiki/%E4%B8%96%E7%95%8C%E6%99%82)" ([UT: Universal Time](https://en.wikipedia.org/wiki/ UT: Universal Time]( Universal_Time)) were defined as inheriting from GMT, but they are also based on the rotation of the earth, and have the same problem.

: Greenwich Mean Time was also the "railroad time" mentioned above.
The same problem applies to Greenwich Mean Time.
UT0, UT1, and UT2 are the types of world time. The use of UT2 has been largely replaced by UTC (see below), and it seems to be practically useless anymore.

International Atomic Time](https://ja.wikipedia.org/wiki/%E5%9B%BD%E9%9A%9B%E5%8E%9F%E5%AD%90%E6%99%82)" ([TAI: Temps Atomique International](https://ja.wikipedia.org/wiki/%E5%9B%BD%E9%9A%9B%E5%8E%9F%E5%AD%90%E6%99%82)) is a time set based on an atomic clock, not on the rotation of the earth. International](https://en.wikipedia.org/wiki/International_Atomic_Time)). This clock physically ticks off the exact time of one second, but then there is a "gap" between one revolution of the earth and one TAI day.

It is inconvenient for both the length of a day and a second to change from time to time, and for the circumference of the earth to be different from a day in our daily lives. Therefore, "[Coordinated Universal Time](https://ja.wikipedia.org/wiki/%E5%8D%94%E5%AE%9A%E4%B8%96%E7%95%8C%E6%99%82)" ([UTC: Coordinated Universal Time](https:// en.wikipedia.org/wiki/Coordinated_Universal_Time)), and UTC is now used as the standard in many fields. UTC is a time system that uses atomic clocks to tick off exactly one second, while introducing "leap seconds" to ensure that the difference from Universal Time (UT1) based on the rotation of the earth does not exceed 0.9 seconds. Leap seconds are often disliked because of their inconvenience, but we have to accept the inconvenience of either the length of a second changing from time to time, or the difference between the earth's revolution and a day in real life, or leap seconds.

Incidentally, there are not only positive leap seconds in which "59 minutes and 60 seconds" are inserted, but also negative leap seconds in which "59 minutes and 59 seconds" are deleted. However, there are no examples of "negative leap seconds" being implemented between the time of formulation and 2021.

UTC is mainly used in the software and telecommunications fields, and GMT is often treated as equivalent to UTC.

Thus, it is now common to express the time of each country or region in terms of its time difference (offset) from UTC. For example, the time in Japan, which is 9 hours ahead of UTC, is written as `UTC+9`, `UTC+09:00`, or `+09:00`. Most time zones are one hour ahead of UTC, but not [Australian Central Standard Time](https://ja.wikipedia.org/wiki/%E3%82%AA%E3%83%BC%E3%82%B9%E3%83%88%E3%83%A9%E3%83% AA%E3%82%A2%E6%99%82%E9%96%93) (`UTC+09:30`) and [Nepal Standard Time](https://ja.wikipedia.org/wiki/%E3%83%8D%E3%83%91%E3%83%BC%E3%83%AB%E6%A8%99% E6%BA%96%E6%99%82) (`UTC+05:45`).

Region-based" and "offset
-------------------------------

As mentioned above, a specific time difference itself, such as `UTC+09:00`, is sometimes called a "time zone". It would be nice if we could distinguish between "time zones that represent regions" and "time zones that represent specific time differences independent of regions", but unfortunately there seems to be no general term to distinguish them.  

Unfortunately, there seems to be no general term to distinguish them. If you know of one, please let me know.
: Stack Overflow question ["Daylight saving time and time zone best practices"](https://stackoverflow.com/questions/2532729/daylight-saving-time- and-time-zone-best-practices) and [`timezone`](https://stackoverflow.com/tags/timezone/info) on the same tag wiki refer to it as "time zone" and "time zone offset". In this article, we will use JSR 310.

In this article, we will refer to the former as "region-based time zone" and the latter as "fixed offset" or simply "offset", referring to JSR 310. Specifically, [`java.time.ZoneId`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneId.html) and [`java.time.ZoneOffset`](https://) docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneOffset.html).

Time zone switching
=========================

The time zone offset for a region can be switched to another offset for a variety of reasons. A prime example is the infamous "Daylight Savings Time".

: It is often referred to as "Daylight Saving Time" in American systems and "Summer Time" in European systems.

Daylight Saving Time
-------

Daylight Saving Time (DST) is a time difference between countries and regions that causes more chaos in the world than the mere difference in time. Since Daylight Savings Time is generally implemented "to allow people to finish work in the light of day and spend more time in their leisure time," when a region switches to Daylight Savings Time, the time in that region moves forward a little.

When a region switches to Daylight Saving Time, the time in that region moves forward a little. There are a few places like [Lord Howe Island, Australia](https://www.timeanddate.com/time/change/australia/lord-howe-island) that are only 30 minutes ahead.

Japan is not a big fan of Daylight Savings Time, so some of you may not know what exactly happens when it switches. It is quite acrobatic, and the time suddenly blows up when the switch is made.

For example, in the year 2020, the United States switched to Daylight Saving Time on Sunday, March 8.  The timing is 2:00 a.m., which is the time before the switch, and when you think one second has passed since 1:59:59 a.m. on that day, it is now 3:00:00 a.m. Using the state of California as an example, the following table shows the elapsed time in one-second increments.

In the United States from 2007 to 2021, the rule is to switch to Daylight Savings Time on the second Sunday in March each year, and then back to Standard Time on the first Sunday in November.

| Time in California | Difference (offset) from UTC
| | --- | --- |
| 2020-03-08 01:59:58 | Pacific Standard Time (`PST`) -08:00 |
| 2020-03-08 01:59:59 | Pacific Standard Time (`PST`) -08:00
| 2020-03-08 03:00:00 | Pacific Daylight Time (`PDT`) -07:00 |
| 2020-03-08 03:00:01 | Pacific Daylight Time (`PDT`) -07:00 |

In other words, there was never a time in California that was 2:30 a.m. on March 8, 2020.

The transition from Daylight Savings Time back to Standard Time is even trickier, as you will experience the same apparent time twice. Again taking California in 2020 as an example, the time passed as follows

| Time in California | Difference from UTC (offset)
| --- | --- |
| 2020-11-01 01:00:00 | Pacific Daylight Time (`PDT`) -07:00 |
| 2020-11-01 01:00:01 | Pacific Daylight Time (`PDT`) -07:00 | ... | ...
| ... | ... | ...
| 2020-11-01 01:59:59 | Pacific Daylight Time (`PDT`) -07:00 | ... | ... | ...
| 2020-11-01 01:00:00 | Pacific Standard Time (`PST`) -08:00 | ... ...
| 2020-11-01 01:00:01 | Pacific Standard Time (`PST`) -08:00 |

In other words, there were two 1:30 a.m. times on November 1, 2020, in California.

The biggest "time zone curse", as I call it in this article, is that using a region-based time zone always comes with a set of "non-existent time" and "double time" problems like this. Once you use a region-based time zone, there's no escaping it.

### Daylight Savings Time: Anecdotes

There are many anecdotes about Daylight Savings Time, so here are a few.

Although Daylight Savings Time has not been adopted in Japan in 2021, [Daylight Savings Time was once in effect immediately after World War II](https://ja.wikipedia.org/wiki/%E5%A4%8F%E6%99%82%E9%96%93#%E9%80%A3%E5%90 %88%E5%9B%BD%E8%BB%8D%E5%8D%A0%E9%A0%98%E6%9C%9F).

As of 2021, every country will return to Standard Time within a year of the switch to Daylight Saving Time. However, [during World War II, the United Kingdom switched to Daylight Savings Time and did not return, and then switched back to Daylight Savings Time twice the following year](https://ja.wikipedia.org/wiki/%E8%8B%B1%E5%9B%BD%E5%A4%8F%E6%99%82%E9%96%93 #%E6%AD%B4%E5%8F%B2).

Even in countries and regions that have adopted Daylight Saving Time, not all of them seem to have stable "switching rules" like the United States. For example, [in Chile, the daylight saving time system changed several times around 2016](https://en.wikipedia.org/wiki/Time_in_Chile#Summer_time_(CLST/EASST)). [In Brazil, until 2008, the areas where Daylight Saving Time was implemented and the date of the switch were announced separately each year, and the announcement was sometimes made just before the start of Daylight Saving Time](https://en.wikipedia.org/wiki/Daylight_saving_time_in_Brazil ).

Switchover other than Daylight Saving Time
-----------------------

In addition to Daylight Savings Time, local time zone offsets may also be switched. In addition to Daylight Savings Time, local time zone offsets may also change, mainly due to political decisions made by the government of the country or region at the time.

For example, at the end of 2011, the standard time in [Independent State of Samoa](https://ja.wikipedia.org/wiki/%E3%82%B5%E3%83%A2%E3%82%A2) switched from `UTC-11:00` to `UTC+13:00`. The switch was implemented in such a way that the end of December 29th was directly followed by the beginning of December 31st, meaning that the entire 30th of December 2011 did not exist in Samoa.

The curse of the time zone also comes into play in this way. Many of us are aware that Daylight Savings Time can be an hour or so longer or shorter, but we have never considered that we might lose an entire day.

The End of Daylight Savings Time
-----------------

As of 2021, the end of Daylight Savings Time is being debated around the world. As a software engineer, I welcome the end of daylight saving time in the long run, but it's not that simple to say that something that has been in place for a long time will no longer be in place. We need to keep a close eye on the situation.

For example, according to the resolution of the European Parliament, daylight saving time in the EU was supposed to be abolished in 2021.  However, due to Brexit and the Corona disaster, the situation was still unclear even in March of 2021.  

: ["European Parliament Passes Bill to Abolish Daylight Saving Time in 2021" (March 28, 2019, Asahi Shimbun)](https://digital.asahi.com/articles/ASM3W0014M3VUHBI02R.html)
: ["Why Europe Could Abolish Daylight Saving Time in 2021" (March 27, 2021, Asahi Shimbun)](https://digital.asahi.com/articles/ASP3W4HWJP3VUHBI04L.html)
: ["Why Europe Couldn't Stop Daylight Saving Time" (March 11, 2021, Bloomberg)](https://www.bloomberg.com/news/articles/2021-03-) 11/will-daylight-saving-time-ever-end)

To complicate the situation in the EU, it seems that it is up to each country to decide whether the new standard time after the abolition of Daylight Saving Time will be back to the "old standard time" or the "new daylight saving time". As of June 2021, we still don't know what the final decision will be, although it seems that there is a desire to make it as consistent as possible. To put it another way, the same "Central European Time (CET)" (https://ja.wikipedia.org/wiki/%E4%B8%AD%E5%A4%AE%E3%83%A8%E3%83%BC%E3%83%AD%E3%83%83%E3%83%91%E6% 99%82%E9%96%93), there may be a time difference between Germany, France, and Italy from next year. The curse of time zones strikes when you are not aware of it. It's a scary story. 

: ["Italy's Last Daylight Saving Time as Daylight Saving Time Abolished" (March 21, 2021, World Voice in Newsweek Japan)](https://www.newsweekjapan.jp/worldvoice/vismoglie/2021/03/post-23.php )

Also, in California, a 2018 referendum supported a change in daylight saving time.  As of June 2021, there are no concrete plans for a change, but that may change in the future.

: ["California, Residents Support Daylight Saving Time Change" (November 19, 2018, Japan External Trade Organization)](https://www.jetro.go.jp/biznews/2018/11/f4ab9860d030abf0.html)

One thing to note about the California change is that some software uses "Los Angeles Time" as representative of "[Pacific Time](https://ja.wikipedia.org/wiki/%E5%A4%AA%E5%B9%B3%E6%B4%8B%E6%99%82%E9%96%93)". As we will see later, there is actually Java. As we will see later, this is actually the case with Java's standard API. For example, if you use "Pacific Standard Time (`PST`)" to represent the winter time in Seattle, Washington, it is internally treated as Los Angeles time. I wonder what would happen if Daylight Savings Time was abolished in California. There is an aspect of the time zone curse that we know something terrible is about to happen, but we don't know what it will be until the political decisions of each country or region are made. It's a story we don't want to think about.

Time in Software Technology
=============================

So far, we have mainly introduced the general structure of time and time zones. From here on, we will focus on the technical aspects specific to the software and communication fields.

Unix time: the universal time axis
----------------------------

Although there is a time difference between "time" in different parts of the world, time still flows in the same way all over the world, and the time axis is the same all over the world. A point on that time axis is the same moment, common to the whole world.  For example, 3:00:00 p.m. on July 1, 2020 in Japan and 7:00:00 a.m. on July 1, 2020 in the United Kingdom are the same point on the time axis. It is no problem to use the local time in each country or region, but when you cross time zones, especially when the Internet is involved, you want to use the same time axis worldwide.

The relativistic point is (ry)

As mentioned above, there is a common standard called UTC, so all you have to do is to express the time axis in UTC. However, it is useless to calculate the year, month, day, hour, minute, second, and so on on that time axis. So in the software field, we often use [Unix time](https://ja.wikipedia.org/wiki/UNIX%E6%99%82%E9%96%93) to represent time.

Unix time, also known as "Unix time" in Japanese and "POSIX time" or "(Unix) epoch time" in English, expresses the time as the number of seconds elapsed since 0:00:0 minutes and 0 seconds of January 1, 1970, UTC. This UTC time, January 1, 1970, 0:0:0 is called "epoch".

If you know Unix time, it should be easy to calculate the year, month, day, hour, minute, and second in any time zone... but there is one problem left. Leap seconds. Leap seconds are designed to compensate for the unpredictability of the rotation speed of the Earth's axis, so it is impossible to determine when leap seconds will be introduced in the future. This means that the Unix time corresponding to the future time cannot be calculated.

Therefore, Unix time ignores leap seconds in favor of convenience, abandoning the strictness of "elapsed time". [Recently, a positive leap second was inserted between December 31, 2016 23:59:59 and January 1, 2017 0:00:00:0 in UTC](https://jjy.nict.go.jp/QandA/data/leapsec.html), where Unix time's ` 1483228800` lasted for 2 seconds. If we arrange its elapse in 0.5 second increments, we get the following

| time in UTC | Unix time with decimals
| --- | --- |
| 2016-12-31 23:59:59.00 | 1483228799.00 |
| 2016-12-31 23:59:59.50 | 1483228799.50 |
| 2016-12-31 23:59:60.00 | 1483228800.00 |
| 2016-12-31 23:59:60.50 | 1483228800.50 |
| 2017-01-01 00:00:00.00 | 1483228800.00 |
| 2017-01-01 00:00:00.50 | 1483228800.50 |
| 2017-01-01 00:00:01.00 | 1483228801.00 |

If you look at just the integer part of Unix time, it doesn't look like much of a problem, since the same second lasts for two seconds. However, if there is a fractional part and the fractional part is counted as usual, the time will have gone backwards, so be careful. 

: Historically, there is a theory that the term "Unix time" refers only to integers up to the second (second precision). In accordance with this, "the fractional part of Unix time" is a bit strange, but the modern [POSIX `clock_gettime`](https://pubs.opengroup.org/onlinepubs/9699919799/functions/ clock_gettime.html) is in seconds or nanoseconds, so the Unix time in this article is defined to refer to numbers with fractional parts as well.

The "dilution" of leap seconds
-------------------

Although leap seconds have been introduced in UTC, not all software requires "exact time to the second". Leap seconds have caused a lot of problems in the past, including the regressive problem. 

In the past, leap seconds have caused many problems, including regressive problems.

So, a method of "diluting" the leap second with a few hours of time around the leap second, discarding the exactness of the second gained by UTC again when it is not needed, was born from discussions around 2000. This is becoming a common practice in recent software and cloud services, but there are several schools of thought on this "dilution".

There are several schools of thought on this "dilution" : such a technique was first publicly discussed in [Markus Kuhn of Cambridge University's UTS (Smoothed Coordinated Universal Time)](https://www.cl.cam.ac.uk/~mgk25/uts.txt) in 2000. It seems to be the first.

For example, the "[Java Time Scale](https://docs.oracle.com/javase/jp/8/docs/api/java/time/Instant.html)" used in Java's JSR 310 is a derivative of the first discussion, [UTC-SLS (Coordinated Universal Time with Smoothed Leap Seconds)](https://www.cl.cam.ac.uk/~mgk25/time/utc-sls/), which was derived from the first discussion. UTC-SLS distributes and dilutes the leap seconds evenly over the last 1000 seconds of the day in which they are introduced, making them invisible. So, in a Java timescale dilution period with positive leap seconds, it actually takes 1.001 seconds for a second to pass on the surface.

It was published as an [IETF Internet Draft](https://tools.ietf.org/html/draft-kuhn-leapsecond-00) in 2006.

On the other hand, for cloud services such as AWS and Google Cloud, a slightly different school of thought is becoming more common. Their method is often referred to as "[Leap Smear](https://docs.ntpsec.org/latest/leapsmear.html)" and is mainly provided via NTP.

The word "Smear" means something like "to rub on" or "to rub into obscurity".

The first Leap Smear implemented by Google [https://googleblog.blogspot.com/2011/09/time-technology-and-leaping-seconds.html] for the 2008 leap second was to "un-smear" the leap second to 20 hours "before" it. The next [2012-2016] Leap Smear [Google's first Leap Smear in 2008]() distributed leap seconds "non-linearly" to the "20 hours" "before" them. The following [Google's Leap Smear for leap seconds from 2012 to 2016](https://cloudplatform.googleblog.com/2015/05/Got-a-second-A-leap-second-that-is-Be-ready -for-June-30th.html) is now "linearly" distributed over "20 hours" "before and after" the leap second.

Now [Google suggests](https://developers.google.com/time/smear) that the standard is to distribute "linearly" over the "24 hours" "before and after" the leap second. Leap Smear](https://aws.amazon.com/jp/blogs/aws/look-before-you-leap-the-coming-leap-second-and-aws/), implemented by Amazon in 2015 and 2016, is similar to this. It seems safe to assume that this will be the norm for cloud services.

tzdb: Industry standard for timezone representation
---------------------------------

The [Time Zone Database](https://www.iana.org/time-zones) is probably the most common industry standard for representing time zones in the software field. IDs such as `Asia/Tokyo` and `Europe/London`, which you may have seen before, are from this Time Zone Database.

: [Wikipedia:tz database](https://ja.wikipedia.org/wiki/Tz_database)

It was originally called "tz database", "tzdb" for short, or simply "tz". In this article, it will be referred to mainly as "tzdb". It is also called "zoneinfo" because of the path name used in Unix-like operating systems. It was started by Arthur David Olson and others, and records show that it was maintained as late as 1986.  It is sometimes called "Olson database" after Olson.

: ["seismo!elsie!tz ; new versions of time zone stuff" (Nov 25, 1986)](http://mm.icann.org/pipermail/tz/1986-November/008946.html)

The tzdb ID is given with the name of the continent or ocean in front of the first `/` and the name of the city or island that represents the time zone in the back.  Country names are generally not used.  There are a few timezones with three elements, such as `America/Indiana/Indianapolis`.

This is the same as saying "in Tokyo time" or "in New York time" in Japanese.

: The state of affairs involving countries is prone to change, and it has been stated [that this is because it is robust against changes due to political circumstances](https://github.com/eggert/tz/blob/2021a/theory.html#L143-L151). It seems to me that "cities" as units of human life tend to be maintained longer than that. Source needed. Incidentally, [an early suggestion](https://mm.icann.org/pipermail/tz/1993-October/009233.html) had the intention of using country names.

The management of tzdb was transferred to ICANN's IANA in 2011, but it is still maintained by individual volunteers.  Time zones change surprisingly often somewhere in the world, and new versions of tzdb are released several times a year. This can be due to political decisions, as in the case of Samoa, or to the introduction or abolition of a new daylight saving time system, or to changes in the boundaries of a country or region. There are also times when errors are found in the registered historical data and they need to be corrected.  Updates to tzdb are often made just before the actual time zone change, and the aforementioned Samoa Standard Time change was applied to tzdb [only four months before the actual time zone change in December 2011](http://mm.icann.org/pipermail/tz/2011- August/008703.html).

: ["ICANN to Manage Time Zone Database" (October 14, 2011)](https://itp.cdn.icann.org/en/files/announcements/release-14oct11-en.pdf)
: Incidentally, [Paul Eggert's page](https://web.cs.ucla.edu/~eggert/tz/tz-link.htm), who is currently the main person in charge of : maintaining the tzdb data, summarizes a lot of important information.
: For example, in `Asia/Tokyo`, the [South Ryukyu Islands time problem](https://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E6%A8%99%E6%BA%96%E6 %99%82#South_Ryukyu_Islands%E6%99%82%E9%96%93), familiar to old BSD users. There is also the [South Ryukyu Islands Survey Report on the Time Problem](http://www.tomo.gr.jp/root/9925.html). Even relatively recently, there have been [some corrections to information during World War II](http://mm.icann.org/pipermail/tz/2018-January/025896.html).

tzdb is being maintained with the goal of including all time zone changes, especially since January 1, 1970, offset switching rules such as Daylight Savings Time, and even leap second information. tzdb is embedded in operating systems, execution environments such as Java, and libraries for various languages, and when an update is released, it is incorporated by the respective maintainers and distributed worldwide as an update incorporating the update.

Although tzdb includes information prior to January 1, 1970 to some extent, due to calendar differences and problems with historical data, there seems to be little effort to make the older information accurate.  In particular, the policy seems to be to define time zone IDs only for "time zones that still need to be distinguished after 1970. For example, it was proposed to create `America/Sao_Paulo` to represent Daylight Saving Time, which was implemented in 1963 in some areas including Sao Paulo, Brazil (https://mm.icann.org/pipermail/tz/2010-January/016007. html). html) to represent Daylight Savings Time, which was implemented in 1963 in some parts of the world, but was rejected [due to this policy](https://mm.icann.org/pipermail/tz/2010-January/016010.html).

It is also thought that "accurate" cannot be defined in the first place, since there are variations in the interpretation of old history.

Military time zones
--------------------

I'm sure many of you have seen the notation for `UTC` with a single `Z` character. This comes from "[Military time zones](https://en.wikipedia.org/wiki/List_of_military_time_zones)", which is mainly used by the US military. It maps the uppercase alphabet (except for `J`) to 25 time zones, from `UTC-12` to `UTC+12`, in one-hour increments. Time zones that are not hourly, such as `UTC+05:30`, are sometimes called `E*` ("Echo-Star") with a `*` (star). 

: [Wikipedia (en): Indian Standard Time](https://en.wikipedia.org/wiki/Indian_Standard_Time)

Military time zones are also listed in [RFC 822](https://datatracker.ietf.org/doc/html/rfc822) and [RFC 2822](https://datatracker.ietf.org/doc/html/rfc2822). There are many languages and libraries that can handle this as standard. However, it is best not to use anything other than `Z`.

The primary reason for this is that there was an error in the description of military time zones in the early RFC 822. There have historically been several software packages that have done strange things based on that error. The error was corrected in RFC 2822, but the implementation is still the same for compatibility reasons. In addition, there are some time zones that are not supported by military time zones, such as `UTC+13`. Some time zones, such as `UTC+13`, cannot be used in military time zones. Other time zones, such as `Z`, are not well known and there seems to be little reason to use them.

Time zone abbreviations
-----------------

### JST: Jerusalem Standard Time?

Japan Standard Time (JST) is often abbreviated to `JST`. This is also [mentioned](https://github.com/eggert/tz/blob/2021a/asia#L2087-L2093) in tzdb as follows.

````
# From Hideyuki Suzuki (1998-11-09):
# 'Tokyo' usually stands for the former location of Tokyo Astronomical
# Observatory: 139 degrees 44' 40.90" E (9h 18m 58.727s),
# 35 degrees 39' 16.0" N.
# This data is from 'Rika Nenpyou (Chronological Scientific Tables) 1996'.
# edited by National Astronomical Observatory of Japan....
# JST (Japan Standard Time) has been used since 1888-01-01 00:00 (JST).
# The law is enacted on 1886-07-07.
The law is enacted on 1886-07-07.

The [definition of `Asia/Tokyo`](https://github.com/eggert/tz/blob/2021a/asia#L2166-L2168) is also as follows. (`J%sT` is a notation in which `S` (standard time) or `D` (daylight saving time) is added to `%s`. Not that daylight saving time is currently in effect in Japan.)

````
# Zone NAME STDOFF RULES FORMAT [UNTIL].
Zone Asia/Tokyo 9:18:59 - LMT 1887 Dec 31 15:00u
                        9:00 Japan J%sT
````

However, if you look at tzdb a little more, you will see that there is also a comment [referring to Jerusalem Standard Time as `JST`](https://github.com/eggert/tz/blob/2021a/asia#L1706-L1713) as follows However, if you look at tzdb a little more, you will see that there is also a comment that refers to the Jerusalem Standard Time as `JST` () as follows

````
# From Ephraim Silverberg (2001-01-11):
#
# Until then there were three
# different abbreviations in use:
# IST/IDT
# JST Jerusalem Standard Time [Danny Braniss, Hebrew University].
# IZT Israel Zonal (sic) Time [Prof. Haim Papo, Technion].
# EEST Eastern Europe Standard Time [used by almost everyone else].
````

However, the official tzdb interpretation is that `JST' as "Jerusalem Standard Time" is ruled out, as in the following comment (https://github.com/eggert/tz/blob/2021a/asia#L1715 -L1720).

````
# Since timezones should be called by country and not capital cities,
# I ruled out JST. As Israel is in Asia Minor and not Eastern Europe,
As Israel is in Asia Minor and not Eastern Europe, # EEST was equally unacceptable.
# any other timezone abbreviation, I felt that 'IST' was the way to go
# and, indeed, it has received almost universal acceptance in timezone
# settings in Israeli computers.
```.

However, "Jerusalem Standard Time" itself is still in use in many places.  It can be found in [GE Digital documentation](https://www.ge.com/digital/documentation/meridium/Help/V43070/r_apm_pla_valid_time_zones.html) and in [Windows time zone information](https://support.microsoft.com/en-us/topic/israel-and-libya-time-zone-update-for-windows-operating-systems-7c6a08aa-8c56- 4d7a-2aa8-b956602ebf0a). The fact that "Jerusalem Standard Time" still exists means that there will of course be people here who call it `JST` for short. Name conflicts are very annoying, especially in software interchange.

It is, of course, extremely difficult to change the name to something like "Israel Standard Time". This is the same reason why tzdb has decided not to use country names in IDs, but to use city names.

### Time zone abbreviations are deprecated.

Time zone abbreviations such as `JST` are easy to use at first glance, but as you can see, the abbreviation does not always uniquely identify the time zone you are looking for. Time zone abbreviations should not be used in program descriptions or in data that may be loaded into software. There is a hell of a lot of data that works for a while in your hand, and then starts to go wrong when you get a customer in another country or region.

In fact, the old Java standard API [`java.util.TimeZone`](https://docs.oracle.com/javase/jp/8/docs/api/java/util/TimeZone.html) clearly states that "three-character time zone IDs are deprecated. In fact, the old Java standard API [`java.util. In the new JSR 310 [`java.time.ZoneId`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneId.html), abbreviations are not supported by default, and the [mechanism to specify the mapping between abbreviations and time zones as a separate ZoneId](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneId.html#of-java.lang.String-java.util.Map-).

If you are unfortunate enough to have to read in data that contains timezone abbreviations, you will have no choice but to give up and type them in. Deal with it while it is still in the earliest possible stage of the data processing process. In addition, specify in the software or service specification which time zone each abbreviation should be read as.  In addition, since some abbreviations may be implicitly interpreted by Java or other processing systems or libraries, it is important to understand all the specifications of these abbreviations, and clearly state them again in the specifications of the software or service under development.

For example, "`JST` is read as `+09:00`".

If your software or service outputs data with time zone abbreviations, stop it as soon as possible. Instead, use offsets such as `+09:00` or tzdb IDs such as `Asia/Tokyo` which are region based. Whether offset or region based is better will be discussed later in the "Implementation" section, but in any case, abbreviations are not allowed. If you can't stop using abbreviations for compatibility or other reasons, make this all part of the specification.

Time zone abbreviations should only be used in person-to-person communication where the context is clear. Here are a few more problems caused by time zone abbreviations.

### CST

A more obvious example of an abbreviation conflict than `JST` is `CST`. It's even [explicitly mentioned in the Javadoc for `java.util.TimeZone`](https://docs.oracle.com/javase/jp/8/docs/api/java/util/TimeZone.html).

If you work as a software engineer in Japan or the United States, you may know `CST` as "[Central Standard Time]"(https://ja.wikipedia.org/wiki/%E4%B8%AD%E9%83%A8%E6%A8%99%E6% If you work as a software engineer in Japan or the United States, you may tend to think that `CST` means "[Central Standard Time](%96%E6%99%82)". However, "[China Standard Time (Chinese Standard Time)](https://ja.wikipedia.org/wiki/%E4%B8%AD%E5%9B%BD%E6%A8%99%E6%BA%96%E6%99%82)" is also `CST`. CST`. Furthermore, "[Cuba](https://ja.wikipedia.org/wiki/%E3%82%AD%E3%83%A5%E3%83%BC%E3%83%90) Standard Time" is also `CST`. 

These are all countries that have a complicated relationship with the United States, but I wonder if it is coincidence or inevitability.

`CST`: "China Standard Time" is [still active in tzdb](https://github.com/eggert/tz/blob/2021a/asia#L40-L55). It is neither excluded nor deprecated like `JST`: "Jerusalem Standard Time".

````
# The following alphabetic abbreviations appear in these tables.
# (corrections are welcome):
# std dst
# LMT Local Mean Time
# 2:00 EET EEST Eastern European Time
# 2:00 IST IDT Israel
# 5:30 IST India
# 7:00 WIB west Indonesia (Waktu Indonesia Barat)
# 8:00 WITA central Indonesia (Waktu Indonesia Tengah)
# 8:00 CST China
# 8:00 HKT HKST Hong Kong (HKWT* for Winter Time in late 1941)
# 8:00 PST PDT* Philippines
# 8:30 KST KDT Korea when at +0830
# 9:00 WIT east Indonesia (Waktu Indonesia Timur)
# 9:00 JST JDT Japan
# 9:00 KST KDT Korea when at +09
KDT Korea when at +09

The [definition of `Asia/Shanghai`](https://github.com/eggert/tz/blob/2021a/asia#L668-L672) for China Standard Time is as follows. The `[UNTIL]` column in the last line is blank, which means it's still valid. (`%s` is the same as `J%sT`.)

````
# Zone NAME STDOFF RULES FORMAT [UNTIL].
# Beijing time, used throughout China; represented by Shanghai.
Zone Asia/Shanghai 8:05:43 - LMT 1901
                        8:00 Shang C%sT 1949 May 28
                        8:00 PRC C%sT
````

Cuban Standard Time, [`America/Havana` defined as well](https://github.com/eggert/tz/blob/2021a/northamerica#L3373-L3376).

```
# Zone NAME STDOFF RULES FORMAT [UNTIL].
Zone America/Havana -5:29:28 - LMT 1890
                        -5:29:36 - HMT 1925 Jul 19 12:00 # Havana MT
                        -5:00 Cuba C%sT
```

### EST, EDT, CST, CDT, MST, MDT, PST, PDT

As mentioned in the `CST` conflicts section, there are several languages and libraries that preferentially handle United States time zone abbreviations, including `CST`. There are several languages and libraries that prefer to handle the United States time zone abbreviation including `CST`, such as [Ruby's `Time`](https://github.com/ruby/ruby/blob/v3_0_1/lib/time.rb#L40-L43) and [Java's old `java.util.TimeZone`](https://docs.oracle.com/ javase/jp/8/docs/api/java/util/TimeZone.html) are examples. The main reason for this is that these abbreviations are specified in [RFC 822](https://datatracker.ietf.org/doc/html/rfc822) and [RFC 2822](https://datatracker.ietf.org/doc/html/rfc2822). This seems to be the main reason why these abbreviations are specified in [RFC 822]() and [RFC 2822]().

However, these abbreviations are treated slightly differently in different software. The abbreviations used in Ruby and Java are also different, and in fact, Java is more likely to be "wrong", but for compatibility reasons, it is still partially retained. Up to now, we have managed to deal with this as a "specification", but it may come to the surface as a problem, triggered by the abolition of daylight saving time, which has been much discussed in recent years. The following is an introduction to this issue.

#### Problems with Interpreting Abbreviations: The Java Example

These abbreviations originally correspond to either Standard Time or Daylight Saving Time, respectively. For example, `PST` is just Pacific "Standard Time", and `PST` does not refer to Pacific Daylight Time. Pacific "Daylight Saving Time" is just `PDT`, Pacific "Daylight Saving Time".

That is, `PST` is always `-08:00`, and "California time switches from `PST` (`-08:00`) to `PDT` (`-07:00`) in the summer", not "`PST` becomes `-07:00` in the summer". The above [RFC 2822 also clearly states that `PST is semantically equivalent to -0800`, etc.](https://datatracker.ietf.org/doc/html/rfc2822#section-4.3).

Ruby's `Time` has an implementation along these lines](https://github.com/ruby/ruby/blob/v3_0_1/lib/time.rb#L40-L43). Ruby's `Time` always treats `PST` as `-8`, and `PDT` as `-7`. This is the correct interpretation.

However, the old Java standard API (and its inheritor [Joda-Time](https://www.joda.org/joda-time/)) treats it differently. It maps abbreviations such as `PST` to region-based timezone IDs such as `America/Los_Angeles`. At first glance, this looks good, but what's the problem?

The string `2020-07-01 12:34:56 PST`, a combination of `2020-07-01 12-34-56` (daylight saving time in California) and `PST`, should be interpreted as `2020-07-01 12:34:56 -08:00`. However, the old Java standard API maps this `PST` to `America/Los_Angeles`, so it becomes `2020-07-01 12:34:56 America/Los_Angeles`. Then this will eventually be interpreted as `2020-07-01 12:34:56 -07:00`, since `2020-07-01` is daylight saving time in California.

You might be thinking, "It's obvious that July 1, 2020 is daylight saving time, so why write `2020-07-01 12:34:56 PST` in the first place? ...But is that really all there is to it?

The same thing happens with `MST` (Mountain Standard Time). The old Java API maps `MST` to `America/Denver`. Colorado, where Denver is located, has daylight saving time, so `America/Denver`, which is `-07:00` in winter, becomes `-06:00` in summer. This is the same situation as `PST`, and the same argument as above, "`2020-07-01 12:34:56 MST` is bad to write", is certainly true for Denver.

Another state that uses the same "Mountain Time" is Arizona. As I mentioned in "Time Zone Definitions and Usage" above, Arizona has not adopted Daylight Savings Time, except for a few places. This means that `2020-07-01` combined with `MST`, `2020-07-01 12:34:56 MST`, is an expression that should be valid in Arizona, except for some parts, and it should be interpreted as `2020-07-01 12:34:56 -07:00`. However, the Java API interprets it as `2020-07-01 12:34:56 -06:00`.

This can be easily verified by the following Java code. 

: This sample code uses the newer JSR 310 `DateTimeFormatter` instead of the older Java API, but shows the same behavior. If you go back in the history of this Java and timezone abbreviation, it was actually fixed once in the old API. However, JSR 310 `DateTimeFormatter` also reintroduced this behavior in some functions, and this sample code is an example of it. Actually, I tried to dig a little deeper, but it turned out to be a long story, so I'll leave that story to [Java Edition](. /curse-of-timezones-java-ja) as a "bonus". If you are interested in it, please see there.

```java
import java.time.format.DateTimeFormatter;
import java.time.ZonedDateTime;

public final class MountainTime {
    public static void main(final String[] args) throws Exception {
        System.out.println(ZonedDateTime.parse("2020/01/01 12:34:56 MST", FORMATTER));
        System.out.println(ZonedDateTime.parse("2020/01/01 12:34:56 MDT", FORMATTER));
        System.out.println(ZonedDateTime.parse("2020/07/01 12:34:56 MST", FORMATTER));
        System.out.println(ZonedDateTime.parse("2020/07/01 12:34:56 MDT", FORMATTER));

        // America/Phoenix is in Arizona, which has not adopted Daylight Savings Time.
        System.out.println(ZonedDateTime.parse("2020/01/01 12:34:56 America/Phoenix", FORMATTER));
        System.out.println(ZonedDateTime.parse("2020/01/01 12:34:56 America/Phoenix", FORMATTER));
        System.out.println(ZonedDateTime.parse("2020/07/01 12:34:56 America/Phoenix", FORMATTER));
        System.out.println(ZonedDateTime.parse("2020/07/01 12:34:56 America/Phoenix", FORMATTER));
    }

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss zzz");
}
````

This output will look like this (Here we have checked with Java 8, but we have confirmed that the result is similar with OpenJDK 16.0.1.)

```
$ java -version
openjdk version "1.8.0_292"
OpenJDK Runtime Environment (build 1.8.0_292-8u292-b10-0ubuntu1~20.04-b10)
OpenJDK 64-Bit Server VM (build 25.292-b10, mixed mode)

$ java MountainTime
2020-01-01T12:34:56-07:00[America/Denver].
2020-01-01T12:34:56-07:00[America/Denver].
2020-07-01T12:34:56-06:00[America/Denver][America/Denver
2020-07-01T12:34:56-06:00[America/Denver][America/Denver
2020-01-01T12:34:56-07:00[America/Phoenix][America/Phoenix
2020-01-01T12:34:56-07:00[America/Phoenix][America/Denver
2020-07-01T12:34:56-07:00[America/Phoenix][America/Phoenix][America/Phoenix
2020-07-01T12:34:56-07:00[America/Phoenix][America/Phoenix
````

Let's recall that we were told that "California's 2018 referendum supported the abolition of Daylight Savings Time.

In the case of `America/Denver`, which corresponds to `MST`, this Denver was in the majority for adopting Daylight Savings Time, with the minority exception of Arizona, which did not adopt Daylight Savings Time. On the other hand, California is the only state that is currently discussing abolishing daylight saving time. Not adopting daylight saving time is by far the minority. And `America/Los_Angeles`, which corresponds to `PST`, is in California. It is possible that in the future `PST` will correspond to the minority exception.

As for timezone abbreviations, I'm not sure what will happen in the future. Even the commonly used `PST` is in this state. It is worth writing this chapter if it makes you think "time zone abbreviations are scary".

Development: Dates and Calendars
===============

So far, we have mainly looked at the period (day and time) associated with the earth's rotation. Now, what about the period (year and date) associated with the earth's rotation?

Although there are some cultures that have calendars unique to each country or region, such as the lunar calendar and the Japanese Gengo, the Gregorian calendar has now become widespread as the so-called Western calendar, and has come to be established as a common language, at least technically. As long as you only use the Gregorian calendar for dates in the last few decades, you are unlikely to have any misery with the calendar.

However, once you start dealing with dates from the past, the story of calendars is as vast and dark as time and time zones. The Julian calendar, a pre-Gregorian calendar, and the pre-Gregorian calendar, a forced application of the Gregorian calendar to the Gregorian calendar, are just two of the many types of calendars that can throw software engineers into confusion.

However, if I were to cover the issue of calendars in this article, it would more than double the size of the article. Here is a very well organized blog post to replace it.

["Is a Year in the West a Leap Year? (Blog post by Yuki Nagise, October 30, 2020)](https://nagise.hatenablog.jp/entry/2020/10/30/173911)

And on to implementation.
=============

I could go on and on about this tricky concept of time and time zones. However, I think we've covered the general knowledge to some extent.

So, what should we pay attention to when we put this knowledge into concrete implementation?

In [an old article on Qiita in 2018](https://qiita.com/dmikurube/items/15899ec9de643e91497c), I introduced implementation using Java as a concrete example. In addition, in [the December 2018 issue of Software Design magazine](https://gihyo.jp/magazine/SD/archive/2018/201812), I wrote a general discussion of implementations not limited to Java. In this article, I incorporated the contents of the Software Design magazine and also added Java-specific topics, which resulted in a significant increase in the overall volume of the article. Therefore, I decided to separate the general discussion of implementation and Java-specific topics into two separate articles.

* [The Book of the Timezone Curse (Implementation)](. /curse-of-timezones-impl-ja)
* [Curse of timezones (Java version)](. /curse-of-timezones-java-ja)

I've only linked to the implementation and Java editions by the same author here, but if you can tell me about articles by other people that summarize stories about other languages, software, etc., I may be able to introduce them here. 

There are many topics that I would like to read in depth, such as : Ruby (especially Ruby on Rails), web browser environment including JavaScript (`temporal`), and MySQL, PostgreSQL and JDBC. I may be able to write a little about Ruby (other than Rails) and Linux, but I'd rather leave it to those who really know their stuff.

Extra: Environment variable TZ
====================

The environment variable `TZ` was used to set the time zone of (especially Unix-like) operating systems.  Originally, tzdb itself was maintained as the source data for `zoneinfo`, which was also the backbone of the `TZ` environment variable.

It is still the same today.

If I were to start explaining how `TZ` is set and how it is reflected in actual behavior, I would have to write another long article, so I won't do that in this article.  However, since the `TZ` "format" appears in many places, I thought it would be better to mention it lightly in this "Knowledge" section, and decided to add it as an extra.

I've decided to add it as an addition to the "Knowledge" section. : Please write a "Unix(-like)" section and explain it in detail, including its history.

UTC+9? JST-9?
--------------

Japan time is 9 hours ahead of UTC, which is generally referred to as `UTC+9` or `UTC+09:00` as mentioned above. On the other hand, many of you may have set the environment variable `TZ` to `JST-9`.

The sign is reversed between `+` and `-`, and it is confusing, isn't it?

This `TZ` format is a so-called historical situation. I won't go into the historical details, but a generalized version of this format is now clearly documented as part of [POSIX](https://ja.wikipedia.org/wiki/POSIX). There is also an explanation in the glibc manual.

Environment Variables, The Open Group Base Specifications Issue 7, 2018 edition.](https://pubs.opengroup.org/onlinepubs/9699919799/) basedefs/V1_chap08.html)

: [21.5.6 Specifying the Time Zone with TZ, The GNU C Library](https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html#TZ- Variable)

The format is taken from POSIX. (Whitespace characters are added by the author for clarity.)

````
std offset [dst [offset] [,start[/time],end[/time]]]
```` std offset

The required field is `std offset`, right? The `JST` part of `JST-9` is for `std`, and the next `-9` is for `offset`. The `JST` is an abominable time zone abbreviation, but this is hard to control due to history. The `offset` is explained as follows.

> Indicates the value added to the local time to arrive at Coordinated Universal Time.

Indicates the value added to the local time to arrive at Coordinated Universal Time. Japan time is 9 hours ahead of UTC, so "adding the negative value `-9` to Japan time makes it UTC". The reason why Japan time is `-` as in `JST-9` is that it is, by definition, that way.

PST8PDT
--------

Now let's look at the format of `TZ` again.

```
std offset [dst [offset] [,start[/time],end[/time]]]
```

Japan time is simple, `JST-9`, but the generalized format is kind of long. There are a number of non-mandatory `[...]] `, there are a number of `dst` entries. What is this `dst` and what is the second `offset`?

You may have seen time zone abbreviations for the United States, such as `PST8PDT` and `EST5EDT`, which are not just `PST` or `EDT`. This is the notation that uses up to `std offset [dst]`. For example, `PST8PDT` means "Standard Time is `PST`, add `8` hours to get UTC. And daylight saving time is `PDT`.

This format is valid for time zones other than the United States, such as `GMT0BST` in the United Kingdom, or `CET-1CEST` in France and Germany. For example, you can write `GMT0BST` in the UK, or `CET-1CEST` in France and Germany, or `JST-9JDT` when daylight saving time is introduced in Japan. However, only `PST8PDT`, `MST7MDT`, `CST6CDT`, and `EST5EDT` in the United States are given special treatment by some, for example [the corresponding entries are written directly in tzdb](https://github.com/eggert/tz/ blob/2021a/northamerica#L203-L206).

````
Zone EST5EDT -5:00 US E%sT
Zone CST6CDT -6:00 US C%sT
Zone MST7MDT -7:00 US M%sT
Zone PST8PDT -8:00 US P%sT
````

If the second `offset` is omitted, the default interpretation is "daylight saving time is one hour ahead of standard time". In most countries and regions with a daylight saving time system, daylight saving time precedes standard time by one hour, so the second `offset` is almost never written. On Lord Howe Island, a rare exception, it is apparently written as `LHST-10:30LHDT-11`.

After that, there is almost no chance to write `[,start[/time],end[/time]]]` directly. If you are interested, please read the POSIX and glibc manuals.

TZ=Asia/Tokyo
--------------

As someone who has been using Unix-like environment for a long time, I feel that `JST-9` is the best way to set `TZ`, but at least nowadays, you can set tzdb ID directly to `TZ`, such as `TZ=Asia/Tokyo`, and often do so. 

But at least now you can set the tzdb ID directly to `TZ`, such as `TZ=Asia/Tokyo`, which seems to be the case in many cases. I think it was common to set `TZ=JST-9` when I started to work with Unix-like environment around 2000, and I don't know when the implementation or convention changed. If you have any information, please send it to me. (Or perhaps a "Unix version"...)

Considering that it is better not to use timezone abbreviations in the first place (see above), and that this notation is not very versatile, I think it is better to use tzdb IDs for `TZ` nowadays. 

For example, if we abolish daylight saving time only in California, we have to change `TZ=PST8PDT` to `TZ=PST8` for California environment. If you set `TZ=America/Los_Angeles` from the beginning, you only need to update tzdb.
: [Paul Eggert's page](https://web.cs.ucla.edu/~eggert/tz/tz-link.htm) has some statements in support of this.
