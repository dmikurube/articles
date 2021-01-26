---
title: "タイムゾーン略称の闇"
emoji: "🌐" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [ "timezone" ]
layout: default
---

3年ほど前に Qiita で「[タイムゾーン呪いの書](https://qiita.com/dmikurube/items/15899ec9de643e91497c)」という記事を書いた [@dmikurube](https://zenn.dev/dmikurube) です。 [^curse]

[^curse]: この呪いの書も改訂の上で Zenn に移そうかなあ、と思っているのですが、改訂が進んでいなくてまだそのままになっております。

さて、この呪いの書の中で、筆者は以下のようなことを書きました。

> 3文字4文字のタイムゾーン略称は一見使いやすいのですが、このように、実は一意に特定できるものではありません。このことから、少なくともソフトウェアに再度読み込ませる可能性のあるデータを出力するのに `"JST"` のような略称を用いるのはできるだけ避けましょう。

> 詳しくは後述しますが、出力の際は多くの場合 `"+09:00"` などの固定オフセットを用いるのがいいでしょう。どうしても地域ベースのタイムゾーン名を使わなければならない場合も、少なくとも `"Asia/Tokyo"` などの tz database 名を使いましょう。

このタイムゾーン略称に関する記述は記事を書いたあとも筆者が繰り返し主張してきたことで、記事の中でも反応の多かったところです。[^reactions] しかし、「は？ アホ？」みたいな反応を見かけたこともあり、また、残念ながら身近で略称の使用を食い止められなかった事例もありました。

[^reactions]: いただいた反応の大部分は「知らなかった」「気をつけよう」といったものでした。念のため。

本記事はそんな方々 [^abbreviation-fans] に捧げます。とりあえず下の表を眺めれば、言いたいことはわかるでしょう。

[^abbreviation-fans]: 本記事は「`Asia/Tokyo` とか書くのは長ったらしいし現在は `JST` で特定できるんだから略称の方が実用的」などとのたまう人々を **物量でぶん殴る** ことを主目的として執筆されています。一つ一つ詳細に読んでもらおうという主旨の記事ではありませんが、世のタイムゾーン略称の解釈はこんなバラバラなのかという闇を、ぜひ物量で実感してください。

**ふるえて眠れ**

# Contributions

「ここは間違っている」「他にもこんな事例がある」などの情報提供はいつでもお待ちしております。本記事へのコメント、または[リポジトリ](https://github.com/dmikurube/writings)への pull request でぜひお送りください。

# 各処理系の略称解釈 (違いがあるものを抜粋)

<!-- https://github.com/zenn-dev/zenn-roadmap/issues/104 -->

| \    | Java                      | Joda-Time                 | Ruby       | PostgreSQL     | timeanddate.com [↓](#timeanddate.com) |
| ---- | ------                    | --------                  | ---------- | ----           | ---- |
| ADT  | N/A                       | N/A                       | -03:00     | -03:00         | Atlantic Daylight (-3)$\\$Arabia (+4) |
| ART  | Africa/Cairo (+02:00)     | Africa/Cairo (+02:00)     | -03:00     | -              | Argentina (-3) |
| AST  | America/Anchorage (-9:00) | America/Anchorage (-9:00) | -04:00     | -04:00         | Atlantic (-4)$\\$Arabia (+3) |
| AT   | N/A                       | N/A                       | -02:00     | N/A            | |
| BST  | N/A                       | N/A                       | -02:00     | N/A            | |

# 各処理系の事情について解説

## Java

### Java 1.1

かなり初期の Java 1.1 の頃には既に `java.util.TimeZone` [^java-1.1-TimeZone] でいくつかのタイムゾーン略称を扱っていたようです。しかし、その略称の解釈がボロボロもいいところだったようです。

[^java-1.1-TimeZone]: [The Java Version Almanac の Java 1.1 の `java.util.TimeZone`](https://javaalmanac.io/jdk/1.1/api/java.util.TimeZone.html)

MIT のサイトから [IBM Java 1.1.6 の `java.util.TimeZone` のソースコードらしきもの](http://web.mit.edu/java_v1.1.6/distrib/sun4x_57/src/java/util/TimeZone.java)が参照でき、この中の `compatibilityMap` という定数でいくつかの略称が定義されていることが確認できます。そのコメント中に `Note in particular that these three-letter IDs are completely wrong in some cases, and do not represent the correct abbreviations in common use.` と書かれているとおり `AST` や `ART` など、間違いだと言い切れるようなものがいくつかあります。

もっとも、このファイルは IBM Java のものであって Sun Java ではなさそうです。しかし `compatibilityMap` は互換性を気にしての定義のようなので、おそらく Sun のものでも同様だったであろうと推測はできそうです。 (詳細をご存知の方はぜひお知らせください)

近年の Java で直接これらを考慮する必要はないと断言していいと思います。しかし、現代のライブラリでもこのころのタイムゾーン略称の影響が互換性のために残されていると思われるものがいくつかあるため、参考のために記載しています。

### Java 1.3

Java 1.2 ではまだ標準的にタイムゾーン略称が扱われていた [^java-1.2-TimeZone] ようですが、その後 Java 1.3 には既に非推奨となっていたようです。 Java 1.3 の `java.util.TimeZone` の Javadoc [^java-1.3-TimeZone] には以下のような記述が確認できます。

[^java-1.2-TimeZone]: [The Java Version Almanac の Java 1.2 の `java.util.TimeZone`](https://javaalmanac.io/jdk/1.2/api/java/util/TimeZone.html)

[^java-1.3-TimeZone]: [The Java Version Almanac の Java 1.3 の `java.util.TimeZone`](https://javaalmanac.io/jdk/1.3/api/java/util/TimeZone.html)

> For compatibility with JDK 1.1.x, some other three-letter time zone IDs (such as "PST", "CTT", "AST") are also supported. However, their use is deprecated because the same abbreviation is often used for multiple time zones (for example, "CST" could be U.S. "Central Standard Time" and "China Standard Time"), and the Java platform can then only recognize one of them.

### Java SE 8: Date and Time API

その後 Java では [Java 8 から Date and Time API](https://www.oracle.com/technical-resources/articles/java/jf14-date-time.html) が導入されました。 [^java-8-date-and-time-ja]

[^java-8-date-and-time-ja]: [日本語版記事 "Java SE 8 Date and Time"](https://www.oracle.com/technetwork/jp/articles/java/jf14-date-time-2125367-ja.html)

### もう一つの間違い: tzdb への対応付け

Java はタイムゾーン略称についてもう一つ大きな間違いを犯しています。 `PST` などの略称を `America/Los_Angeles` などの tz database 地域ベースタイムゾーン名に対応付けてしまったことです。

「え、なんで? tz database の名前だったらいいんじゃないの?」と思われるかもしれません。

しかし "Pacific Standard Time (PST)" はあくまで Pacific "Standard Time" であり "Daylight Time" (夏時間) ではありません。 "Pacific Standard Time" が指すのは常に `-08:00` であり、夏になると「『カリフォルニア時間』が `PST` (`-08:00`) から `PDT` (`-07:00`) に移行する」のであって「"Pacific Standard Time" が夏になると `-07:00` になる」わけではありません。メールのヘッダーなどが定義される [RFC 2822](https://tools.ietf.org/html/rfc2822) でも、明確に `PST is semantically equivalent to -0800` と記述されています。

つまり、夏時間期間である2020年7月1日のある時刻を表現した文字列 `"2020-07-01 12:34:56 PST"` は、本来 `"2020-07-01 12:34:56 -08:00"` と同等に解釈しなければならないのですが、このあたりの Java の API はこれを `"2020-07-01 12:34:56 America/Los_Angeles"` と解釈し、これは `"2020-07-01"` という日付をもとに `"2020-07-01 12:34:56 -07:00"` と同等に解釈されてしまうのです。

「2020年7月1日が夏時間なのは明らかなんだから `"2020-07-01 12:34:56 PST"` なんて書かないし書くほうが悪いんじゃ」と思われるかもしれません。しかし本当にそうでしょうか?

`PST` は今のところ問題ないかもしれません。 [`timeanddate.com` を見ると、アメリカ大陸で "Pacific Time" (`PT`) を採用している都市は、この記事を書いている 2021 年初頭の時点では、基本的に夏時間も採用しているようです。](https://www.timeanddate.com/time/zones/pst)

しかし同様のことは "Mountain Standard Time" (MST) でも起きていました。[初期の Java](http://web.mit.edu/java_v1.1.6/distrib/sun4x_57/src/java/util/TimeZone.java) では `java.util.TimeZone` は `MST` を `America/Denver` と同等に解釈していました。 Denver のあるコロラド州は夏時間を採用しているので、冬に `-07:00` だった `MST` は、夏には `-06:00` と解釈されるようになります。しかし [`timeanddate.com`](https://www.timeanddate.com/time/zones/mst) によれば "Navajo Nation" を除くアリゾナ州は夏時間を採用していません。ということは `"2020-07-01 12:34:56 MST"` という表記は "Navajo Nation" を除くアリゾナ州では有効であり、これは `"2020-07-01 12:34:56 -07:00"` と解釈されなければならないのに `java.util.TimeZone` を使うと `"2020-07-01 12:34:56 -06:00"` と解釈されてしまったのです。

2006 年ごろ以降 の Java から、この `MST` や、同様の問題がある `EST` と `HST` のマッピング先が tzdb 名ではなくオフセット (`-07:00` など) になり、それ以前との互換性が必要なアプリケーションでは Java のシステムプロパティ `sun.timezone.ids.oldmapping` を明示的に `"true"` に設定することで古いマッピングで動作するようになる、という形になりました。 [^java-oldmapping]

[^java-oldmapping]: [IBM Java についての公式記事](https://www.ibm.com/support/pages/java-daylight-saving-time-known-problems-and-workarounds) や [Oracle Communities の discussion](https://community.oracle.com/tech/developers/discussion/2539847/est-mst-and-hst-time-zones-in-java-6-and-java-7) に加えて、この [Stack Overflow](https://stackoverflow.com/questions/41567101/why-are-3-letter-abbreviations-for-us-timezones-inconsistent-with-respect-to-day) が参考になりそうです。

さらに、最近カリフォルニア州では、夏時間を廃して夏も冬も常に `-07:00` (2020 年現在の `PDT` 相当) にしようという動きが活発で、[住民投票でも賛成多数となった](https://www.jetro.go.jp/biznews/2018/11/f4ab9860d030abf0.html)ようです。仮にこれが実現すると `"20XX-01-01 12:34:56 PST"` (冬) や `"20XX-07-01 12:34:56 PST"` (夏) がどういうことになるか…わかりますね? 今でも `java.util.TimeZone` は `PST` を `America/Los_Angeles` (カリフォルニア州) と解釈していますが、一方で "Pacific Time" を採用する州はカリフォルニア州以外にもたくさんあります。

## Joda-Time

xxx

## Ruby

ここで "Ruby" として挙げているのは Ruby の [`date` ライブラリ](https://docs.ruby-lang.org/ja/latest/class/Date.html) で使われるものです。 `DateTime.strptime` や `Date._strptime` などで使われます。

```ruby
irb(main):001:0> require 'date'
irb(main):002:0> DateTime.strptime('2002-03-14T11:22:33 JST', '%Y-%m-%dT%H:%M:%S %Z')
=> #<DateTime: 2002-03-14T11:22:33+09:00 ((2452348j,8553s,0n),+32400s,2299161j)>
irb(main):003:0> Date._strptime('2002-03-14T11:22:33 ADT', '%Y-%m-%dT%H:%M:%S %Z')
=> {:year=>2002, :mon=>3, :mday=>14, :hour=>11, :min=>22, :sec=>33, :zone=>"ADT", :offset=>-10800}
```

この中にも [`CAT`](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L65) や [`BT`](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L86) など、一般的とはおよそ言い難い略称解釈が含まれています。この略称周りの Ruby リポジトリ中での初出は [2002 年ごろ](https://github.com/ruby/ruby/commit/dc9cd6a8c22ad04baa7498fd0cbc5d519ed73be0)で、出典は `date2` や `parsedate(2)` ライブラリに行き着くようなのですが、その前まではたどれていません。「[日付解析の手法](https://www.funaba.org/date2/parsedate)」や [[ruby-dev:9489] parsedate2](http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-dev/9489) あたりが参考になりそうです。

ちなみに [`time` ライブラリ](https://docs.ruby-lang.org/ja/latest/class/Time.html) の方の `Time.strptime` では、このあたりの略称解釈は使われません。

```ruby
irb(main):001:0'> require 'time'
=> true
irb(main):002:0> Time.strptime('2002-03-14T11:22:33 JST', '%Y-%m-%dT%H:%M:%S %Z')
=> 2002-03-14 11:22:33 +0000

# ここでは "JST" が解釈されず、デフォルトのタイムゾーンが使われた結果として "+0000" に
# なっていることに注意しましょう。
#
# システム時刻が日本時間だったり環境変数 TZ が "JST" だったりするとこれが "+0900" になり、
# 「あれ "JST" は解釈されてるじゃん」と勘違いするかもしれないので気をつけましょう。
# この実行結果は "env TZ=UTC irb" とデフォルトを明示的に UTC にして実行したものです。
```

近年の Ruby では `Date` や `DateTime` はあまり使わず `Time` のみを使ったほうがいいという話もあるらしい [^modern-Ruby-Date] ので、もう `Date` と `Date` のタイムゾーン略称のことは気にしなくてもいいのかもしれません。しかし [2019 年にもなって `Date` にわざわざ新しいタイムゾーン略称を追加](https://github.com/ruby/date/pull/16) したりもしていて、まったく油断ならねえな…、などと思う次第です。この時点で解釈に曖昧性がなかったもののみを採用したようではありますが、今後も曖昧にならない保証はありませんね。罪深い。

[^modern-Ruby-Date]: @[tweet](https://twitter.com/sonots/status/936541110771449858)

## PostgreSQL

[PostgreSQL](https://www.postgresql.org/) が 8.1 まで採用していたタイムゾーン略称にも、いくつか独特なものがありました。

* [PostgreSQL 8.1: B.2. Date/Time Key Words](https://www.postgresql.org/docs/8.1/datetime-keywords.html)

PostgreSQL は 8.2 (2006年ごろ) からタイムゾーン略称があまり標準化されたものではないことを認知し、略称とタイムゾーンのマッピングは、管理者がその責任において実行時パラメータとして設定しなければならないものだとしたようです。これは英断だったと言っていいでしょう。

* [PostgreSQL 8.2: B.3. Date/Time Configuration Files](https://www.postgresql.org/docs/8.2/datetime-config-files.html)
* [PostgreSQL 13: B.4. Date/Time Configuration Files](https://www.postgresql.org/docs/13/datetime-config-files.html)

もっとも、互換性のために `Default` では以前と同じ略称が使われます。そのため、他と違いがあることは変わらず意識する必要があるでしょう。

## timeanddate.com

`timeanddate.com` はノルウェー Stavanger 市を拠点とする Time and Date AS が運営するサイトで "the world's top-ranking website for time and time zones" [^timeanddate] だそうです。

「処理系」というわけではありませんが、世界各地のタイムゾーンに関する情報をかなり高いレベルで網羅しているため、信頼できる公平な情報源の一つとして記載しています。

[^timeanddate]: [Time and Date AS](https://www.timeanddate.com/company/)

# 各タイムゾーン略称

## `ADT`

`ADT` は [`timeanddate.com`](https://www.timeanddate.com/time/zones/adt) を見ると "Atlantic Daylight Time" (`-03:00`) と解釈されることが主なようですが、同じ [`timeanddate.com` に "Arabia Daylight Time" (`+04:00`) も](https://www.timeanddate.com/time/zones/adt)見つかります。

著者は `ADT` を `+04:00` として解釈するような処理系はいまのところ見つけていません。 [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L52) と [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) はともに "Atlantic Daylight Time" (`-03:00`) として扱っています。

## `ART`

`ART` は [`timeanddate.com`](https://www.timeanddate.com/time/zones/art) によれば "Argentina Time" (`-03:00`) と解釈するのが一般的なようです。 [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L51) もこの解釈に準じています。

しかし [Java](http://web.mit.edu/java_v1.1.6/distrib/sun4x_57/src/java/util/TimeZone.java) では、古くから `java.util.TimeZone` で `ART` を "(Arabic) Egypt Standard Time" (`Africa/Cairo`, `+02:00`) だとする定義があったようです。この古いマッピングは、[現代の JDK](https://github.com/openjdk/jdk/blob/jdk-17%2B6/src/java.base/share/classes/sun/util/calendar/ZoneInfoFile.java#L222) にも脈々と受け継がれています。

## `AST`

`AST` は [`timeanddate.com`](https://www.timeanddate.com/time/zones/ast) によれば "Atlantic Standard Time" (`-04:00`) と解釈するのが一般的なようです。 [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L56) も [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) もこの解釈に準じています。

しかし [Java](http://web.mit.edu/java_v1.1.6/distrib/sun4x_57/src/java/util/TimeZone.java) では、古くから `java.util.TimeZone` で `AST` を "Alaska Standard Time" (`America/Anchorage`, -09:00) だとする定義があったようです。この古いマッピングは、[現代の JDK](https://github.com/openjdk/jdk/blob/jdk-17%2B6/src/java.base/share/classes/sun/util/calendar/ZoneInfoFile.java#L223) にも脈々と受け継がれています。

## `AT`

`AT` という二文字単体のタイムゾーン略称は、正直あまり一般的ではありません。しかし [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L97) は `AT` を `-02:00` と解釈します。

Ruby のコード履歴の中からこの出典を追うことはできませんでしたが、いろいろ調べてみると [MHonArc](https://www.mhonarc.org/MHonArc/doc/resources/timezones.html) に出てくる "Azores Time" が `-02:00` 相当 (当該ページ上では正負が逆転していますがこれは `JST-9` 的な正負) になっていて、おそらくこのあたりに由来があるんじゃないか、と推測しています。

ちなみに "Azores Time" (`Atlantic/Azores`) は現代では冬時間 `-01:00` 夏時間 `+00:00` となっていて、前述の Ruby や MHonArc のものからは違っているあたりも物悲しさがあります。

## `BST`

`BST` は [`timeanddate.com`](https://www.timeanddate.com/time/zones/bst) によれば "British Summer Time" (`+01:00`) と解釈するのが一般的なようです。 [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L70) や [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) もこの解釈に準じています。

しかし [Java](http://web.mit.edu/java_v1.1.6/distrib/sun4x_57/src/java/util/TimeZone.java) では、古くから `java.util.TimeZone` で `BST` を "Bangladesh Standard Time" (`Asia/Dacca`, `+06:00`) だとする定義があったようです。この古いマッピングは、[現代の JDK](https://github.com/openjdk/jdk/blob/jdk-17%2B6/src/java.base/share/classes/sun/util/calendar/ZoneInfoFile.java#L225) にも脈々と受け継がれています。 (ちなみに昔と今では `Asia/Dacca` と `Asia/Dhaka` という違いもあったんだなあ、なんていうことも見えてきます。)

## `BT`

`BT` という二文字単体のタイムゾーン略称は、正直あまり一般的ではありません。しかし [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L86) は `BT` を `+03:00` と解釈します。

Ruby のコード履歴の中からこの出典を追うことはできませんでしたが、いろいろ調べてみると [MHonArc](https://www.mhonarc.org/MHonArc/doc/resources/timezones.html) に出てくる "Baghdad Time" が `+03:00` 相当 (当該ページ上では正負が逆転していますがこれは `JST-9` 的な正負) になっていて、おそらくこのあたりに由来があるんじゃないか、と推測しています。

## `CAT`

`CAT` というと、現代では [`timeanddate.com` によれば "Central Africa Time" (`+02:00`) と解釈するのが一般的](https://www.timeanddate.com/time/zones/cat)なようです。 Java でも[古くも](http://web.mit.edu/java_v1.1.6/distrib/sun4x_57/src/java/util/TimeZone.java)[新しくも](https://github.com/openjdk/jdk/blob/jdk-17%2B6/src/java.base/share/classes/sun/util/calendar/ZoneInfoFile.java#L226)この定義を採用しています。

しかし [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L65) と [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) は `CAT` を "Central Alaska Standard Time" (`-10:00`) と解釈する立場を取っています。

この "Central Alaska Time" が「間違い」かというと、そうも言い切れないようです。 [`worldtimezone.com`](https://www.worldtimezone.com/wtz-names/wtz-cat.html) という別のサイトを見ると "CAT (until 1967): Central Alaskan Standard Time" と書いてあるのがわかります。

[Wikipedia の "Alaska Time Zone"](https://en.wikipedia.org/wiki/Alaska_Time_Zone) に曰く 1966 年に U.S. で施行された ["Uniform Time Act"](https://en.wikipedia.org/wiki/Uniform_Time_Act) (統一時間法) 以降、これまで "Central Alaska Standard Time" (`CAT`) と呼ばれていたタイムゾーンが "Alaska-Hawaii Standard Time" (`AHST`) と呼ばれるようになったため、そこから `CAT` で "Central Alaska Standard Time" を指すことは減っていったのだろうと推測されます。

> The Standard Time Act of 1918 authorized the Interstate Commerce Commission to define each time zone. The United States Standard Alaska Time was designated as UTC−10:00. Some references prior to 1967 refer to this zone as Central Alaska Standard Time (CAT) or as Alaska Standard Time (AST). In 1966, the Uniform Time Act renamed the UTC−10:00 zone to Alaska-Hawaii Standard Time (AHST), effective April 1, 1967. This zone was renamed in 1983 to Hawaii-Aleutian Standard Time when the majority of Alaska was moved out of the zone.

しかしそれもすぐにゼロにはならず、まだ "Central Alaska Standard Time" が生きているうちに一部のソフトウェア [^cat-origin] に実装され、それを参考にして別のソフトウェアでも実装され…、というような歴史があったのかもしれません。なんていうことを考えると ~~歴史は奥が深い~~ 適当にタイムゾーン略称を用いることがいかに後世に禍根を残す悪行かがわかりますね。

[^cat-origin]: 調べてないですが、大元はどこかの UNIX あたりでしょうか。誰か調査求む。

## `CCT`

`CCT` は [`timeanddate.com`](https://www.timeanddate.com/time/zones/cct) によれば "Cocos Islands Time" (`+06:30`) と解釈するのが一般的なようです。

しかし [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L96) と [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) は `CCT` を "China Coastal Time" (中国湾岸時間; `+08:00`) と解釈する立場を取っています。

この "China Coastal Time" というのを調べても PostgreSQL 関連以外になかなか例が見つからないのですが、[アメリカ地質調査所 (United States Geological Survey; USGS)](https://help.waterdata.usgs.gov/code/tz_query?fmt=html) が使っているタイムゾーン略称で "China Coastal Time" を `CCT` としているようです。

## `CDT`

`CDT` は [`timeanddate.com`](https://www.timeanddate.com/time/zones/cdt) を見るまでもなく "Central Daylight Time" (`-05:00`) と解釈するものだと思われています。 [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L16) や [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) も実際そう解釈します。

しかし [`timeanddate.com`](https://www.timeanddate.com/time/zones/cdt-cuba) によると "Cuba Daylight Time" (`-04:00`) も同様に `CDT` です。近いだけにややこしくなりそうですね。

また Java 絡みでは前述したように、一部のタイムゾーン略称を tz database 名に対応付けていることによる問題があります。夏時間の略称 (`?DT`) は Java 標準には入っておらず Java 標準では問題は起こらないのですが、標準 [Java Date and Time API](https://www.oracle.com/technetwork/jp/articles/java/jf14-date-time-2125367-ja.html) の前身となった [Joda-Time](https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeUtils.java#L445) は `CDT` を `America/Chicago` に対応付けています。このことで起こる問題は前の記述を確認してください。

## `CST`

`CST` は [`timeanddate.com`](https://www.timeanddate.com/time/zones/cst) を見るまでもなく "Central Standard Time" (`-06:00`) と解釈するものだと思われています。 [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L15) や [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) も実際そう解釈します。

しかし `timeanddate.com` によると "[Cuba Standard Time](https://www.timeanddate.com/time/zones/cst-cuba)" (`-05:00`) も "[China Standard Time](https://www.timeanddate.com/time/zones/cst-china)" も同様に `CST` です。

また [Java](https://github.com/openjdk/jdk/blob/jdk-17%2B6/src/java.base/share/classes/sun/util/calendar/ZoneInfoFile.java#L226) 絡みでは前述したように `CST` を tz database 名である `America/Chicago` に対応付けていることによる潜在的な問題があります。これは[古くから](http://web.mit.edu/java_v1.1.6/distrib/sun4x_57/src/java/util/TimeZone.java)そうなっています。

## `EAST`

`EAST` は [`timeanddate.com`](https://www.timeanddate.com/time/zones/east) によれば "Easter Island Standard Time" (`-06:00`) と解釈するのが一般的なようです。しかし [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L101) と [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) は `EAST` を `+10:00` と解釈します。

Ruby のコード履歴の中からこの出典を追うことはできませんでしたが、この時間はおそらく "East Australian Standard Time" を `EAST` と呼んでいると推測されます。

[`timeanddate.com`](https://www.timeanddate.com/time/zones/aest) によれば、本来このタイムゾーンを表す略称としては `AEST` ("Australian Eastern Standard Time"; `+10:00`) が一般的ですが、どこかでこのひっくり返った略称が入り込んでしまったようです。 "East Australian Standard Time" で `EAST` とする出典は PostgreSQL 以外にほとんど確認できませんでしたが、前述の "China Coastal Time" と同じ[アメリカ地質調査所 (United States Geological Survey; USGS)](https://help.waterdata.usgs.gov/code/tz_query?fmt=html) が "East Australian Standard Time" を使っていました。

## `EDT`

`EDT` は [`timeanddate.com`](https://www.timeanddate.com/time/zones/edt) を見るまでもなく "Eastern Daylight Time" (`-04:00`) と解釈するものだと思われており、筆者も "Eastern Daylight Time" 以外の `EDT` はいまのところ確認していません。 [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L14) や [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) もそう解釈します。

しかし Java 絡みでは前述したように、一部のタイムゾーン略称を tz database 名に対応付けていることによる問題があります。夏時間の略称 (`?DT`) は Java 標準には入っておらず Java 標準では問題は起こらないのですが、標準 [Java Date and Time API](https://www.oracle.com/technetwork/jp/articles/java/jf14-date-time-2125367-ja.html) の前身となった [Joda-Time](https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeUtils.java#L443) は `EDT` を `America/New_York` に対応付けています。このことで起こる問題は前の記述を確認してください。

## `EST`

`EST` は [`timeanddate.com`](https://www.timeanddate.com/time/zones/est) を見るまでもなく "Eastern Standard Time" (`-05:00`) と解釈するものだと思われており、筆者も "Eastern Standard Time" 以外の `EST` はいまのところ確認していません。 [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L14) や [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) もそう解釈します。

しかし Java 絡みでは、初期の Java で `EST` を tz database 名である `America/New_York` に対応付けていたことによる潜在的な問題がありました。前述したように、この問題は 2006 年ごろに認知されて、デフォルトではオフセット `-05:00` にマッピングされるようになり、旧来の仕様との互換性が必要な場合はシステムプロパティで制御する、という形になっています。 [^java-oldmapping]

標準 [Java Date and Time API](https://www.oracle.com/technetwork/jp/articles/java/jf14-date-time-2125367-ja.html) の前身となった [Joda-Time](https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeZone.java#L1319) は、旧来の Java の挙動を一部引き継いで `EST` を `America/New_York` に対応付けています。

## `GST`

`GST` は [`timeanddate.com`](https://www.timeanddate.com/time/zones/gst) によれば "Gulf Standard Time" (湾岸標準時; `+04:00`) と解釈するのが一般的なようです。

しかし [Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L102) と [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) は `GST` を "Guam Standard Time" (グアム標準時; `+10:00`) と解釈する立場を取っています。

ちなみに [`timeanddate.com`](https://www.timeanddate.com/time/zones/chst) によれば、現在ではグアム島の標準時は "Chamorro Standard Time" (チャモロ標準時; 略称は `ChST`) と呼ばれるのが一般的で、この "Guam Standard Time" という名前の標準時は存在しないようです。

## `HDT`

`HDT` という三文字のタイムゾーン略称は、現在その扱いが曖昧なものになっているように見えます。

[Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L62) と [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) はともに `HDT` を "Hawaii(/Alaska) Daylight Time" (`-09:00`) として扱っています。

最初の注意点として [1945 年以降現在まで、ハワイ州で夏時間は実施されていません](https://en.wikipedia.org/wiki/Daylight_saving_time_in_the_United_States#Hawaii)。そのため、現在のハワイに "'Hawaii' Daylight Time" (「ハワイ」夏時間) は存在しません。

実際には、アメリカ合衆国で法的にハワイ州に適用されるタイムゾーンは 1983 年以降 "Hawaii–Aleutian Standard/Daylight Time" と呼ばれ、アラスカ州アリューシャン列島の一部のタイムゾーンと一体になっています。このアリューシャン列島の方では夏時間が実施されているため "Hawaii–Aleutian Daylight Time" は存在します。

合衆国として法的にタイムゾーンの略称は規定していない [^us-abbreviation] らしく、そのため世間では "Hawaii–Aleutian Standard/Daylight Time" は `HAST`/`HADT` と略されたり `HST`/`HDT` と略されたりしているようです。この略称については [tz database でも 2015 年に議論があり](http://mm.icann.org/pipermail/tz/2015-April/022203.html)、それまで tz database では `HADT`/`HAST` が使われていたものを、[「`HST`/`HDT` のほうがよく見る気がするし、政府系の文書の中では `HST`/`HDT` が使われているっぽい」という理由で tz database で採用する略称を `HST`/`HDT` に変えた](http://mm.icann.org/pipermail/tz/2015-April/022208.html)、という経緯があるようです。

[^us-abbreviation]: [tz database の記載](https://github.com/eggert/tz/blob/2021a/northamerica#L262)より。より正確な出典を募集しています。

[`timeanddate.com`](https://www.timeanddate.com/time/zones/hadt) でも、ページの URL には `HADT` が使われている (`https://www.timeanddate.com/time/zones/hadt`) のに対して、ページ内では `HDT` と表記されている、など、運用・表記に苦慮している様子がうかがえます。

~~まあ、わざわざ難しいこと考えずに略称を使うのをやめれば混乱しなくていいんじゃないですかね。~~

## `HST`

`HST` については、まず [`HDT`](#hdt) の項からご覧ください。

[Ruby](https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L67) と [PostgreSQL](https://www.postgresql.org/docs/8.1/datetime-keywords.html) はともに `HST` を "Hawaii(–Aleutian) Standard Time" (`-10:00`) と解釈します。

`HST` については、前述の `HDT` と同様の事情に加えて Java 固有の事情があります。初期の Java では `HST` を tz database 名である `Pacific/Honolulu` に対応付けていたことによる潜在的な問題がありました。前述したようにこの問題は 2006 年ごろに認知されて、デフォルトではオフセット `-10:00` にマッピングされるようになり、旧来の仕様との互換性が必要な場合はシステムプロパティで制御する、という形になっています。 [^java-oldmapping]

標準 [Java Date and Time API](https://www.oracle.com/technetwork/jp/articles/java/jf14-date-time-2125367-ja.html) の前身となった [Joda-Time](https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeZone.java#L1313) は、旧来の Java の挙動を一部引き継いで `HST` を `Pacific/Honolulu` に対応付けています。

```java

        // "MDT" considered as Mountain Standard Time (-07:00) in legacy Embulk.
        //
        // "MDT" is widely acknowledged as Mountain Daylight Time (-06:00).
        //
        // Java and Ruby have recognized "MDT" as Mountain Daylight Time (-06:00) normally.
        //
        // Embulk has recognized "MDT" wrongly as Mountain Standard Time (-07:00) because Embulk has calculated its offset by:
        //   org.joda.time.format.DateTimeFormat.forPattern("z").parseMillis("MDT")
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L18
        // * Java: N/A
        // * Joda-Time DateTimeUtils: https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeUtils.java#L447
        //
        // Standard Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Mountain_Time_Zone
        // * timeanddate.com: https://www.timeanddate.com/time/zones/mst
        //
        // Daylight Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Mountain_Time_Zone
        // * timeanddate.com: https://www.timeanddate.com/time/zones/mdt
        "MDT", ZoneOffset.of("-07:00"),
        "Use -07:00, -06:00, America/Denver, America/Edmonton, or else as needed instead for true Mountain Daylight Time. "
            + "Embulk has recognized MDT wrongly as Mountain Standard Time, and keeps it for compatibility in the legacy mode.",
```

```java

        // "MEST" considered as Middle European Summer Time (+02:00) in legacy Embulk.
        //
        // Middle European Summer Time is usually acknowledged as Central European Summer Time (CEST).
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L82
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Middle European Summer Time / Central European Summer Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Central_European_Summer_Time
        // * timeanddate.com: https://www.timeanddate.com/time/zones/cest
        "MEST", ZoneOffset.of("+02:00"),
        "Use +02:00, Europe/Paris, Europe/Berlin, or else as needed instead for Middle (Central) European Summer Time.",
```

```java

        // "MESZ" considered as Mitteleuropaeische Sommerzeit (+02:00) in legacy Embulk.
        //
        // Mitteleuropaeische Sommerzeit means Central European Summer Time in Germany.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L83
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Mitteleuropaeische Zeit:
        // * Wikipedia: https://en.wikipedia.org/wiki/Time_in_Germany
        // * timeanddate.com: N/A
        "MESZ", ZoneOffset.of("+02:00"),
        "Use +02:00, Europe/Berlin, or else as needed instead for Mitteleuropaeische Sommerzeit.",
```

```java

        // "MET" considered as Middle European Time ("MET"; +01:00) in legacy Embulk.
        //
        // Middle European Time is usually acknowledged as Central European Time (CET).
        //
        // Java recognized "MET" as Middle East Time (+03:30) for historical reasons as of 1.1.6 at least.
        // Embulk has not adopted it.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L73
        // * Java 1.1.6: http://web.mit.edu/java_v1.1.6/distrib/sun4x_57/src/java/util/TimeZone.java
        // * Joda-Time DateTimeZone: https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeZone.java#L1309
        //
        // Central European Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Central_European_Time
        // * timeanddate.com: https://www.timeanddate.com/time/zones/cet
        "MET", ZoneId.of("MET"),  // "MET" is accepted as ZoneId as-is.
        "Use +01:00, +02:00, Europe/Paris, Europe/Berlin, Africa/Algiers, or else as needed instead for Middle (Central) European Time. "
            + "Or, use +03:30, Asia/Tehran, or else as needed instead for Middle East Time, historical Java standard.",
```

```java

        // "MEWT" considered as Middle European Winter Time (+01:00) in legacy Embulk.
        //
        // Middle European Winter Time is usually acknowledged as Central European Time (CET).
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L74
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Middle European Winter Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Central_European_Time
        // * timeanddate.com: N/A
        "MEWT", ZoneOffset.of("+01:00"),
        "Use +01:00, Europe/Paris, Europe/Berlin, Africa/Algiers, or else as needed instead for Middle European Winter Time.",
```

```java

        // "MEZ" considered as Mitteleuropaeische Zeit (+01:00) in legacy Embulk.
        //
        // Mitteleuropaeische Zeit means Central European Time in Germany.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L75
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Mitteleuropaeische Zeit:
        // * Wikipedia: https://en.wikipedia.org/wiki/Time_in_Germany
        // * timeanddate.com: N/A
        "MEZ", ZoneOffset.of("+01:00"),
        "Use +01:00, +02:00, Europe/Berlin, or else as needed instead for Mitteleuropaeische Zeit.",
```

```java

        // "MSD" considered as Moscow Daylight Time (+04:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L90
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Moscow Daylight Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Moscow_Time
        // * timeanddate.com: https://www.timeanddate.com/time/zones/msd
        "MSD", ZoneOffset.of("+04:00"),
        "Use +04:00, Europe/Moscow, or else as needed instead for Moscow Daylight Time.",
```

```java

        // "MSK" considered as Moscow Standard Time (+03:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L89
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Moscow Standard Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Moscow_Time
        // * timeanddate.com: https://www.timeanddate.com/time/zones/msk
        "MSK", ZoneOffset.of("+03:00"),
        "Use +03:00, +04:00, Europe/Moscow, or else as needed instead for Moscow Standard Time.",
```

```java

        // "MST" considered as Mountain Standard Time (-07:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L17
        // * Java: https://github.com/openjdk/jdk/blob/jdk8-b120/jdk/src/share/classes/sun/util/calendar/ZoneInfoFile.java#L274
        // * Java 1.1.6: http://web.mit.edu/java_v1.1.6/distrib/sun4x_57/src/java/util/TimeZone.java
        // * Joda-Time DateTimeZone: https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeZone.java#L1316
        // * Joda-Time DateTimeUtils: https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeUtils.java#L446
        //
        // Standard Time
        // * Wikipedia: https://en.wikipedia.org/wiki/Mountain_Time_Zone
        // * timeanddate.com: https://www.timeanddate.com/time/zones/mst
        "MST", ZoneOffset.of("-07:00"),
        "Use -07:00, -06:00, America/Denver, America/Edmonton, America/Phoenix, or else as needed instead for Mountain Standard Time.",

        "MST7MDT", ZoneId.of("MST7MDT"),
        "Use -07:00, -06:00, America/Denver, America/Edmonton, America/Phoenix, or else as needed instead for Mountain Time.",
```

```java

        // "NDT" considered as Newfoundland Daylight Time (-02:30) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L55
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Newfoundland Daylight Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Newfoundland_Time_Zone
        // * timeanddate.com: https://www.timeanddate.com/time/zones/ndt
        "NDT", ZoneOffset.of("-02:30"),
        "Use -02:30, America/St_Johns, or else as needed instead for Newfoundland Daylight Time.",
```

```java

        // "NST" considered as Newfoundland Standard Time (-03:30) in legacy Embulk.
        //
        // Java has recognized "NST" as New Zealand Standard Time (+12:00) for historical reasons since 1.1.6 at the latest.
        // Embulk has not adopted it.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L50
        // * Java: https://github.com/openjdk/jdk/blob/jdk8-b120/jdk/src/share/classes/sun/util/calendar/ZoneInfoFile.java#L238
        // * Java 1.1.6: http://web.mit.edu/java_v1.1.6/distrib/sun4x_57/src/java/util/TimeZone.java
        // * Joda-Time DateTimeZone: https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeZone.java#L1338
        //
        // Newfoundland Standard Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Newfoundland_Time_Zone
        // * timeanddate.com: https://www.timeanddate.com/time/zones/nst
        "NST", ZoneOffset.of("-03:30"),
        "Use -03:30, -02:30, America/St_Johns, or else as needed instead for Newfoundland Standard Time."
            + "Or, use +12:00, +13:00, Pacific/Auckland, or else instead for New Zealand Standard Time, historical Java standard.",
```

```java

        // "NT" considered as obsolete Nome Time (-11:00) in legacy Embulk.
        //
        // Nome Time has no longer existed, and the areas have switched to Alaska Time.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L68
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Nome Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Nome,_Alaska
        // * timeanddate.com: https://www.timeanddate.com/time/zone/usa/nome
        // * worldtimezone.com: https://www.worldtimezone.com/wtz-names/wtz-nt.html
        // * MHonArc: https://www.mhonarc.org/MHonArc/doc/resources/timezones.html
        "NT", ZoneOffset.of("-11:00"),
        "Use -11:00, America/Anchorage, or else as needed instead for obsolete Nome Time.",
```

```java

        // "NZDT" considered as New Zealand Daylight Time (+13:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L107
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // New Zealand Daylight Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Time_in_New_Zealand
        // * timeanddate.com: https://www.timeanddate.com/time/zones/nzdt
        "NZDT", ZoneOffset.of("+13:00"),
        "Use +13:00 Pacific/Auckland, or else as needed instead for New Zealand Daylight Time.",
```

```java

        // "NZST" considered as New Zealand Standard Time (+12:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L105
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // New Zealand Standard Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Time_in_New_Zealand
        // * timeanddate.com: https://www.timeanddate.com/time/zones/nzst
        "NZST", ZoneOffset.of("+12:00"),
        "Use +12:00, +13:00, Pacific/Auckland, or else as needed instead for New Zealand Standard Time.",
```

```java

        // "NZT" considered as New Zealand Time (+12:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L106
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // New Zealand Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Time_in_New_Zealand
        // * timeanddate.com: N/A
        "NZT", ZoneOffset.of("+12:00"),
        "Use +12:00, +13:00, Pacific/Auckland, or else as needed instead for New Zealand Time.",
```

```java

        // "PDT" considered as Pacific Standard Time (-08:00) in legacy Embulk.
        //
        // "PDT" is widely acknowledged as Pacific Daylight Time (-07:00).
        //
        // Java and Ruby have recognized "PDT" as Pacific Daylight Time (-07:00) normally.
        //
        // Embulk has recognized "PDT" wrongly as Pacific Standard Time (-08:00) because Embulk has calculated its offset by:
        //   org.joda.time.format.DateTimeFormat.forPattern("z").parseMillis("PDT")
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L20
        // * Java: N/A
        // * Joda-Time DateTimeUtils: https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeUtils.java#L449
        //
        // Pacific Standard Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Pacific_Time_Zone
        // * timeanddate.com: https://www.timeanddate.com/time/zones/pst
        //
        // Pacific Daylight Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Pacific_Time_Zone
        // * timeanddate.com: https://www.timeanddate.com/time/zones/pdt
        "PDT", ZoneOffset.of("-08:00"),
        "Use -08:00, -07:00, America/Los_Angeles, America/Vancouver, or else as needed instead for true Pacific Daylight Time. "
            + "Embulk has recognized PDT wrongly as Pacific Standard Time, and keeps it for compatibility in the legacy mode.",
```

```java

        // "PST" considered as Pacific Standard Time (-08:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L19
        // * Java: https://github.com/openjdk/jdk/blob/jdk8-b120/jdk/src/share/classes/sun/util/calendar/ZoneInfoFile.java#L242
        // * Java 1.1.6: http://web.mit.edu/java_v1.1.6/distrib/sun4x_57/src/java/util/TimeZone.java
        // * Joda-Time DateTimeZone: https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeZone.java#L1315
        // * Joda-Time DateTimeUtils: https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeUtils.java#L448
        //
        // Standard Time
        // * Wikipedia: https://en.wikipedia.org/wiki/Pacific_Time_Zone
        // * timeanddate.com: https://www.timeanddate.com/time/zones/pst
        "PST", ZoneOffset.of("-08:00"),
        "Use -08:00, -07:00, America/Los_Angeles, America/Vancouver, or else as needed instead for Pacific Standard Time.",
```

```java

        "PST8PDT", ZoneId.of("PST8PDT"),
        "Use -08:00, -07:00, America/Los_Angeles, America/Vancouver, or else as needed instead for Pacific Time.",
```

```java

        // "SAST" considered as South Africa Standard Time (+02:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L84
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // South Africa Standard Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/South_African_Standard_Time
        // * timeanddate.com: https://www.timeanddate.com/time/zones/sast
        "SAST", ZoneOffset.of("+02:00"),
        "Use +02:00, Africa/Johannesburg, or else as needed instead for South Africa Standard Time.",

```

```java
        // "SGT" considered as Singapore Time (+08:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L97
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Singapore Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Singapore_Standard_Time
        // * timeanddate.com: https://www.timeanddate.com/time/zones/sgt
        "SGT", ZoneOffset.of("+08:00"),
        "Use +08:00, Asia/Singapore, or else as needed instead for Singapore Time.",
```

```java

        // "SST" considered as Swedish Summer Time (+02:00) in legacy Embulk.
        //
        // "SST" is widely acknowledged as Samoa Standard Time (-11:00).
        //
        // Ruby has recognized "SST" as Swedish Summer Time (+02:00) for historical reasons since 2002 at the latest.
        // PostgreSQL has recognized "SST" as Swedish Summer Time (+02:00), too. Embulk has adopted it.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L85
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Swedish Summer Time:
        // * Wikipedia: N/A
        // * timeanddate.com: https://www.timeanddate.com/time/zone/sweden
        //
        // Samoa Standard Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Samoa_Time_Zone
        // * timeanddate.com: https://www.timeanddate.com/time/zones/sst
        "SST", ZoneOffset.of("+02:00"),
        "Use +02:00, Europe/Stockholm, or else as needed instead for Swedish Summer Time. "
            + "Or, use -11:00, Pacific/Pago_Pago, or else as needed instead for Samoa Standard Time.",
```

```java

        // "SWT" considered as Swedish Winter Time (+01:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L76
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Swedish Winter Time:
        // * Wikipedia: N/A
        // * timeanddate.com: https://www.timeanddate.com/time/zone/sweden
        "SWT", ZoneOffset.of("+01:00"),
        "Use +01:00, Europe/Stockholm, or else as needed instead for Swedish Winter Time.",

        // "UCT" considered as UTC in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: N/A
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // UTC:
        // * Wikipedia: https://en.wikipedia.org/wiki/Universal_Time
        // * timeanddate.com: https://www.timeanddate.com/time/zones/utc
        "UCT", ZoneOffset.UTC,
        "Use UTC instead.",
```

```java

        // "UT" considered as Universal Time in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L11
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Universal Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Universal_Time
        // * timeanddate.com: https://www.timeanddate.com/time/zones/ut
        "UT", ZoneOffset.UTC,
        "Use UTC instead.",
```

```java

        // "WADT" considered as obsolete and wrong West Australian Daylight Time (+08:00) in legacy Embulk.
        //
        // Ruby has recognized "WADT" as West Australian Daylight Time (+08:00) for historical reasons since 2002 at the latest.
        // It is wrong. Western Australia has not observed daylight saving time.
        //
        // PostgreSQL has recognized "WADT" as West Australian Daylight Time (+08:00), too.
        //
        // Embulk has adopted this wrong West Australian Daylight Time (+08:00).
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L98
        // * Java: N/A
        // * Joda-Time: N/A
        // * PostgreSQL: https://www.postgresql.org/docs/8.0/datetime-keywords.html
        //
        // West Australian Daylight Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Time_in_Australia
        // * timeanddate.com: N/A
        "WADT", ZoneOffset.of("+08:00"),
        "Use +08:00, Australia/Perth, or else as needed instead for West Australian Daylight Time.",
```

```java

        // "WAST" considered as obsolete and wrong West Australian Standard Time (+07:00) in legacy Embulk.
        //
        // "WAST" is widely acknowledged as West Africa Summer Time (+02:00).
        //
        // Ruby has recognized "WAST" as West Australian Standard Time (+07:00) for historical reasons since 2002 at the latest.
        // Furthermore, it is wrong. West Australian Standard Time has never been +07:00. It has been +08:00 in reality.
        //
        // PostgreSQL has recognized "WAST" as West Australian Standard Time (+07:00), too.
        //
        // Embulk has adopted this West Australian Standard Time (+07:00).
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L95
        // * Java: N/A
        // * Joda-Time: N/A
        // * PostgreSQL: https://www.postgresql.org/docs/8.0/datetime-keywords.html
        //
        // West Australian Standard Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Time_in_Australia
        // * timeanddate.com: https://www.timeanddate.com/time/zones/awst
        //
        // West Africa Summer Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/West_Africa_Time
        // * timeanddate.com: https://www.timeanddate.com/time/zones/wast
        "WAST", ZoneOffset.of("+07:00"),
        "Use +07:00, +08:00, Australia/Perth, or else as needed instead for West Australian Standard Time. "
            + "Or, use +02:00, Africa/Windhoek, or else as needed instead for West Africa Summer Time.",
```

```java

        // "WAT" considered as West Africa Time (+01:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L77
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // West Africa Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/West_Africa_Time
        // * timeanddate.com: https://www.timeanddate.com/time/zones/wat
        "WAT", ZoneOffset.of("+01:00"),
        "Use +01:00, +02:00, Africa/Lagos, Africa/Windhoek, or else as needed instead for West Africa Time.",
```

```java

        // "WEST" considered as Western European Summer Time (+01:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L78
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Western European Summer Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Western_European_Summer_Time
        // * timeanddate.com: https://www.timeanddate.com/time/zones/west
        "WEST", ZoneOffset.of("+01:00"),
        "Use +01:00, Europe/Lisbon, Africa/Casablanca, or else as needed instead for Western European Summer Time.",
```

```java

        // "WET" considered as Western European Time ("WET") in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L47
        // * Java: N/A
        // * Joda-Time DateTimeZone: https://github.com/JodaOrg/joda-time/blob/v2.10.6/src/main/java/org/joda/time/DateTimeZone.java#L1307
        //
        // Western European Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Western_European_Time
        // * timeanddate.com: https://www.timeanddate.com/time/zones/wet
        "WET", ZoneId.of("WET"),  // "WET" is accepted as ZoneId as-is.
        "Use +00:00, +01:00, Europe/Lisbon, Africa/Casablanca, or else as needed instead for Western European Time.",
```

```java

        // "YDT" considered as obsolete Yukon Daylight Time (-08:00) in legacy Embulk.
        //
        // Yukon time zones have no longer existed, and the areas have switched to Pacific Time or Alaska Time.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L59
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Yukon Daylight Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Yukon_Time_Zone
        // * timeanddate.com: N/A
        "YDT", ZoneOffset.of("-08:00"),
        "Use -08:00, America/Whitehorse, America/Yakutat, or else as needed instead for obsolete Yukon Daylight Time.",
```

```java

        // "YST" considered as obsolete Yukon Standard Time (-09:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L63
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Yukon Standard Time:
        // * Wikipedia: https://en.wikipedia.org/wiki/Yukon_Time_Zone
        // * timeanddate.com: https://www.timeanddate.com/time/zones/yst
        "YST", ZoneOffset.of("-09:00"),
        "Use -09:00, -08:00, America/Whitehorse, America/Yakutat, or else as needed instead for obsolete Yukon Daylight Time.",
```

```java

        // "ZP4" considered as Zulu plus 4, USSR Zone 3, (+04:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L91
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Zulu plus 4, USSR Zone 3:
        // * Wikipedia: https://en.wikipedia.org/wiki/Time_in_Russia#Soviet_Union
        // * timeanddate.com: N/A
        // * worldtimezone.com: https://www.worldtimezone.com/wtz-names/wtz-usz3.html
        "ZP4", ZoneOffset.of("+04:00"),
        "Use +04:00, Europe/Samara, or else as needed instead for USSR Zone 3.",
```

```java

        // "ZP5" considered as Zulu plus 5, USSR Zone 4, (+05:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L92
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Zulu plus 5, USSR Zone 4:
        // * Wikipedia: https://en.wikipedia.org/wiki/Time_in_Russia#Soviet_Union
        // * timeanddate.com: N/A
        // * worldtimezone.com: https://www.worldtimezone.com/wtz-names/wtz-usz4.html
        "ZP5", ZoneOffset.of("+05:00"),
        "Use +05:00, Asia/Yekaterinburg, or else as needed instead for USSR Zone 4.",
```

```java

        // "ZP6" considered as Zulu plus 6, USSR Zone 5, (+06:00) in legacy Embulk.
        //
        // Abbreviations:
        // * Ruby: https://github.com/ruby/ruby/blob/v2_7_1/ext/date/zonetab.list#L94
        // * Java: N/A
        // * Joda-Time: N/A
        //
        // Zulu plus 6, USSR Zone 5:
        // * Wikipedia: https://en.wikipedia.org/wiki/Time_in_Russia#Soviet_Union
        // * timeanddate.com: N/A
        // * worldtimezone.com: https://www.worldtimezone.com/wtz-names/wtz-usz5.html
        "ZP6", ZoneOffset.of("+06:00"),
        "Use +06:00, Asia/Omsk, or else as needed instead for USSR Zone 5.",
```
