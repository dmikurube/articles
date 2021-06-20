<!-- * 0-a ************************************************************************************* -->

EN: ---
EN: title: The Curse of Timezones
EN: published: false
EN: description: fds
EN: tags: #timezones #jsr310 #tz #tzdb
EN: ---

<!-- * 0-b ************************************************************************************* -->

<!--
QI: タイムゾーンの存在はほぼ全ての人が知っていると思います。ソフトウェア・エンジニアなら多くの方が、自分の得意な言語で、タイムゾーンが関わるなにかしらのコードを書いたことがあるでしょう。ですが、日本に住んで日本の仕事をしていると国内時差もなく[^1] 夏時間もない[^2] [日本標準時 (Japan Standard Time)](https://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E6%A8%99%E6%BA%96%E6%99%82) のみでおよそ事が足りることもあって、このタイムゾーンという厄介な概念について成り立ちから実装上の注意まで解説した日本語の文書は、残念ながらあまり見つかりません。
QI:
QI: [^1]: 今は。
QI: [^2]: 今は。
-->

<!--
SD: ソフトウェア開発のとき、時刻の扱いにどのような方針を採っていたでしょうか。タイムゾーン、閏秒、そして夏時間。複雑に関係する時刻のしくみと基礎をいま一度確認し、要件に合った設計ができるようにポイントをおさえておきましょう。
-->

JA: タイムゾーンの存在はほぼ全ての人が知っていると思います。ソフトウェア・エンジニアなら多くの方が、自分の得意な言語で、タイムゾーンが関わるなにかしらのコードを書いたことがあるでしょう。ですが、日本に住んで日本の仕事をしていると国内時差もなく[^time-diff-for-now] 夏時間もない[^no-summer-time-for-now] [日本標準時 (Japan Standard Time)](https://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E6%A8%99%E6%BA%96%E6%99%82) のみでおよそ事が足りることもあって、このタイムゾーンという厄介な概念について成り立ちから実装上の注意まで解説した日本語の文書は、残念ながらあまり見つかりません。
JA:
JA: [^time-diff-for-now]: 今は。
JA: [^no-summer-time-for-now]: 今は。

EN: Almost everyone knows something about timezones. Many of software engineers might have written some code related to timezones in their preferred language. On the other hand, people in some countries (including Japan) are not familiar with time zones. Some coutries do not have time differences in the countries. [^time-diff-for-now] Some countries do not have the Summer Time nor the Daylight Saving Time. [^no-summer-time-for-now] Software engineers in these coutries may not have good chances to learn this troubling concept, timezones, from their background to cautions in implementations.
EN:
EN: [^time-diff-for-now]: As of now.
EN: [^no-summer-time-for-now]: As of now.

<!-- * 1-a ************************************************************************************* -->

<!--
QI: (無し)
-->

<!--
SD: 夏時間の話題で多くのエンジニアが沸いた夏になりましたね。無謀に思えた2020年導入の話は幸い断念されましたが、それはそれとして、ソフトウェアで時刻処理をまともに実装しておくに越したことはありません。将来的に夏時間が導入されてしまう可能性もありますし、そのソフトウェアを日本国外に展開するチャンスが来ても、間違った時刻処理が障壁となってしまったら悲しいことです。
-->

JA: 日本では 2020 年開始を目指した夏時間の導入が 2018 年に検討され、ソフトウェア・エンジニアを含む多くの(業界?)実務者の反対もあって同年中に断念されました。それ自体はいいニュースでしたが、他の国で新たに導入されることがあるかもしれませんし、日本も将来に結局導入してしまうかもしれません。
JA:
JA: 結局、ソフトウェアは時刻処理を「まともに」実装しておくに越したことはありません。そのソフトウェアを他の国に展開するチャンスが来ても、「間違った」時刻処理が障壁となってしまったら悲しいことです。

EN: In 2018, Japan's government considered to bring in summer time from 2020. The idea was given up thanks to objections from industries including software engineers. It was a good news, but other countries can still bring in, and Japan may eventually bring in in the future.
EN:
EN: Finally, all software should implement "proper" time processing. It would be very sad if "wrong" time processing blocks an opportunity to sell the software to other countries.

<!-- * 1-b ************************************************************************************* -->

<!--
QI: 本記事は、タイムゾーンを扱おうとすると常につきまとう逃げられない「呪い」、筆者がタイムゾーンに苦しんだ恨み[^3] を、ソフトウェア・エンジニアリングの視点から闇に踏み込んで記述し、この呪いからの適切な逃げ方、呪いを受けつつも真っ向から立ち向かうための戦い方について、筆者の主観から紹介したいと思います。
QI:
QI: [^3]: つまり筆者の呪い。
-->

<!--
SD: 本章は、一度間違えると継続して「呪われて」しまいがちな時刻の罠を避けるために、時刻とタイムゾーンという概念の成り立ちとしくみから、「呪い」を避けるための工夫を紹介します。
-->

JA: 本記事は、時刻やタイムゾーンを扱おうとすると逃げられない「呪い」について、ソフトウェア・エンジニアリングの視点から闇に踏み込んで記述します。また、この呪いからの適切な逃げ方や、呪いを受けつつも真っ向から立ち向かうための戦い方についても、できるだけ時刻とタイムゾーンという概念の成り立ちと仕組みを踏まえながら紹介します。

EN: This article describes the unavoidable "curse" of time and timezones from a viewpoint of software engineering, getting further into the dark side. It also tries to introduce some ideas how to run away from the curse appropriately, and how to fight squarely under a spell of the curse, in the light of the lessons learned from the history and mechanisms of time and timezones.

<!-- * 1-c ************************************************************************************* -->

<!--
QI: 参考実装として、各種言語・ライブラリの中で今のところ (筆者が知る限り) 最も正面から日付・時刻とタイムゾーンの問題に立ち向かった Java (8以降) の [JSR 310: Date and Time API](https://jcp.org/en/jsr/detail?id=310) をときどき参照します。
-->

<!--
SD: (無し)
-->

JA: 参考実装として、各種言語・ライブラリの中で今のところ (筆者が知る限り) 最も正面から日付・時刻とタイムゾーンの問題に立ち向かった Java (8以降) の [JSR 310: Date and Time API](https://jcp.org/en/jsr/detail?id=310) をときどき参照します。

EN: It sometimes refers to Java's [JSR 310: Date and Time API](https://jcp.org/en/jsr/detail?id=310), which has struggled with the complexity of date, time, and timezones the most squarely, as far as the author knows.

<!-- * 1-d ************************************************************************************* -->

<!--
QI: 記事中に情報の不足や誤りなどを発見されましたら[^4] ぜひ編集リクエストをお送りください。各言語における実装についても、コメントや別の記事などでの情報提供をお待ちしております。[^5] 一部 Wikipedia を参照しながら記述していますが、日本語版の Wikipedia には英語版との食い違いがあるようです。そのような場合は、基本的には英語版の方を信用するようにしています。 [^6]
QI:
QI: [^4]: たぶんたくさんある。
QI: [^5]: 筆者も知りたいので。
QI: [^6]: リンクは日本語版の方だったりします。
-->

JA: 記事中に情報の不足や誤りなどを発見されましたら[^4] ぜひ編集リクエストをお送りください。各言語における実装についても、コメントや別の記事などでの情報提供をお待ちしております。[^5] 一部 Wikipedia を参照しながら記述していますが、日本語版の Wikipedia には英語版との食い違いがあるようです。そのような場合は、基本的には英語版の方を信用するようにしています。 [^japanese-wikipedia]
JA:
JA: [^insufficient-and-wrong]: たぶんたくさんある。
JA: [^other-languages]: 筆者も知りたいので。
JA: [^japanese-wikipedia]: リンクは日本語版の方だったりします。

EN: Please let the author know if you find the descriptions insufficient or wrong [^insufficient-and-wrong]. The author is also looking for information about implementations in other languages. [^other-languages] Parts of the article are written with reference to the English Wikipedia.
EN:
EN: [^insufficient-and-wrong]: Expected to be many.
EN: [^other-languages]: The author wants to know as well.

<!-- * 2-a ************************************************************************************* -->

<!--
QI: 時差とタイムゾーン
QI: ===================
-->

<!--
SD: 時刻とは何か？ タイムゾーンとは何か？
SD: ====================================
-->

JA: 時刻と時差。タイムゾーンとはなにか?
JA: ====================================

EN: Time and time difference. What are timezones?
EN: ==============================================

<!-- * 2-b ************************************************************************************* -->

JA: 「午後1時って言ったらまあ昼くらいだよね」という認識を世界中で共有したいのであれば、地球に住んでいる限り「時差」から逃げることはできません。ある地域でいう「午後1時」はその地域である瞬間を表す「時刻」ですが、同じ瞬間に「午前9時」の地域もあります。これがややこしさの元凶であり、出発点です。 [^internet-time]
JA:
JA: [^internet-time]: ところで[インターネットタイム](https://ja.wikipedia.org/wiki/%E3%82%B9%E3%82%A6%E3%82%A9%E3%83%83%E3%83%81%E3%83%BB%E3%82%A4%E3%83%B3%E3%82%BF%E3%83%BC%E3%83%8D%E3%83%83%E3%83%88%E3%82%BF%E3%82%A4%E3%83%A0)ってどうなったんですかね。

EN: To share the sense of "1 p.m. is about the middle of the day." in the world, we cannot disregard "time differences" on the earth. "1 p.m." at one area is "time" that represents a moment at the area. There is other areas at "9 a.m" at the same moment. This is the root cause of the complexity, and the first point to begin.
EN:
EN: [^internet-time]: @@@

<!-- * 2-c ************************************************************************************* -->

JA: とはいえ、たとえば「その地点で太陽が南中する時刻をその地点の正午とする」なんていう定義にしてしまうと、日常の生活も会話もとても困難になります。極端に言えば東西方向に一歩歩くだけでもわずかに時差が発生し、たとえば東西に少しだけ離れた品川と新宿の間にも時差が発生してしまうことになります。

EN: If the noon were (仮定) defined as "the time when the sun culminates at the spot", we have very hard time in daily lives and communications. Untimately speaking, we would have a time difference beyond one-step distance, and we would have a time difference even between Shinagawa and Shinjuku.

<!-- * 2-d ************************************************************************************* -->

JA: そんなことでは法律・商業・社会などいろいろな事情で不便なので、地理的に近い一定の地域では同じ時刻を使うことにしています。その時刻系をその地域の「標準時」と呼び、同じ標準時を使うその地域を「タイムゾーン」と呼んでいます。 (例: 日本全体というタイムゾーンで使われる標準時が日本標準時)
JA:
JA: そこで地理的・社会的に近い地域では共通の時刻を使うことにしています。その共通の時刻をその地域の「標準時」と呼び、同じ標準時を使う地域を「タイムゾーン」と呼びます。たとえば、いわゆる日本標準時を使う「日本」が、1つのタイムゾーンです。 [^trains]
JA:
JA: [^trains] このような「標準時」は、歴史的には鉄道の普及とともに広がったようです。参照: UTC 策定 [要出典]

EN: As it could be inconvenient in various aspects, such as law, business, and social, we use the same "time" in a certain region that is geographically and socially close. The "common time" is called as the "Standard Time" of the region, and a region which uses the same Standard Time is called as a timezone. For example, "Japan" is one timezone where they use the "Japan Standard Time".
EN:
EN: [^trains] @@@

<!-- * 2-e ************************************************************************************* -->

JA: タイムゾーンの境界は、一般的には国境や国内の政治的境界に準じています。その方が便利だということもありますが、なによりも、そもそもタイムゾーンや標準時というのは国際的に条約などで取り決められているわけではなく、国や地域がそれぞれ「自分のところのこの地域はこの時刻でやるぜ!」と宣言しているだけだ、ということもあります。[^8]
JA:
JA: [^dateline]: いわゆる「日付変更線」も同様で、日付変更線という線が国際的に定められているわけではありません。

EN: The boundaries of timezones usually follow country boundaries and domestic political boundaries. One point is that it is simply convenient. Moreover, a timezone is declared just by each country or region such as "This region on our country uses this time as the Standard Time". Any international treaty does not define the boundaries of timezones. [^dateline]
EN:
EN: [^dateline]: Same in the so-called "Dateline". No international treaty does not define the "Dateline".

<!-- * 3-a ************************************************************************************* -->

JA: タイムゾーンという言葉の定義と実際の用法
JA: -----------------------------------------

EN: The definition of the word timezone, and its actual usages
EN: ------------------------------------------------------------

<!-- * 3-b ************************************************************************************* -->

JA: 前述のとおり「タイムゾーン」は標準時をもとに定義されます。標準時は夏時間とは独立した概念で、たとえばアメリカのユタ州とアリゾナ州は同じ「山岳部標準時」を使いますが、夏時間制には差があります。この2州は、定義上は同じタイムゾーンです。
JA:
JA: [^timezone-and-summer-time]: 例えば、[ユタ州](https://ja.wikipedia.org/wiki/%E3%83%A6%E3%82%BF%E5%B7%9E)は夏時間を採用し、[アリゾナ州](https://ja.wikipedia.org/wiki/%E3%82%A2%E3%83%AA%E3%82%BE%E3%83%8A%E5%B7%9E)の大部分は[夏時間を採用していない](https://ja.wikipedia.org/wiki/%E3%82%A2%E3%83%AA%E3%82%BE%E3%83%8A%E6%99%82%E9%96%93)にもかかわらず、ともに[山岳部標準時 (Mountain Standard Time, MST)](https://ja.wikipedia.org/wiki/%E5%B1%B1%E5%B2%B3%E9%83%A8%E6%A8%99%E6%BA%96%E6%99%82) に属する同じ「タイムゾーン」として扱われます。しかし実態としては、「標準時」や「タイムゾーン」という言葉は非常に多様な使われ方をしており、ユタ州とアリゾナ州のような場合を別の「タイムゾーン」と呼んでいる例も多く見られます。本稿でも「タイムゾーン」という言葉をそのように用いている部分があります。文献を読む際やコミュニケーションを取る際は、相手の用語の定義の正しさにあまりこだわらず、逆に自分は何を意図しているのかを明確にしておくといいでしょう。

EN: As noted previously, a "timezone" is defined by the Standard Time. The Standard Time is a concept independent from the Daylight Saving Time or the Summer Time. For example, Utah and Alizona of the United States use the same "Mountain Standard Time (MST)", but they have a difference in the Daylight Saving Time. They are defined to be in the same timezone.
EN:
EN: [^timezone-and-summer-time]: @@@

<!-- * 3-c ************************************************************************************* -->

JA: しかし「タイムゾーン」という言葉は、実態としては多様な使われ方をしています。ユタ州とアリゾナ州を別のタイムゾーンと呼ぶ例も多く見られます。逆に異なる「標準時」の国でも同等の時刻を使っていれば、まとめて1つのタイムゾーンと呼ぶ例もあります。[^windows-aggregated-timezones] 後述する“UTC+9”などの、特定の時差の時刻系そのものをタイムゾーンと呼ぶこともあります。
JA:
JA: [^windows-aggregated-timezones] Windows が使っていたタイムゾーンでは日本と韓国がまとめられていたことがある?

EN: The word "timezone" has, however, various use-cases in a practical sense. There are many use-cases which calling Utah and Arizona as different timezones. In an opposite way, there are some cases that some countries which have different "Standard Times" are considered to be in the same timezone even if these countries declare different "Standard Times", but they are practically equivalent.[^windows-aggregated-timezones] A 時刻系 like "UTC+9", which has the same specific time difference from others, is sometimes called as a timezone.
EN:
EN: [^windows-aggregated-timezones] @@@

<!-- * 4-a ************************************************************************************* -->

JA: タイムゾーンの基準: UTC とうるう秒 [^9]
JA: ----------------------------------------
JA:
JA: [^9]: この項にはおそらく特に不正確な記述が含まれますが、筆者には、分野による用語の差異や歴史的変遷まで含めて短く正確にまとめきることはできませんでした。ソフトウェア・エンジニアとしての実用にはこれでも充分と思いますが、より正確な記述を短く簡潔に書ける方の編集リクエストはいつでもお待ちしております。 (ただしあまり長い記述にはしたくないと考えています)

EN: Base of Timezones: UTC and leap seconds [^9]
EN: ---------------------------------------------
EN:
EN: [^9]: この項にはおそらく特に不正確な記述が含まれますが、筆者には、分野による用語の差異や歴史的変遷まで含めて短く正確にまとめきることはできませんでした。ソフトウェア・エンジニアとしての実用にはこれでも充分と思いますが、より正確な記述を短く簡潔に書ける方の編集リクエストはいつでもお待ちしております。 (ただしあまり長い記述にはしたくないと考えています)

<!-- * 4-b ************************************************************************************* -->

JA: 世界中で時刻について話をするには、なんらかの基準が必要です。各地域間の相対的な時差だけで多くの時刻を扱うのはたいへんです。

EN: To discuss time all over the world, some basing point is required. It would be hard to handle various times only with relative time differences between regions.

<!-- * 4-c ************************************************************************************* -->

JA: 初期に国際的な基準として使われたのが、グリニッジ標準時 (GMT: Greenwich Mean Time) です。 GMT は地球の自転と観測に基づく時刻で日常生活には有用ですが、自転の周期はふらつきがあり、物理的に厳密な24時間とは一致しません。[^physical-24] GMT を継承して数種類の世界時（UT：Universal Time）が定義されましたが、これらもやはり自転に基づきます。
JA:
JA: [^physical-24]: 物理的に厳密な時間ってなんだ、という相対論的なツッコミは置いておいてください。

EN: Greenwich Mean Time (GMT) was employed as an early international basing point. GMT [[@@@ Wikipedia の記述を参考に]]. The daily rotation however wobbles (@@@ fractuate???), and a day in GMT is not equal to the physically strict 24 hours.[^physical-24] Several kinds of Universal Times (UT) were defined with inheriting GMT while they also [@@@Wikipedia]
EN:
EN: [^physical-24]: Forget about the relativity physics.

<!-- * 4-d ************************************************************************************* -->

JA: 逆に、地球の自転によらず原子時計をもとに定めた時刻が国際原子時 (TAI: Temps Atomique International) です。こちらは物理的に厳密な1秒を刻みますが、地球の1周とTAIの1日にはずれが生じます。

EN: On the other hand, Temps Atomique International (TAI) is [[@@@Wikipedia 自転によらず原子時計をもとに定めた時刻]]. TAI ticks by physically strict 1 second, but the earth's daily rotation and a day in TAI misalign.

<!-- * 4-e ************************************************************************************* -->

JA: 1日・1秒の長さが変わるのも、1日と地球の1周がずれるのも、どちらも不便です。そこで協定世界時（UTC：Coordinated Universal Time）として折衷案というべき時刻系が提案され、多くの分野で基準として採用されています。UTCは、原子時計で1秒を刻みつつも、自転に基づく UT (UT1) との差が 0.9秒を超えないように、うるう秒を導入しながら調整を続けている時刻系です。うるう秒は面倒で嫌われがちですが、どれかの不便は受け入れないとならないのです。

EN: It is inconvenient that the lengths of a day and a second are unstable. It is also inconvenient that a day and the earth's daily rotation misalign. Then, Coordinated Universal Time (UTC) was proposed to be a happy medium, and is employed as standards in many domains. UTC ticks by physically strict 1 second by the atomic clock while it continues adjusting by introducing leap seconds so that the difference from UT (UT1) does not exceeds 0.9 second. We have to accept one of the inconveniences although leap seconds are annoying and widely disliked.

<!-- * 4-f ************************************************************************************* -->

JA: ちなみに閏秒は「60秒」が挿入される「正の閏秒」だけではなく、「59秒」が削除される「負の閏秒」が実施される可能性もあります。ただし実施例は2019年現在までに一度もありません。

EN: For your information, leap seconds are not only "positive leap seconds" inserting the "60th second". "Negative leap seconds" can be introduced by removing the "59th second" although we have had no actual example so far as of 2019.

<!-- * 4-g ************************************************************************************* -->

JA: 情報通信分野ではおもにUTCが使われ、またGMTはUTCと同等に扱われることが多いです。

EN: UTC is usually used in the information and communiaction fields. GMT is often treated as an equivalent of UTC.

<!-- * 4-h ************************************************************************************* -->

JA: 時差は UTC からの差で表現され、たとえば UTC から 9時間進んだ日本の時刻は "UTC+9", "UTC+09:00", "+09:00" などと表記します。多くのタイムゾーンは UTC から 1時間単位の差ですが、そうではないオーストラリア中部標準時 (UTC+09:30) やネパール標準時 (UTC+05:45) のようなタイムゾーンも存在します。

EN: A time difference is commonly represented as a difference from UTC. For example, Japan's time, which is [[UTCより9時間進んだ]] , is notated like "UTC+9", "UTC+09:00", or just "+09:00". Although most timezones have hourly differences from UTC, some timezones have non-hourly differences such as Australian 中部 Standard Time (UTC+09:30), and Nepal Standard Time (UTC+05:45).

<!-- * 5-a ************************************************************************************* -->

JA: ### 「地域ベースタイムゾーン」と「固定オフセット」

EN: ### "Region-based timezones" and "Fixed offsets"

<!-- * 5-b ************************************************************************************* -->

JA: 前述したように、地域によらない `"+09:00"` のような時刻系全体のことも「タイムゾーン」と呼ぶことがあります。

EN: As written previously, the entire non-region-based 時刻系 such as `"+09:00"` is sometimes called as "timezones".

<!-- * 5-c ************************************************************************************* -->

JA: 筆者の知る限り、地域を表すタイムゾーンと、地域によらず時刻系全体を表すタイムゾーンを区別する一般的な言葉は無いようです。[^wording-fixed-offset-and-region-based] 本記事では JSR 310 を参考に、前者を「地域ベース (region-based) タイムゾーン」と、後者を「固定オフセット (fixed offsets)」と呼ぶことにします。具体的には [`java.time.ZoneId`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneId.html) と [`java.time.ZoneOffset`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneOffset.html) を参照してください。
JA:
JA: [^wording-fixed-offset-and-region-based]: ご存じの方、教えてください。

EN: As far as the author knows, there are no well-defined common wordings to distinct regional timezones and non-regional timezones.[^words-fixed-offset-and-region-based] This article calls the former as "Region-based timezones", and the latter as "Fixed offsets", with using the JSR 310 as a reference. To be more precise, take a look at [`java.time.ZoneId`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneId.html) and [`java.time.ZoneOffset`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneOffset.html).
EN:
EN: [^wording-fixed-offset-and-region-based]: Please let the author know if you know.

<!-- * 6-a ************************************************************************************* -->

JA: 時刻の切り替わり
JA: =================

EN: Time transitions
EN: =================

<!-- * 6-b ************************************************************************************* -->

JA: ある地域の時刻系 (オフセット) は、様々な理由によって別の時刻 (オフセット) に切り替わることがあります。代表的なものが夏時間です。

EN: 時刻系 (offset) at a region may transition to another 時刻系 (offset) for various reasons. The Summer Time, or the Daylight Saving Time, is an representative example.

<!-- * 7-a ************************************************************************************* -->

JA: 夏時間
JA: -------

EN: Summer Time or Daylight Saving Time
EN: ------------------------------------

<!-- * 7-b ************************************************************************************* -->

JA: 地域間の時差だけでもたいへんなのに、同じ地域で時刻がずれることでさらに世界を混沌に陥れているのが「夏時間」[^daylight-summer]です。明るいうちに余暇を長く過ごせるように実施されるので、夏時間に切り替わるとき、その地域では少し時刻が進みます。
JA:
JA: [^daylight-summer]: アメリカ系では "Daylight Saving Time" と、ヨーロッパ系では "Summer Time" と呼ばれます。

EN: While time differences between regions are already hard, the "Summer Time"[^daylight-summer] throws the world into confusion by transitioning the time (時刻系) in the same region. The Summer Time is enforced so that they have longer free daytime after office hours. Then, the time (@@@少し[^summer-jump]進む) in the region when the region goes into the Summer Time.
EN:
EN: [^daylight-summer]: Called as the "Daylight Saving Time" in U.S. and around, "Summer Time" in Europe and around. In this article, we call it the "Summer Time".

<!-- * 7-c ************************************************************************************* -->

JA: 日本は夏時間に縁が薄いので、切り替わりで具体的に何が起こるのかは知らない方もいるかもしれません。なかなかアクロバティックで、夏時間に切り替わるときはいきなり時刻が吹っ飛びます。

EN: Some countries do not employ the Summer Time. Several people may not know what actually happens in the transition. The transition is acrobatic -- the time jumps in a moment.

<!-- * 7-d ************************************************************************************* -->

JA: たとえば2018年のアメリカ合衆国の場合は3月11日（日）に夏時間に切り替わりました。[^united-states-dst-day] そのタイミングは、切り替わる前の時刻でいう午前2時で、この日の午前1時59分59秒から1秒経ったと思ったら、午前3時0分0秒になっていた、という具合です。カリフォルニア州を例に、経過を1秒ごとに並べると次のようになります。
JA:
JA: [^united-states-dst-day]: 2007年以降のアメリカ合衆国 (2018年時点) の場合、毎年3月の第2日曜日に夏時間に切り替わり、その後11月の第1日曜日に戻ります。

EN: For example of the United States in 2018, they transitioned into the Daylight Saving Time on March 11 (Sun). The time was 2 a.m. (でいう) before the transition. It became 3 a.m. when one second had passed since 1:59:59 a.m. With an example of California, the process per second is shown in the table below.
EN:
EN: [^united-states-dst-day]: The United States after 2007 (as of 2018) transitions to the Daylight Saving Time on the second Sunday in March, and get back on the first Sunday in November.

<!-- * 7-e ************************************************************************************* -->

JA: | カリフォルニア州の時刻 | UTCからの時差 |
JA: | --- | --- |
JA: | 2018-03-11 01:59:58 | 太平洋標準時 (PST) -08:00 |
JA: | 2018-03-11 01:59:59 | 太平洋標準時 (PST) -08:00 |
JA: | 2018-03-11 03:00:00 | 太平洋夏時間 (PDT) -07:00 |
JA: | 2018-03-11 03:00:01 | 太平洋夏時間 (PDT) -07:00 |

EN: | Time in California | Difference from UTC |
EN: | --- | --- |
EN: | 2018-03-11 01:59:58 | Pacific Standard Time (PST) -08:00 |
EN: | 2018-03-11 01:59:59 | Pacific Standard Time (PST) -08:00 |
EN: | 2018-03-11 03:00:00 | Pacific Daylight Time (PDT) -07:00 |
EN: | 2018-03-11 03:00:01 | Pacific Daylight Time (PDT) -07:00 |

<!-- * 7-f ************************************************************************************* -->

JA: 夏時間から戻るときはさらにトリッキーで、一見すると同じ時刻を二度経験することになります。再びカリフォルニア州を例に取ると、時刻は以下のように動きました。

EN: It is more tricky when getting back from the Daylight Saving Time. They experience the same time in appearance. Again, the process in California 2018 went like the table below.

<!-- * 7-g ************************************************************************************* -->

JA: | カリフォルニア州の時刻 | UTCからの時差 |
JA: | --- | --- |
JA: | 2018-11-04 01:00:00 | 太平洋夏時間 (PDT) -07:00 |
JA: | 2018-11-04 01:00:01 | 太平洋夏時間 (PDT) -07:00 |
JA: | … | … |
JA: | 2018-11-04 01:59:59 | 太平洋夏時間 (PDT) -07:00 |
JA: | 2018-11-04 01:00:00 | 太平洋標準時 (PST) -08:00 |
JA: | 2018-11-04 01:00:01 | 太平洋標準時 (PST) -08:00 |

EN: | Time in California | Difference from UTC |
EN: | --- | --- |
EN: | 2018-11-04 01:00:00 | Pacific Daylight Time (PDT) -07:00 |
EN: | 2018-11-04 01:00:01 | Pacific Daylight Time (PDT) -07:00 |
EN: | … | … |
EN: | 2018-11-04 01:59:59 | Pacific Daylight Time (PDT) -07:00 |
EN: | 2018-11-04 01:00:00 | Pacific Standard Time (PST) -08:00 |
EN: | 2018-11-04 01:00:01 | Pacific Standard Time (PST) -08:00 |

### 夏時間のあれこれ / Miscellaneous topics in the Summer Time

- 2019 年現在の日本では夏時間は実施されていませんが、第二次世界大戦後に数年間実施されたことがあります。 [^summer-time-in-japan]
- 夏時間でずれるのは1時間とは限りません。現在でも、オーストラリアのLord Howe島では30分ずれる夏時間制が実施されています。
- 過去、第二次大戦の前後には2時間ずれる夏時間が実施された国もあります。前年の夏時間から戻らないまま二重にずらしたイギリス[^bdst]や、同年中に段階的に2時間ずらしたドイツなどです。
- 日本で 2019 年に検討された夏時間案には、一気に2時間ずらす案も含まれていました。
- ブラジルでは夏時間の実施地域や切り替え日が2008年まで毎年個別に公示されていて、公示が開始の直前になったこともあるようです。
- チリでは近年頻繁に夏時間制に変更があり、安定していないようです。

- While summer Time is not employed in Japan as of 2019, they had Summer Time for a couple of years just after the World War II.[^summer-time-in-japan]
- The Summer Time transition is not only an hour. Even currently, the Lord Howe Island in Australia employes the Summer Time transitioning by 30 minutes.
- In past around the World War II, some countries employed the Summer Time transitioning by 2 hours. The United Kingdom doubly @@@@Wikipedia][^bdst]. Germany [段階的に2時間ずらした]
- The idea of summer time considered in Japan in 2018 included an idea to transition by 2 hours at once.
- In Brazil until 2008, the regions and the transition dates of the Summer Time had been announced individually every year. In some years, the annoucement was just before the transition.
- The Summer Time situation in Chile seems unstable. They have frequently changed the rules in these years.

JA: [^summer-time-in-japan]: https://ja.wikipedia.org/wiki/%E5%A4%8F%E6%99%82%E9%96%93#%E9%80%A3%E5%90%88%E5%9B%BD%E8%BB%8D%E5%8D%A0%E9%A0%98%E6%9C%9F

EN: [^summer-time-in-japan]: @@@

JA: [^bdst]: 英国二重夏時間 (British Double Summer Time, BDST): `"+02:00"`

EN: [^bdst]: British Double Summer Time (BDST): `"+02:00"`


JA: 夏時間以外の切り替わり
JA: -----------------------

EN: Transitions other than Summer Time
EN: -----------------------------------

JA: 夏時間以外にも、国や地域の政治的決定によって、その地域の時刻が切り替わることがあります。

EN: Not only for the Summer Time, a political decision in a country or a region may transition the time in the region.

JA: たとえば2011年の年末には、サモア独立国の標準時が“UTC-11”から“UTC+13”に切り替わりました。この切り替わりは12月29日の終わりがそのまま12月31日の始まりに続く形で行われ、サモアでは2011年12月30日がなかったことになりました。

EN: For example in 2011, the Standard Time of the Republic of Samoa [要Wikipedia] has transitioned from `"UTC-11"` to `"UTC+13"`. The transition [[@@@]]

JA: 夏時間制は一定の規則のもと定例で実施されることが多いですが、このサモアのような非定例の切り替わりも、意外と頻繁にあります。時刻を扱うには、その変更にも追いつかないとならないのです。

EN: Non-periodic transitions like Samoa are surprisingly often happening although the Summer Time is usually enforced periodically under regular rules. We have to catch up with such transitions to deal with time.


JA: 情報通信分野における時刻
JA: =========================

EN: Time in the information and communiaction fields
EN: =================================================

JA: ここまで時刻のしくみ一般を説明してきました。ここからは、情報通信分野特有の内容に入っていきます。

EN: The previous sections explained the mechanism of time. Topics specific in the information and communiaction fields starts here.


JA: Unix time: 世界共通の時間軸
JA: ----------------------------

EN: Unix time: The universal time axis
EN: -----------------------------------

JA: 世界各地で「時刻」には差がありますが、それでも時間軸は世界共通で一本であり、その時間軸上の一点は世界中で同時に訪れます。 [^relativity-physics-2] 例えば、日本の2017年7月1日 午後3時0分0秒とイギリスの2017年7月1日 午前7時0分0秒は、時間軸上では同じ一点です。それぞれの国や地域の中ではそれぞれの時刻を使っていればあまり問題ありませんが、タイムゾーンをまたぐ場合、特にソフトウェアやインターネットが関わる仕組みの中では、地域によらない時間軸を扱う必要性が高くなります。

EN: Although the "(clock) times" differ between geographical regions, the time axis is universally unique, and a point on the time axis comes simultaneously across the world. [^relativity-physics-2] For example, July 1, 2018, 3:00:00pm in Japan, and July 1, 2018, 7:00:00am in the United Kingdom, are the same point on the time axis. It does not matter so much in each country or region to use their own clock time. However, the non-geographical time axis has an increased need in case of crossing timezones, especially if the Internet is involved.

JA: UTC という基準があるので、要は UTC 時間でその時間軸を表現すればいいのです。ですが、せっかく時間はどこでも平等に流れているのに[^17] 年月日時分秒の繰り上げなどをいちいち計算するのは無駄です。そこで情報通信分野では、よく[Unix time](https://ja.wikipedia.org/wiki/UNIX%E6%99%82%E9%96%93)を流用して時刻を表現します。

EN: In short, we have UTC. UTC is available to represent the time axis. @@@(ですが), it is wasteful to calculate carry up/down of year/month/day/hour/minute/second everytime while the time goes fairly [^relativity-physica-2]. Then in the information and communiaction fields, [Unix time](https://en.wikipedia.org/wiki/Unix_time) is often diverted to represent time.

JA: [^relativity-physica-2]: 相対論的なツッコミは (ry

EN: [^relativity-physics-2]: Forget about the relativi...

JA: Unix timeは、日本語ではUNIX時間、英語ではPOSIX timeまたはUNIX Epoch timeなどとも呼ばれ、時刻をUTCの1970年1月1日 0時0分0秒（Epoch）からの経過秒で表現します。

EN: Unix time, also called as POSIX time or UNIX Epoch time, represents the time in the elapsed second since January 1, 1970, 00:00:00 (the Epoch).

TODO: @@@
<!-- 1972/1/1以前のUnix time -->
<!-- https://en.wikipedia.org/wiki/Unix_time#History -->

JA: Unix timeがわかっていれば、任意のタイムゾーンにおける時刻を簡単に計算できるはず…ですが、残された問題が閏秒です。閏秒はそもそも自転速度の未知のふらつきを埋めるしくみなので、未来の何年に閏秒が挿入されるかはなかなか確定できません。そのため閏秒を考慮に入れると、未来の時刻に対応するUnix timeが計算できません。

EN: The time in any timezone should be calculated easy with known Unix time. The leap seconds are the remaining problem there. It is difficult to fix when the leap seconds are introduced because they are to mitigate the ever unknown wobble of the earth's daily rotation. Then, the Unix time cannot be calculated for the future time with the leap seconds considered.

JA: そこでUnix timeは経過時間としての厳密さを捨てて利便性を優先し、閏秒を無視することになりました。最近ではUTCにおける2016年12月31日 23時59分59秒と2017年1月1日 0時0分0秒の間に閏秒が挿入されましたが、このときUnix timeの1483228800は2秒間続きました。その経過を0.5秒ごとに並べると次のようになります。

EN: Then, Unix time ignores th eleap seconds to prioritize usefulness over exactitude as the elapsed time. The recent leap second was introduced between December 31, 2016, 23:59:59 and January 1, 2017, 00:00:00 in UTC for example. The Unix time 1483228800 continued for two seconds. The process by half second is shown as below.

JA: | UTCにおける時刻 | 小数部を含む Unix time |
JA: | --- | --- |
JA: | 2016-12-31 23:59:59.00 | 1483228799.00 |
JA: | 2016-12-31 23:59:59.50 | 1483228799.50 |
JA: | 2016-12-31 23:59:60.00 | 1483228800.00 |
JA: | 2016-12-31 23:59:60.50 | 1483228800.50 |
JA: | 2017-01-01 00:00:00.00 | 1483228800.00 |
JA: | 2017-01-01 00:00:00.50 | 1483228800.50 |
JA: | 2017-01-01 00:00:01.00 | 1483228801.00 |

EN: | The time in UTC | Unix time with the fraction part |
EN: | --- | --- |
EN: | 2016-12-31 23:59:59.00 | 1483228799.00 |
EN: | 2016-12-31 23:59:59.50 | 1483228799.50 |
EN: | 2016-12-31 23:59:60.00 | 1483228800.00 |
EN: | 2016-12-31 23:59:60.50 | 1483228800.50 |
EN: | 2017-01-01 00:00:00.00 | 1483228800.00 |
EN: | 2017-01-01 00:00:00.50 | 1483228800.50 |
EN: | 2017-01-01 00:00:01.00 | 1483228801.00 |

JA: 秒の整数部だけ見ると同じ秒が2秒続くだけに見えますが、小数部の扱いに気をつける必要があります。小数部は普段どおりにカウントするため、小数部も含めて見ると時刻が逆進したことになるからです。

EN: The integral parts look that the identical second continued for two seconds. The fraction parts must be watched. The time went in reverse with the fraction parts considered because the fraction part is counted as usual.


JA: ### UTC-SLS と Leap Smear

EN: ### UTC-SLS and Leap Smear

JA: 情報通信業界のすべての仕事で、うるう秒を導入してまで厳密な1秒が必要なわけではありません。 Unix time における逆進も含め、うるう秒が多くの問題を起こしてきたのも事実です。

EN: All the work in the information and communiaction fields does not need physically strict seconds (@@@うるう秒を導入してまで). It is the fact that the leap seconds have caused many problems including the reverse in Unix time.

JA: そこで必要なさそうな場合は1秒の厳密さを捨てて、うるう秒を周辺の数時間で「希釈」する手法が生まれました。これは最近のクラウドサービスで"Leap Smear"と呼ばれ、一般的になりつつあります。

EN: Then if unnecessary, a method to "smear" the leap seconds with several hours around is incubated with discarding the strictness of a second. It is getting common, and called as "Leap Smear" in recent cloud services.

JA: このような手法が公開の場で議論されたのは、ケンブリッジ大学の Markus Kuhn 氏による 2000 年の UTS (Smoothed Coordinated Universal Time) と、そこから派生して 2006 年に IETF Internet Draft として公開された [UTC-SLS (Coordinated Universal Time with Smoothed Leap Seconds)](https://tools.ietf.org/html/draft-kuhn-leapsecond-00) が最初のようです。 UTC-SLS では閏秒が導入される日の最後の 1,000 秒に均等に閏秒を分散させ、閏秒をなくしてしまいます。

EN: Such methods were firstly discussed in Smoothed Coordinated Universal Time (UTS) in 2000 by Markus Kuhn at the Cambridge University, and in [Coordinated Universal Time with Smoothed Leap Seconds (UTC-SLS)](https://tools.ietf.org/html/draft-kuhn-leapsecond-00) published as IETF Internet Draft in 2006 derived from UTS. UTC-SLS dismisses a leap second by dispersing the leap second into the last thousand seconds of the day when the leap second is introduced.

JA: Google が 2008 年に実施した最初の Leap Smear は UTS-SLS と異なり、閏秒前の20時間に非線形に分散させるものでした。その後2012年、2015年、2016年に実施したLeap Smearは、閏秒を中心とする20時間に線形に分散させるものになったようです。その後Googleは24時間に分散させるやり方を標準とすることを提案しています。Amazonが2015年と2016年に実施したLeap Smearも、同様に24時間に分散させるものでした。

EN: The first Leap Smear by Google in 2008 was different from UTS-SLS to disperse the leap second (@@@non-linearly?) in the 20 hours before the leap second. Later, (@@@ from Wikipedia).

<!--
もしfootnoteなどで参照を貼るようであれば:
Google: https://developers.google.com/time/smear
AWS: https://aws.amazon.com/jp/blogs/news/look-before-you-leap-december-31-2016-leap-second-on-aws/
-->

JA: クラウドサービスのLeap Smearは、おもにNTPを介して提供されています。

EN: Leap Smear in cloud services is usually provided through NTP.

@@@

JA: タイムゾーンの業界標準と注意点
JA: -------------------------------

EN: De facto standard of timezones, and cautions
EN: ---------------------------------------------

(TODO: IATA, Microsoft)

JA: ### Time Zone Database

EN: ### Time Zone Database

JA:  `"Asia/Tokyo"` や `"Europe/London"` のようなタイムゾーンの名前は、この tz database のものです。

JA: 情報通信分野でタイムゾーンに関する最も標準的なデータが [Time Zone Database (tzdb)](https://www.iana.org/time-zones) ([Wikipedia](https://ja.wikipedia.org/wiki/Tz_database)) でしょう。ほかに "zoneinfo database" や、主要な貢献者の名前をとって "Olson database" と呼ばれることもあります。 `"Asia/Tokyo"` や `"Europe/London"` のような名前は、この tzdb のものです。 tzdb のタイムゾーン名は、最初の "/" の前に大陸・海洋名を、後ろにそのタイムゾーンを代表する都市名・島名などを用いて付けられます。[^cities-in-tzdb] 国名は基本的に使われません。 [^countries-in-tzdb] `"America/Indiana/Indianapolis"` のように3要素で構成されるタイムゾーンも少数ながら存在します。

EN: The most standard data about timezones in the information and communiaction fields would be the [Time Zone Database (tzdb)](https://www.iana.org/time-zones) ([Wikipedia](https://en.wikipedia.org/wiki/Tz_database)). It is also called as "zoneinfo database", or "Olson database" named after the main contributor. Names such as `"Asia/Tokyo"` and `"Europe/London"` are from the tzdb. A timezone name from the tzdb consists of a name of continents or oceans before "/", typically followed by a name of cities of islands representing the timezone. [^cities-in-tzdb] Country names are not used in general. [^countries-in-tzdb] Some timezones (小数ながら) consist of three elements such as `"America/Indiana/Indianapolis"`.

JA: [^cities-in-tzdb]: 日本語でも「東京時間で」「ニューヨーク時間で」などというのと同じような感覚だと思います。

EN: [^cities-in-tzdb]: 

JA: [^countries-in-tzdb]: 国が関係する状態は変わりやすいので、[政治的事情による変更に対して頑強であるためと記述されています](https://github.com/eggert/tz/blob/2018e/theory.html#L116-L122)。人が生活する単位としての「都市」はそれよりは長く維持される傾向にあると考えられているようです。要出典。ちなみに[初期の提案](https://mm.icann.org/pipermail/tz/1993-October/009233.html)では使うつもりがあったようです。

EN: [^countries-in-tzdb]: It is described the reason is [@@@](https://github.com/eggert/tz/blob/2018e/theory.html#L116-L122). "Cities" as @@@ of [seikatu] would be considered being maintained longer than countries. @@YOUSHUTTEN@@ By the way, they intended to use in [the initial proposal](https://mm.icann.org/pipermail/tz/1993-October/009233.html).

@@@@

JA: tz database はボランティアによってメンテナンスされています。タイムゾーンの情報は意外なほど頻繁に変わっており、年に数回は新しい版の tz database がリリースされます。先のサモア独立国のように政治的理由からオフセットが変わる場合、夏時間制度を新しく導入する場合・取りやめる場合、国や地域の境界線に変化があった場合など、様々な理由があります。もちろん、登録されたデータに間違いが見つかることもあります。[^21]

EN: The tz database is maintained by volunteers. Timezone status is updated frequently (意外なほど), new versions of tz database are released several times a year. There are various reasons to update, for example, offset changes for political reasons like Samoa above, introducing or abondoning summer time (daylight saving time), boundary changes of countries and regions. A mistake could be found in the registered data. [^south-ryukyu-island]

JA: [^south-ryukyu-island]: `"Asia/Tokyo"` についても、古い BSD ユーザーにはおなじみの [South Ryukyu Islands時間問題](https://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E6%A8%99%E6%BA%96%E6%99%82#South_Ryukyu_Islands%E6%99%82%E9%96%93) ([調査報告](http://www.tomo.gr.jp/root/9925.html)) があったり、比較的最近でも[戦時中の情報について一部修正されたり](http://mm.icann.org/pipermail/tz/2018-January/025896.html)しています。

EN: [^south-ryukyu-island]: Even `"Asia/Tokyo"` had the "South Ryukyu Islands" problem, which is famous for old Japanese BSD users, and also had [a partial fix on the data during the World War II](http://mm.icann.org/pipermail/tz/2018-January/025896.html).

JA: tz database は、特に1970年1月1日以降の全ての変更、夏時間などのあらかじめ定められた切り替わりのルール、うるう秒の情報まで様々な情報を含むことを目標にメンテナンスが続けられています。新しい版は OS や JRE などの処理系、ライブラリなどのメンテナによって更新が取り入れられ、それらを組み込んだアップデートとしてそれぞれ世界中に配信されています。

EN: The tz database is continuously maintained to contain all updates after January 1st 1970, predefined rules of transitions like summer time, and leap seconds. New versions are distributed in the world through updates of operating systems, JRE, libraries by their maintainers.

JA: ちなみに、前述のサモア標準時の変更が tz database に適用されたのは、[実際に標準時が変わる2011年12月のわずか4ヶ月前のこと](http://mm.icann.org/pipermail/tz/2011-August/008703.html)でした。

EN: For your informaton, the Samoa standard time change above was applied into the tz database [just 4 months before the change in December 2011](http://mm.icann.org/pipermail/tz/2011-August/008703.html).

JA: 1970年1月1日以前の情報もある程度は含まれていますが、暦の違い、歴史資料の問題などもあって、完全に正確なものにしようとはそもそも考えられていないようです。[^22] 特に、個別のタイムゾーン名は「1970 年以降に区別する必要のあるタイムゾーン」のみを定義する、という方針らしいです。例えばブラジルのサンパウロを含む一部地域で 1963 年に実施された夏時間を表すために [`"America/Sao_Paulo"` の新設が提案された](https://mm.icann.org/pipermail/tz/2010-January/016007.html)ことがありますが、[この方針により却下されています](https://mm.icann.org/pipermail/tz/2010-January/016010.html)。

EN: The tz database is not considered to include complete information before January 1st 1970 because of 暦の違い, and problems of 歴史資料, although some are included. They look to have a policy to define separate timezone names which "need to be distinguished after 1970". For example, [a proposal for a new timezone `"America/Sao_Paulo"`](https://mm.icann.org/pipermail/tz/2010-January/016007.html) to represent the daylight saving time enforced around San Paulo in 1963 was [refused due to this policy](https://mm.icann.org/pipermail/tz/2010-January/016010.html).

JA: [^22]: 歴史の解釈にも揺れがあるため、「正確なもの」はそもそも存在しない、と考えられます。

EN: [^22]: It@@@

JA: 3文字/4文字の略称
JA: ------------------

EN: Abbreviations of 3 or 4 letters
EN: --------------------------------

JA: ### `"JST"`: Jerusalem Standard Time?

EN: ### `"JST"`: Jerusalem Standard Time?

JA: 日本標準時 (Japan Standard Time) は、しばしば `"JST"` と略されているのを見かけます。しかし [tz database を眺めてみる](https://github.com/eggert/tz/blob/2018c/asia)と、実際には以下のように Jerusalem Standard Time を `"JST"` とするコメントも見つかります。

EN: Japan Standard Time is often abbreviated as `"JST"`. But, [looking in the tz database]((https://github.com/eggert/tz/blob/2018c/asia)), a comment below is actualy found to abbreviate Jerusalem Standard Time as another `"JST"`.

JA:     # JST  Jerusalem Standard Time [Danny Braniss, Hebrew University]
JA:     # JST (Japan Standard Time) has been used since 1888-01-01 00:00 (JST).

EN:     # JST  Jerusalem Standard Time [Danny Braniss, Hebrew University]
EN:     # JST (Japan Standard Time) has been used since 1888-01-01 00:00 (JST).

(Jerusalem は実際には inactive であることを書く?)

JA: 3文字4文字のタイムゾーン略称は一見使いやすいのですが、このように、実は一意に特定できるものではありません。このことから、少なくともソフトウェアに再度読み込ませる可能性のあるデータを出力するのに `"JST"` のような略称を用いるのはできるだけ避けましょう。日本では動いていたのに、国外のお客さんがついてから、なんかデータがおかしくなり始めた、みたいな地獄が待っています。

EN: Although timezone abbreviations with 3-4 letters look useful at a glance, in fact, they are not guaranteed to be unique like this. It is strongly recommended to avoid such abbreviations like `"JST"`, at least for data to be read by software again. You'll be going into the hell that your code starts to break your customer's data once you have customers from foreign countries.

JA: 詳しくは後述しますが、出力の際は多くの場合 `"+09:00"` などの固定オフセットを用いるのがいいでしょう。どうしても地域ベースのタイムゾーン名を使わなければならない場合も、少なくとも `"Asia/Tokyo"` などの tz database 名を使いましょう。地域ベースのタイムゾーンと固定オフセットをセットで出力する案もあります。既に `"JST"` などを用いたデータが生成されてしまっている場合は、データ処理プロセスのできるだけ初期のステージのうちに変換しましょう。

EN: It would be nice to use fixed offsets like `"+09:00"` in many cases to output your data. Even if you (どうしても) need geographical timezones, use tz database names like `"Asia/Tokyo"` at least. Another idea is to output a set of a geographical timezone and a fixed offset. If your data already include abbreviations like `"JST"`, convert them in an earlier stage in your data processsing pipeline.

JA: 不幸にしてこのような略称を入力しなければならない際は、諦めて決め打ちで読み込むしかありません。世界で使われている多くの略称を収集し、その中から「`"JST"` は `"Asia/Tokyo"` として読み込むよ」などと、仕様を明確にしておきましょう。

EN: If you need to read such abbreviations unfortunately, you have to read them (決め打ち). Collect abbreviations from the world, and define a clear specification like '`"JST"` is read as `"Asia/Tokyo"`'.

JA: [`java.util.TimeZone`](https://docs.oracle.com/javase/jp/8/docs/api/java/util/TimeZone.html) においても、「互換性のために残してはあるけど非推奨だよ」と明確に記述されています。新しい JSR 310 の [`java.time.ZoneId`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneId.html) においては、標準ではサポートされず、[略称と tz database 名の対応を後から追加する仕組み](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneId.html#SHORT_IDS)が導入されています。

EN: Even [`java.util.TimeZone`](https://docs.oracle.com/javase/8/docs/api/java/util/TimeZone.html) clearly states "They are kept for compatibility, but not recommended @@@". [`java.time.ZoneId`](https://docs.oracle.com/javase/8/docs/api/java/time/ZoneId.html) in newer JSR 310 does not support such abbreviations by default. It just provides [a mechanism to add a mapping from abbreviations to tz database names](https://docs.oracle.com/javase/8/docs/api/java/time/ZoneId.html#SHORT_IDS).

JA: これらの略称は、文脈が明らかな対人コミュニケーションにおいて**のみ**用いるのがいいでしょう。

EN: Recommended to use such abbreviations like them ONLY in human communications that have clear contexts.

JA: ### `"EST"`, `"EDT"`, `"CST"`, `"CDT"`, `"MST"`, `"MDT"`, `"PST"`, `"PDT"`

EN: ### `"EST"`, `"EDT"`, `"CST"`, `"CDT"`, `"MST"`, `"MDT"`, `"PST"`, `"PDT"`

JA: Ruby の `Time.strptime` に見られるように、[アメリカ合衆国の一部略称のみ標準で解釈できる](https://svn.ruby-lang.org/cgi-bin/viewvc.cgi/tags/v2_5_0/lib/time.rb?view=markup#l103)ようになっている処理系があります。これは [RFC 2822](https://www.ietf.org/rfc/rfc2822.txt) などに、これらの略称が標準として含まれていることに由来するようです。

EN: Like Ruby's `Time.strptime`, some languages and libraries can [process only some abbreviations of United States of America by default](https://svn.ruby-lang.org/cgi-bin/viewvc.cgi/tags/v2_5_0/lib/time.rb?view=markup#l103). It looks to come from some standards such as [RFC 2822](https://www.ietf.org/rfc/rfc2822.txt) including these abbreviations.

JA: ただし、それでもこれらの略称の使用はできるだけ避けるべきです。夏時間などの扱いに処理系による違いが見られるからです。

EN: However, these abbreviations should be still avoided. They are processed differently by languages and librarires, for example on summer time (daylight saving time).

JA: 例えば Ruby の `Time.strptime` は RFC に則って `"PST"` を常に `"-08:00"` として扱い、逆に `"PDT"` は常に `"-07:00"` として扱います。これは、例えば夏時間期間である `"2017-07-01 12:34:56"` に `"PST"` を付けた場合でも同様で `"2017-07-01 12:34:56 -08:00"` として解釈されます。

EN: For example, Ruby's `Time.strptime` follows RFC to always assume `"PST"` as `"-08:00"`, and `"PDT"` as `"-07:00"`. It always applies. For example, `"PST"` with `"2017-07-01 12:34:56"`, which is in daylight saving time, is assumed as `"2017-07-01 12:34:56 -08:00"`.

JA: しかし、例えば JSR 310 の前身である [Joda-Time](http://www.joda.org/joda-time/) では少し事情が異なります。[`org.joda.time.DateTimeUtils#getDefaultTimeZoneNames`](http://www.joda.org/joda-time/apidocs/org/joda/time/DateTimeUtils.html#getDefaultTimeZoneNames--) は、例えば `"PST"`, `"PDT"` をともに `"America/Los_Angeles"` に対応させます。どうやら [`org.joda.time.format.DateTimeFormat.forPattern`](http://www.joda.org/joda-time/apidocs/org/joda/time/format/DateTimeFormat.html#forPattern-java.lang.String-) では間接的にこの `getDefaultTimeZoneNames` が使われているようで[^23]、このため Ruby の `Time.strptime` や RFC とは異なり `"2017-07-01 12:34:56 PST"` は `"2017-07-01 12:34:56 -07:00"` として解釈されます。

EN: On the other hand, the situation is different in [Joda-Time](http://www.joda.org/joda-time/), which is (前身) of JSR 310. [`org.joda.time.DateTimeUtils#getDefaultTimeZoneNames`](http://www.joda.org/joda-time/apidocs/org/joda/time/DateTimeUtils.html#getDefaultTimeZoneNames--) maps both `"PST"` and `"PDT"` to `"America/Los_Angeles"`. [`org.joda.time.format.DateTimeFormat.forPattern`](http://www.joda.org/joda-time/apidocs/org/joda/time/format/DateTimeFormat.html#forPattern-java.lang.String-) looks to use this `getDefaultTimeZoneNames` indirectly.

[^23]: Joda-Time のコードをあまり深く追えてはいないので要検証。

JA: Military time zones
JA: --------------------

EN: Military time zones
EN: --------------------

SD:“Z”の1文字で“UTC”を表す記述を見たことがある人は多いと思います。これはおもに米軍で使われる“Military time zones”から来ています。“UTC-12”から“UTC+12”までの25のタイムゾーンに、大文字のアルファベット（“J”を除く）を対応させます。

SD:これもRFC 822などに記載があり、標準で扱えるライブラリは多いです。しかし“Z”以外は、やはり使用を避けたほうがいいでしょう。

SD:その第一の理由は、初期のRFCの記述に誤りがあったことです。その誤りのため、異なる扱い方をしていた実装が歴史的にいくつかあり、後にRFC 2822で扱いが変わっています。ほかにも“UTC+13”や“UTC+09:30”のように扱えないタイムゾーンがあることや、有名な“Z”以外はあまり知られていないことなど、使用を避けるべき理由はいくつか挙げられます。


JA: 主に米軍で使われているタイムゾーン表現で、地域によらない固定オフセットに対応します。 `"A"` 〜 `"Z"` までの大文字アルファベット (`"J"` のみ不使用) を `"-12:00"` から `"+12:00"` まで 1 時間おきに 25 個のオフセットに割り当てています。 ([Wikipedia:en](https://en.wikipedia.org/wiki/List_of_military_time_zones))

EN: They are timezones corresponding to non-geographical fixed time offsets, which are used mainly by the U.S. military. Alphabets from `"A"` to `"Z"` (skipping `"J"`) are mapped to hourly 25 time offsets from `"-12:00"` to `"+12:00". Note that it is not respectively. ([Wikipedia:en](https://en.wikipedia.org/wiki/List_of_military_time_zones))

JA: `"Z"` の一文字で `"UTC"`/`"GMT"` を指す表現は見たことがある人が多いと思いますが、ここから来ています。

EN: Many people might have seen `"Z"` representing `"UTC"` or `"GMT"`. It has come from this.

JA: これらも `"PST"` などと同様に [RFC 2822](https://www.ietf.org/rfc/rfc2822.txt) に標準として含まれています。こちらは一意に定まる固定オフセット表現なので「避けるべき」というほどではありません。が、有名な `"Z"` 以外は一般的に知られているとは言い難いので、出力の際にわざわざ選ぶようなものでもないでしょう。 Military time zone では UTC から30分差や15分差のタイムゾーンを表現できない、という問題もあります。

EN: These are included in [RFC 2822](https://www.ietf.org/rfc/rfc2822.txt) as well as `"PST"` and else. They are not that so bad that "should be avoided" because they are uniquely identified fixed time offsets. However, they are still irregular options to choose consciously because they are not known very well just except for the famous `"Z"`.

JA: おまけ: 昔の日付・時刻
JA: =======================

EN: Appendix: Old-world date and time
EN: ----------------------------------

JA: (TODO: 少なくともグレゴリオ暦、ユリウス暦、先発グレゴリオ暦については書いておきたいのですが、力尽きたのでひとまず現状で公開しています)

EN: (TODO: Wanted to mention about Gregorian, Julius, and the proleptic Gregorian, but I ran out. Publised with the current status.)


(SD)
JA: 「時刻」の技術
JA: ===============

EN: Techniques of "time"
EN: =====================

JA: 時刻というこの厄介な概念について話を続けるときりがないのですが、ここまでである程度は概観できたと思います。時刻は複雑で、「こうやっておけば大丈夫」と言えるような唯一の正解はなさそうです。適切な扱い方は要件によって違うものになるでしょう。

EN: Although the topic of time, this troublesome concept, goes on for ever, we could have surveyed in some degree. Time is complicated, and there may not be a right answer to be always okay. Different requirements will need different handling.

JA: それでも、要件を整理しながら個々に対抗策を考えることはできます。ここからは、Java 8から導入されたJSR 310（java.time）のクラス群を例として参照しながら、設計時に気をつけるべきことを考えてみます。JSR 310については、あとの節で詳しく扱います。

EN: We are still able to think counterplans individually with sorting out the requirements. From now, let's think about the points to watch out in designing software, with reference to JSR 310 (`java.time`) introduced since Java 8.

JA: 内部データ表現
JA: ---------------

EN: Internal data structures
EN: -------------------------

JA: ソフトウェアで時刻をどう保持するかは、次の3点から考えるといいでしょう。

EN: How to maintain time data in software, it is nice to start thinking the following three points.

JA: * 保持している時刻が時間軸上の1点に対応しなくなるあいまいさがあえて必要か
JA: * 時刻の切り替わりをまたぐ計算をするか
JA: * 地理ベースの情報が必要な要件か

EN: * Do we need @@@
EN: * Do we calculate date and time across time transitions?
EN: * Does the requirement need geographical locations?

JA: 以下、細かい検討内容を見てみます。

JA: ### 閏秒を直接扱う必要があるか？ 秒以下の精確さが必要か？

EN: ### Do we need to handle leap seconds directly? Do we need subseconds?

JA: まず考えるのは閏秒です。銀行などでは閏秒を厳密に扱う必要があるかもしれませんが、一般向けのWebサービスで必要なことは多くないでしょう。閏秒は、どうにかごまかせないかをまず検討しましょう。1秒の長さが厳密でなくともよければ前述のLeap Smearがそのまま使えるかもしれませんし、秒未満の時間が不要なら逆進を考慮せずに「59分59秒」に2秒間をかけてもいいかもしれません。経過時間をはかるだけなら、時刻よりタイマーのほうが適切です。ごまかす場合、どうごまかすのか仕様として明記しましょう。

EN: Think about leap seconds first. Although banks and finances may need to handle leap seconds strictly, common web services would not need. First of all, consider covering up leap seconds. If non-strict length of a second is accepted, the Leap Smear above may be applied straightforward. If subseconds are not required, spending two seconds in "59:59" may be okay without considering the reverse. If it is just measuring the elapsed time, a timer would be more appropriate than the clock-time. Remember to clarify your cover-up in the specification.

JA: 閏秒さえごまかせるなら、内部表現として Unix time を使う案は最初に検討する価値があります。閏秒を除けば解釈にあいまいさがなく、使うメモリも少なく、単純な計算は非常に簡単に行えます。たとえば、イベント発生時刻の記録などには充分なはずです。注意点として Unix time の数値を数値型でそのまま保持すると、時差の計算で混乱しがちです。 JSR 310 の `Instant` のような専用のクラスを使うと混乱を減らせるでしょう。

EN: If leap seconds are covered-up, Unix time would be the first considerable (@@@) option as internal representation. It has no ambiguity in interpretation except for leap seconds, it consumes less memory, and it performs simple calculation in a very easy way. It would be sufficient for recording the time of event occurence, for example. Note that developers can be easily confused in calculation if the Unix time is represented in an ordinary integer type. A dedicated class, such as JSR 310 `Instant`, mitigates such confusion.

JA: ただし Unix time も万能ではありません。詳しくは後述しますが、うるう秒を無視できても Unix time が適さないケースもあります。

EN: Unix time is, however, not a silver bullet. As the detail is discussed later, Unix time may not be suited for some cases even if leap seconds can be ignored.

JA: うるう秒を扱うと一気にたいへんになります。 Unix time は使えなくなりますし、そもそも閏秒を扱えるライブラリは多くありません。たとえば JSR 310 も、単体では充分に閏秒を扱えません。どうしてもうるう秒を扱わなければならない場合、それでも任せられるかぎりライブラリに任せましょう。 Java の場合は JSR 310 と ThreeTen-Extra((https://www.threeten.org/threeten-extra/)) というライブラリの併用で、ある程度カバーできます。 ThreeTen-Extra はもともと JSR 310 の一部として検討されていたものですが、仕様が肥大化したため、外部ライブラリとして切り出して整理されたものです。

EN: Everything will be like the hell to handle leap seconds strictly. Unix time cannot be used. There are not so many libraries that can handle leap seconds appropriately. For example, even JSR 310 cannot handle leap seconds sufficiently by itself. If leap seconds are still absolutely required, the right answer is to leave it to existing libraries as far as possible. In case of Java, a combination of JSR 310 and ThreeTen-Extra((https://www.threeten.org/threeten-extra/)) covers a certain level. ThreeTen-Extra was originally a part of JSR 310 discussions, but removed from the final specification because of the bloated specification. It has been extracted as an external library.

JA: ### 暦の計算をするか？

EN: ### Do we need calendar calculation?

JA: 「翌日」や「その月の最終営業日」のような暦の計算が必要なことがあります。そんなときはタイムゾーンのことを考えないわけにはいきません。夏時間などの時刻の切り替わりをまたぐ可能性があります。まず必要なのは、たとえば要求が「翌日」なら、それが「24時間後（閏秒を無視できれば86,400秒後）」でいいのか「次の日の同じ時刻」なのか明確にすることです。そして「次の日の同じ時刻」になりそうなら、それは本当に必要なのか再検討しましょう。

EN: Some cases may require calendar calculation, such as "the next day" and "the last business day of the month". We can't afford not to consider timezones in such cases. Such calculations may step over a time transition like the Summer Time, or the Daylight Saving Time. First of all, we need to make the requirement clear. If the requirement claims "the next day", clarify it can be "24 hours later (86,400 seconds later if leap seconds are ignored)", or "the same clock-time on the next day". Then, if it looks like "the same clock-time on the next day", reconsider whether it is really needed.

JA: 「次の日の同じ時刻」までの時間は、夏時間を考慮すると 23時間かも 24時間かも 25時間かもしれません。 Unix time では計算しづらいため、少なくとも地理ベースのタイムゾーンと日付、時分秒を組み合わせて表現する必要がありますが、それだけではありません。「存在しない時刻」「二重に存在する時刻」もあるため、地理ベースのタイムゾーンだけでは情報が失われてしまいます。たとえば `"2018-11-03 01:30:00"` の「次の日の同じ時刻」である `"2018-11-04 01:30:00"` は、標準時なのか夏時間なのか `"America/Los_Angeles"` だけでは判断できません。

EN: The time until "the same clock-time on the next day" can be 23 hours, 24 hours, or 25 hours, in the light of the Summer Time. It is hard to calculate with Unix time. A geographical timezone, date, hour, minute, and second are at least needed to represent the time. But that's not all. There are "存在しない時刻" and "二重に存在する時刻". Only a geographical timezone can lose some information. For example, "the same clock-time on the next day" of `"2018-11-03 01:30:00"` is like `"2018-11-04 01:30:00"`. But, a geographical timezone of `"America/Los_Angeles"` does not determine it is in the Standard Time, or the Daylight Saving Time.

JA: `"-07:00"` のようなオフセットも同時に保持しておけば、少なくとも情報の喪失は防ぐことができます。 JSR 310 の `ZonedDateTime` は地理ベースのタイムゾーンと同時にオフセットも保持できるので、助けになるでしょう。しかし、切り替わりによる不整合の扱いは要件しだいです。各ケースを検討して、早いほうに寄せる、エラーにする、ズレや重複を許容する、など要件に合った対応を自分たちで決めなければなりません。極端な場合、サモアのように「次の日」が存在しない例さえあります。

EN: Maintaining a time offset like `"-07:00"` at the same time prevents information loss at least. JSR 310 `ZonedDateTime` may help as it can maintain a time offset along with a geographical timezone. However, it still depends on the requirement how to handle the unconformance of time transitions. It may be 早いほうに寄せる, making such a case an error, or accept such "存在しない時刻" and "二重に存在する時刻". Decisions have to be made by ourselves. Remember an extreme case like Samoa that "the next day" does not exist.

JA: 「24時間後」で済むなら、タイムゾーンを考慮する必要が激減します。 Unix time を採用して単純化できるかもしれません。日付や時分秒を頻繁に扱うなら日時を使う案もまだ有力ですが、タイムゾーンとしてオフセットのみを使えば十分なことも多いでしょう。

EN: If "24 hours later" is acceptable, we'll have dramatically reduced needs to consider timezones. Unix time may be applicable, and things may be simplified. Although maintaining calendar date and time is still a reasonable option to calculate dates, hours, minutes, seconds, maintaining only time offsets may be sufficient.

JA: ### 現地時刻や、その時刻の場所は重要か？

EN: ### Do the local time, or the location of the time matter?

JA: どこで起きること・起きたことの時刻か、が重要なことがあります。たとえば店舗の営業時間は、一般的には現地時刻で表します。飛行機の出発・到着時刻は、それぞれ出発地と到着地の現地時刻です。

EN: The location of the time of the event may matter. For example, opening hours of retail stores are represented by the local time in general. Departure and arrival times of flights are the local times of departure and arrival, respectively.

JA: 将来のイベントの予定が現地時刻で決まっているかもしれません。このような場合に Unix time に変換してしまうと、痛い目を見ることがあります。たとえば、近く夏時間を導入するかもしれない国で 2年後の 7月24日に予定されているイベントの開始時刻が、現地時刻で決まっていたとします。[^tokyo-olympic] その開始時刻を現時点の tz database を使って Unix time に変換してしまうと、夏時間がそれまでに導入された場合、実際の開始時刻と変換後の Unix time がずれてしまいます。

JA: [^tokyo-olympic] [アレ](@@@2020)ですね。

EN: A schedule of a future event may be fixed in the local time of the venue. Converting the schedule to Unix time can cause a big pain. For example, assume that an event is scheduled for July 24, two years later, and its starting time is fixed in the local time in a country which may introduce the Summer Time soon. If we convert the starting time to Unix time with the tz database as of now, we will have a mismatch between the actual future startime time, and the converted Unix time, in case the Summer Time is actually introduced before the event.

EN: [^tokyo-olympic] You may think that it is unrealistic presumption. But it was [the real](@@@2020のWikipedia).

JA: 起きたことの記録としての過去の時刻は、直感的には UTC や Unix time で残ってさえいればいいように思えます。しかし、人間は現地時刻で解釈します。たとえば、@@@夏時間に入る前の病院のカルテの記録時刻を夏時間に入ったあとに医師が見返したとき、その時刻を夏時間に入る前の現地時刻として解釈したいのが普通でしょう。

EN: UTC and Unix time intuitively seem to work fine for a past time, as a record of an event. People, however, interpret time in their local time. For example, imagine a doctor looks back a carte that is written before the summer time. The doctor normally expects that the carte's timestamp is recorded in the local time before the summer time. @@@

JA: こんなときは時刻をタイムゾーンと一緒に持ち回る必要がありますが、持ち回るタイムゾーンの形式も問題です。選択肢は、オフセットのみを持つ、地理ベースのタイムゾーンのみを持つ、両方を持つ、の3つです。将来のイベントの例では、時刻にオフセットを持つと逆に困ったことになるので、地理ベースのタイムゾーンのみ保持するのがよさそうです。カルテの例では、オフセットだけ持てば記録としては十分そうですが、「この記録から何時間後」のような計算をするなら、一緒に地理ベースのタイムゾーンも必要かもしれません。

EN: In such cases, timezones should be paired @@@ with the time. Also, a @@@ of the timezone matters. Your choice is: only the offset, only the geographical timezone, or both. For the example of future events, an offset makes troubles. Only the geographical timezone would work fine. For the example of a carte, only the offset may work enough, but the geographical timezone may be needed if you calculate the time like "X hours later from this carte".

JA: ただし、地理ベースのタイムゾーンを扱うときは常に前述の問題を頭に入れておかなければなりません。オフセットで済むなら時刻は常に Unix time に変換でき、簡単にできます。これは、時刻とタイムゾーンを扱うときは常に考えなければならないトレードオフです。

EN: You still have to keep the difficulties of geographical timezones. If offsets work fine for you, everything would be easy. The time can always be converted to Unix time. This is the trade-off that you always have to think when you manipulate time and timezones.

JA: ### タイムゾーンの表現

EN: ### Representing a timezone

JA: 地理ベースのタイムゾーンが必要なときは、前述の tzdb を基本とするといいでしょう。 JSR 310 では `ZoneId` クラスが対応します。

EN: If you need a geographical timezone, @@@. `ZoneId` is the one in JSR 310.


JA: @@@データの出力・永続化・受け渡し
JA: ---------------------------------

EN: Output, persistence, and transition of time data
EN: -------------------------------------------------

JA: 時刻データの永続化や他のコンポーネントとの受け渡しの際にも、考えることは同様です。ただし、永続化したデータや受け渡したデータは関わる人が増えるので、次の点に気をつけると混乱を減らせます。

EN: 

JA: * Unix timeで済む場合はUnix timeを使うことを検討する
JA: * 省略する必要がない限り、タイムゾーン情報を省略しない。常にUTCと決めている場合でも明示的にUTCと付ける
JA: * オフセットを確定できる場合は常にオフセットを付ける

EN: 

JA: ### 時刻の文字列表現

EN: ### String representation of time

JA: JSON などに入れるために文字列にする際は、みんなが同じ形式を使うとみんなが楽です。国際規格の ISO 8601 に従った `"20181031T123456+0900"` や `"2018-10-31T12:34:56+09:00"` のような形式がよく使われます。 JSR 310 も ISO 8601 を強く意識して作られていて、扱いやすくなっています。

EN: Everyone would feel easy if everyone uses the same string representation, for example in JSON. ISO 8601-compliant representations such as `"20181031T123456+0900"` and `"2018-10-31T12:34:56+09:00"` are often used. JSR 310 @@@

JA: ただし ISO 8601 には地理ベースのタイムゾーンに関する仕様は含まれていません。 JSR 310 は `"2018-10-31T12:34:56+09:00[Asia/Tokyo]"` のように表記を拡張しています。

EN: ISO 8601, however, does not include geographical timezones. JSR 310 extends the representation such as `"2018-10-31T12:34:56+09:00[Asia/Tokyo]"`.

JA: くどいですが、地理ベースのタイムゾーンを出力する場合 `JST` などのあいまいな略称は使わないようにしましょう。

EN: 

JA: データの入力
JA: -------------

EN:
EN: 

JA: ### 現在時刻の取得

EN: ### Retrieving the time present

JA: 現在時刻を取得して使うだけなら単純に済むことは多いですが、通信が関係する場合は「通信対象（たとえばブラウザ）が認識する時刻・タイムゾーン」と「今書いているコードが動く環境の時刻・タイムゾーン」のどちらを扱いたいのか・扱っているのかを明確にしましょう。<!--これじゃ分散システムの話っぽい…-->

EN: 

JA: ### 外部データソースからの入力

EN: ### Input from an external data source

JA: 自分で永続化したデータは設計したとおりに読み込めるはずですが、読み込むのはそればかりではありません。

EN: 

JA: 読み込む時刻が文字列の場合、前述の ISO 8601 に従っていれば簡単ですが、そうでないこともあります。ありがちな問題としては、アメリカの慣習に従って年月日を「月日年」で並べた CSV のデータが来るかもしれません。

EN: If the time is represented as a string, it may not follow ISO 8601. A typical problem is the order of dates. You may receive a CSV file that has dates in an order of "month-day-year" of US-style, "day-month-year" of Europe style, or "year-month-day" of @@@.

JA: また、前述した `"JST"` のようなあいまいな略称が使われてしまうこともあります。その場合は決め打ちするしかありません。どうしても略称を読み込む必要がある場合は、「“JST”は“Asia/Tokyo”として扱う」など、対応関係を仕様として明確化しておきましょう。

EN: Furthermore, they may use an ambiguous representation, such as `"JST"` described above. You have to @@@. If you cannot avoid to read data in an ambiguous representation, it is recommended to declare a clear specification such as "`JST` is considered to be `Asia/Tokyo`".

JA: JSR 310 の `ZoneId` はおもに tzdb 名を使ってインスタンス化するのですが、インスタンス化の際に別名の `Map` を与えることができます。たとえば `"JST"` を `"Asia/Tokyo"` に対応させる `Map` を用意しておけば、それを使って `"Asia/Tokyo"` と同等の `ZoneId` を `"JST"` から生成することもできます。

EN: Although `ZoneId` of JSR 310 is usually instantiated with a tzdb name, an alias `Map` can be specified when instantiating. For example, you can instantiate a `ZoneId` from `"JST"` from `"Asia/Tokyo"` with a `Map` corresponds `"JST"` to `"Asia/Tokyo"`.

JA: ### ユーザからの入力

EN: ### User input

JA: ユーザが過去や未来の時刻を手で入力する場合、その時刻がどの地域、どのオフセットのものかが問題になります。まずは要件からユーザの意図を検討しなければなりません。とくに未来の時刻を入力する場合、ユーザは前述のイベントの例のように「将来ずれるかもしれない現地時刻」を指定したいのか、「将来もずれない絶対時刻」を指定したいのか、要件によって異なるでしょう。

EN: When a user inputs time in the past or in the future, the region and the offset of the time matter. You will have to consider the requirements @@@YOUKEN@@@ with user's expected intention. Especially when input a future time, @@@

JA: ユーザが想定するタイムゾーンを特定する方法はいくつか考えられます。大きく分けると、時刻と一緒に手で入力してもらう、事前にアカウントなどに設定しておいてもらう、ユーザが@@@physically@@@「今いる」タイムゾーンを使う、の3つになるでしょう。

EN: There are several methods . @@@ input manually with the time, get configured @@@JIZEN@@@ in the user account or else, use the timezone where the user physically exists.

JA: 手で入力してもらうのは煩雑ですが確実です。限定された「わかっている」ユーザが対象の場合や、間違いが許されない重要な設定の場合は、有力な選択肢になります。また、手入力以外を採用した場合でも、最後の手段として手で編集する余地を残す案もあります。

EN: Manual input is annoying, but safe. If the target is expected to be "expert @@@" users, or the setting is important that cannot allow mistakes, it can be a @@@ choice. Or, manual input can be a last resort to @@@

JA: アカウントなどに設定しておいてもらう方法は、もちろんアカウントなどに設定を保存できるシステムであることが大前提です。そのうえで、ユーザが他のタイムゾーンに移動したときに、設定の追従を忘れる可能性も考慮に入れなくてはならないでしょう。手で入力をさせないまでも「今あなたが入力しようとしているのは東京時間です」とわかる表示をすると、間違いを減らせるかもしれません。

EN: 

JA: ユーザが「今いる」タイムゾーンを使うのは意外と厄介です。まず、ユーザが本当に今いる場所の時刻を意図しているのかは、自明ではありません。そして「今いる」タイムゾーンを取得する方法も技術的に確実ではありません。スマートフォンのアプリなどなら取得しやすいですが、とくにPCは場所を正確に反映しているとは限りません。

EN: 

Web ブラウザの場合はさらに厄介です。地理ベースのタイムゾーンを取得するブラウザ API の状況は、まだかんばしくありません。ネイティブと同程度の確実さで取得できるのは「現在のオフセット」だけです。現在のオフセットを使って、時刻の切り替わりをまたぐ過去や未来の時刻を解釈すると、当然おかしなことになってしまいます。

JA: Time Zone Databaseの更新
JA: -------------------------

EN: Update the Time Zone Database
EN: ------------------------------

JA: tzdb は新しい版が頻繁にリリースされます。古い版の tzdb を使っていると、地域によって時刻の解釈がおかしくなってしまい、それが致命的な問題を引き起こすこともあるでしょう。

EN: The tzdb releases new versions frequently. Old versions of tzdb @@@

JA: ネイティブアプリケーションやライブラリの開発は tzdb のバージョン管理とは独立ですが、オンラインサービスの運用はそうもいきません。サモアのように大きな変更が直前に入ることがあると考えると、コーディング以外に tzdb 更新の戦略もしっかり立てておかなければなりません。いま作っているソフトウェアがどこの tzdb を参照していて、なにを更新すれば tzdb が更新されるのかを把握しておきましょう。

EN: 

JA: Javaで使われるtzdbはJava Runtimeの各バージョンに付属します。

EN: 

<!--
リンク (あとで消す)

* https://qiita.com/dmikurube/items/15899ec9de643e91497c
* https://www.slideshare.net/khasunuma/jsr310-75403613
* https://www.slideshare.net/khasunuma/jsr310-2-75403948
* https://www.slideshare.net/khasunuma/jdk8-threeten-75404053
* https://www.slideshare.net/khasunuma/jsr310-timezone-75404253
* https://www.slideshare.net/khasunuma/jsr310-adjuster-75404274
* https://www.slideshare.net/khasunuma/jsr310-3-75404431
* https://www.slideshare.net/khasunuma/jsr310-4-75404462
* https://www.m3tech.blog/entry/timezone-handling
* https://quipper.hatenablog.com/entry/2016/12/08/090000
-->


JA: 実装の話
JA: =========

SD: Java 特有の話
SD: ==============

EN: Topics specific in Java
EN: ========================

Java #0: JRE と tz database
----------------------------

tz database の説明で「tz database は年に数回は新しい版がリリースされます」と紹介しました。 Java の場合は Java Runtime Environment (JRE) にコンパイル済みの tz database が付属する形になっています。 JRE をアップデートすると、新しいバージョンの tz database もくっついてきて更新されます。 [^24]

[^24]: タイミングによってはその JRE バージョンのリリース時点で tz database の対応が間に合わず、最新よりちょっとだけ古い tz database がやってくる可能性はあります。

JRE 自体はアップデートしたくないけど tz database だけアップデートしたい、という場合は [Timezone Updator Tool (TZUpdater)](http://www.oracle.com/technetwork/jp/java/javase/tzupdater-readme-136440.html) を使うことができます。[^25]

[^25]: 数年前に Oracle の方針云々で「TZUdater 提供されなくなる!」と混乱が起きたことがあります。2018年1月現在、サポートが打ち切られていないバージョンの JRE であれば TZUpdater は提供されています。

tz database が Java 実行環境 (JRE) に付属するものであって Java アプリケーションに付属するものではない、という点には注意が必要です。つまり、あるアプリケーションをホスト A で動かしたときとホスト B で動かしたときで tz database のバージョンがずれてしまう可能性がある、ということです。

後述する地域ベースタイムゾーン (`ZoneId`) やそれを利用した日付時刻 (`ZonedDateTime`) を使う場合は、アプリケーションの更新・管理とは別に、戦略的に tz database のバージョン管理も行う必要があります。

前述のサモア標準時のように大規模な変更が直前に行われる可能性を考えると、ただ最新を追いかけるというだけでもそんなに簡単ではありません。

Java #1: [JSR 310: Date and Time API](https://jcp.org/en/jsr/detail?id=310)
----------------------------------------------------------------------------

JSR 310 は (既に何度か参照していますが) 日付・時刻を扱う新しい Java API です。 Java 8 から追加されました。

Stephen Colebourne 氏によって実装された [Joda-Time](http://www.joda.org/joda-time/) というライブラリが JSR 310 以前からあったのですが、これをベースとして、同じ Stephen 氏のリードで正式な Java API として再設計されたのが JSR 310 です。後述する、古くからの API である `java.util.Date` と `java.util.Calendar` を完全に置き換えることを目指した[^26] らしいです。

[^26]: 要出典。

JSR 310 は「ただ日付・時刻を扱うだけなのに複雑すぎる!」という声もよく耳にします。が、日付・時刻というものが、上で書いてきたようにそもそも超複雑なんです。 JSR 310 のオブジェクトモデルは、この「超複雑な日付・時刻というモノ」をできるだけ忠実にモデル化しようとしており、とてもよくできているという認識を筆者は持っています。確かに複雑だけどそもそも超複雑なんだから仕方ないじゃん! という感じ。[^27]

[^27]: Parser による解釈が厳密すぎて大変、というのはわかる。

### [`java.time.ZoneId`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneId.html), [`java.time.ZoneOffset`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneOffset.html)

JSR 310 のタイムゾーンは、すべてのタイムゾーンを表す [`java.time.ZoneId`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneId.html) 抽象クラスと、その中でも固定オフセットを表すサブクラスの [`java.time.ZoneOffset`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZoneOffset.html) という2つのクラスで実装されています。文字列表現からは、それぞれ `ZoneId.of("Asia/Tokyo")` や `ZoneOffset.of("+09:00")` などと呼び出してインスタンスを作成します。

地域ベースの `ZoneId` インスタンスには tz database のタイムゾーンが対応していて、「いつ夏時間に切り替わるか」「過去のどの時点から使うオフセットが変わったか」などの遷移ルールも実装されています。 `ZoneId` インスタンスの `ZoneId#getRules()` を呼び出すことで、ルールを実装した [`java.time.ZoneRules`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/zone/ZoneRules.html) を取得することができます。

`ZoneId` は抽象クラスなのでそのもののインスタンスは作れません。地域ベースタイムゾーンは、今のところ `ZoneId` のサブクラスの [`java.time.ZoneRegion`](http://hg.openjdk.java.net/jdk8/jdk8/jdk/file/jdk8-b132/src/share/classes/java/time/ZoneRegion.java#l90) として実装されているようです。 (`ZoneRegion` は非公開なので直接は使えませんし、今後もこの実装が保証されるわけではありません。使うときはあくまで `ZoneId` として使います)

`"Asia/Tokyo"` `"UTC+09:00"`, `"+09:00"` のそれぞれに対して `ZoneId.of()` と `ZoneOffset.of()` を呼び出したインスタンスは、以下のように動作しています。

```java
import java.time.DateTimeException;
import java.time.ZoneId;
import java.time.ZoneOffset;

public class ZoneIds {
    public static void main(final String[] args) {
        investigateZoneId("Asia/Tokyo");
        investigateZoneId("UTC+09:00");
        investigateZoneId("+09:00");
        investigateZoneOffset("Asia/Tokyo");
        investigateZoneOffset("UTC+09:00");
        investigateZoneOffset("+09:00");
    }

    private static void investigateZoneId(String id) {
        System.out.printf("ZoneId:[%s]\n", id);
        investigate(ZoneId.of(id));
    }

    private static void investigateZoneOffset(String id) {
        System.out.printf("ZoneOffset:[%s]\n", id);
        try {
            investigate(ZoneOffset.of(id));
        } catch (DateTimeException ex) {
            System.out.printf("  DateTimeException: %s\n\n", ex.getMessage());
        }
    }

    private static void investigate(ZoneId zoneId) {
        System.out.printf("  .toString(): [%s]\n", zoneId);
        System.out.printf("  .getClass(): [%s]\n", zoneId.getClass());
        System.out.printf("  .normalized().toString(): [%s]\n", zoneId.normalized());
        System.out.printf("  .normalized().getClass(): [%s]\n", zoneId.normalized().getClass());
        System.out.printf("  .getRules().isFixedOffset(): [%s]\n", zoneId.getRules().isFixedOffset());
        System.out.printf("\n");
    }
}
```

```
ZoneId:[Asia/Tokyo]
  .toString(): [Asia/Tokyo]
  .getClass(): [class java.time.ZoneRegion]
  .normalized().toString(): [Asia/Tokyo]
  .normalized().getClass(): [class java.time.ZoneRegion]
  .getRules().isFixedOffset(): [false]

ZoneId:[UTC+09:00]
  .toString(): [UTC+09:00]
  .getClass(): [class java.time.ZoneRegion]
  .normalized().toString(): [+09:00]
  .normalized().getClass(): [class java.time.ZoneOffset]
  .getRules().isFixedOffset(): [true]

ZoneId:[+09:00]
  .toString(): [+09:00]
  .getClass(): [class java.time.ZoneOffset]
  .normalized().toString(): [+09:00]
  .normalized().getClass(): [class java.time.ZoneOffset]
  .getRules().isFixedOffset(): [true]

ZoneOffset:[Asia/Tokyo]
  DateTimeException: Invalid ID for ZoneOffset, invalid format: Asia/Tokyo

ZoneOffset:[UTC+09:00]
  DateTimeException: Invalid ID for ZoneOffset, non numeric characters found: UTC+09:00

ZoneOffset:[+09:00]
  .toString(): [+09:00]
  .getClass(): [class java.time.ZoneOffset]
  .normalized().toString(): [+09:00]
  .normalized().getClass(): [class java.time.ZoneOffset]
  .getRules().isFixedOffset(): [true]
```

`ZoneId#normalize()` は `ZoneOffset` に正規化できるインスタンスであれば正規化した `ZoneOffset` を返す、というメソッドです。 `ZoneId.of("UTC+09:00")` で作られたインスタンスは `ZoneRegion` ですが、それを `normalize()` してできたインスタンスは `ZoneOffset` になっていることがわかります。

`ZoneRules#isFixedOffset()` は、そのタイムゾーンが遷移のない固定されたタイムゾーンか否かを返すメソッドです。夏時間を採用していないはずの `"Asia/Tokyo"` が `false` なのはなんでだ! と思われるかもしれませんが、理由の一つは前述の通り、過去の一時期に夏時間を採用したことがあるためですね。 (ちなみにその夏時間以外にも遷移がありました)

固定オフセットが、地域ベースのタイムゾーンとは別のクラスで実装されている、というのが JSR 310 のキモです。これについては `java.time.OffsetDateTime` と `java.time.ZonedDateTime` に触れる際に後述します。

### [`java.time.Instant`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/Instant.html)

時間軸上の特定の一点を表すのが [`java.time.Instant`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/Instant.html) です。前述の UNIX 時間 (秒) と、小数部としてナノ秒を用いています。

うるう秒を無視することによる問題が無さそうであれば[^A1] 特に内部表現としては `java.time.Instant` を使うことをまず検討するべきでしょう。曖昧さがなく、メモリの消費も小さく、前後の比較も簡単で、例えばイベントが起こった時刻の記録としては必要十分です。

[^A1]: ほとんどの場合では、問題になることは無いと思います。

次項の日付時刻クラス群は、「一週間先」「一ヶ月先」のような日付時刻の計算を行うとき、ユーザーが関係する入出力、外部データの入出力、などのタイミングで使うことが多いでしょう。

### [`LocalDateTime`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/LocalDateTime.html), [`OffsetDateTime`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/OffsetDateTime.html), [`ZonedDateTime`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZonedDateTime.html)

どれも日付と時刻の組を表すクラス群ですが、用途に応じて3種類あります。筆者は、これらの使い分けは「時間軸上の一点 (前述の `Instant`) に対応できないことがあってもいいか否か」「その日付時刻から夏時間の境をまたぐ計算をするか否か」「その日付時刻表現について地理的地域は重要か否か」を基準に判断するのがいいと考えています。

#### [`java.time.LocalDateTime`]((https://docs.oracle.com/javase/jp/8/docs/api/java/time/LocalDateTime.html))

`LocalDateTime` は、タイムゾーン情報を一切含まない日付時刻です。このため `LocalDateTime` だけでは `Instant` には変換できず、「時間軸上のどの一点を表すのか」は `LocalDateTime` だけからはわからない、ということになります。

JSR 310 に関する日本語記事を探すと「とりあえず `LocalDateTime` 使っとけばいいよ」という記述をたまに見かけますが、あえて `LocalDateTime` を使うべき状況を筆者はほとんど思いつきません。何か起きた時間のログとして使うには「どの時点だったか」を確定できないと不十分ですし、ログでは無くても `LocalDateTime` を持ち回れば「この `LocalDateTime` ってどこの時間だったっけ」とチームに混乱を引き起こす原因になります。

同じタイムゾーンの大量の日付時刻を計算するときに、節約のために `LocalDateTime` を使うケースはあるかもしれません。その場合は、なるべくその計算のためだけの狭い範囲に限定して `LocalDateTime` が漏れないようにする、特にそのまま外部には保存しない、などの工夫をしながら使うことをお勧めします。

それ以外には、あえてタイムゾーン情報と関連付けたくない場合、例えば「そのホストがどこにあるかによらずそのホストの時刻の 23:00:00 に特定の処理を実行する」のような場合以外に `LocalDateTime` をあえて使うべきケースは、ほとんど無いように思います。[^28]

[^28]: 「こんな時に `LocalDateTime` 使うとよかった!」などの反例をお待ちしています。

#### [`java.time.OffsetDateTime`]((https://docs.oracle.com/javase/jp/8/docs/api/java/time/OffsetDateTime.html))

`OffsetDateTime` はタイムゾーン情報を持つものの、固定オフセットの `java.time.ZoneOffset` のみを許す日付時刻です。「なんでわざわざ `ZoneOffset` のみに限定するのか?」「`ZoneId` や後述の `ZonedDateTime` でいいじゃないか?」という意見があるかもしれません。が、前述の通り `ZoneOffset` というクラスを用意して限定できるようにしたことが JSR 310 のキモです。

`ZoneOffset` のみに制限することで `OffsetDateTime` は常に一意な `Instant` に変換できることを保証できるのです。[^29] 後述するように `ZonedDateTime` ではそうはいきません。

[^29]: 変換は「一対一」ではなく、うるう秒の場合に `Instant` への変換で情報が失われてしまうことには、若干の注意が必要です。

`OffsetDateTime` で済む場合はできるだけ `OffsetDateTime` を使っておくと、タイムゾーンの呪いをかなり遠ざけることができます。特に、他のコンポーネントとのインターフェースに使う場合や、外部に保存する場合 (ログなど) に `OffsetDateTime` (または相当するデータ) を使っておくと、曖昧なデータになってしまったりチームメンバーを混乱させたりする危険をだいぶ減らすことができます。

「常に UTC を使う規約にしておけば `LocalDateTime` でもいい!」という意見はあるかもしれません。しかし、往々にしてその規約を忘れたコードが生まれるものです。常に UTC を使う場合でも `ZoneOffset.UTC` を持った `OffsetDateTime` を作るようにしておくと、多少のメモリは使いますが混乱を減らせます。例えばこのような現在時刻を取得するには `OffsetDateTime.now(ZoneOffset.UTC)` などと呼び出せばいいでしょう。

`ZoneOffset` は[値ベースのクラス](https://docs.oracle.com/javase/jp/8/docs/api/java/lang/doc-files/ValueBased.html)ですが `ZoneOffset.UTC` は定数なので、大量の `ZoneOffset` インスタンスが作られるわけではなく、メモリへの影響もあまり大きくないと思われます。 [^30]

[^30]: 要検証。

#### [`java.time.ZonedDateTime`]((https://docs.oracle.com/javase/jp/8/docs/api/java/time/ZonedDateTime.html))

`ZonedDateTime` は任意の `java.time.ZoneId` をタイムゾーン情報として持つ日付時刻です。「`OffsetDateTime` より情報量多そうだし `ZonedDateTime` 使っとけばいいだろ!」という記述もたまに見かけますが、前述したように落とし穴があります。

例えば `"America/Los_Angeles"` で2017年3月12日 午前2時30分、という時刻が与えられてしまったとします。が、そんな時刻は実は存在しません。夏時間のことを思い出してみるとわかりますが `"America/Los_Angeles"` では2017年3月12日 午前1時59分59秒から2017年3月12日 午前3時0分0秒に吹っ飛んでいるからです。

また `"America/Los_Angeles"` で2017年11月5日 午前1時30分、という時刻も困ります。この場合は2017年11月5日 午前1時30分 (-07:00) のケースと2017年11月5日 午前1時30分 (-08:00) のケースと、両方がありえてしまうからです。

現在時刻から `ZonedDateTime` を作ったり、タイムゾーン付きの文字列を parse して `ZonedDateTime` を作ったりする場合には、このような問題は起こりにくいでしょう。このような問題が起こる代表的なケースとして、タイムゾーンなしの日付時刻データに「デフォルト」タイムゾーンとしてタイムゾーンを付加しようとするような状況が考えられます。

`ZonedDateTime` は補助的に `java.time.ZoneOffset` を追加で持つこともできます。[^31] このようにしたインスタンスでは、上記の後者のような問題は起こりません。しかし、あるインスタンスが `ZoneOffset` を持っているかどうかは、型からはわかりません。 `ZonedDateTime` インスタンスを受け取る人は常にこような問題に気を使わないとならなくなる、ということを意識しておく必要があります。

[^31]: 例: `"2017-11-05 01:30:00 -07:00[America/Los_Angeles]"`

とは言え `ZonedDateTime` を使うべきケースはあります。 `OffsetDateTime` は夏時間の計算をやってくれませんし、地理的地域の情報は `ZonedDateTime` でしか持つことができません。例えば「夏時間がある地域で店舗の営業時間を扱う」ような場合は、下手に自力で計算してバグを埋めるより JSR 310 に任せてやってもらいましょう。必要性と厄介さのトレードオフです。日付時刻計算の途中で `ZonedDateTime` が必要になるようなケースは、しばしばあると思います。

ただし `ZonedDateTime` を他のコンポーネントとのインターフェースとして使う場合や、外部に保存するデータとして使う際は注意が必要です。そのような場合は補助の `ZoneOffset` を常に入れるように保証できないか、仕様から検討することをお勧めします。

Java #2: `java.util.Date` と `java.util.Calendar`
--------------------------------------------------

    ￣￣￣￣￣￣￣|
    ＿＿＿＿＿＿＿|
    　　　　 　　|
    　　　 　　　|
    |￣￣|￣￣| |
    |　　| ∧_∧|
    |　　|(´∀`)つミ
    |　　|/ ⊃ ﾉ|   java.util.Date
    [二二二二二]|   java.util.Calendar
    　　　　　　|

不幸にもまだ Java 7 以前しか使えない場合でも [ThreeTen Backport](http://www.threeten.org/threetenbp/) という JSR 310 の多くの機能を Java 7 以前にバックポートしたライブラリがあります。せめてそっち使いましょう。

2018 年において Java 8 以降への移行すら考えていない、ということはさすがにもう無いと思うので、今から新しく Joda-Time を採用する理由はあまり無いでしょう。 Joda-Time を Java 8 以降で使うことは基本的に推奨されていません。

その他の言語
-------------

(タイムゾーンの扱いについて充分な内容を扱った記事には、お知らせいただけたらリンクを張らせていただきたいと思います)

言語に依らない戦略
-------------------

JSR 310 の場合の一般化になりますが、以下の点に気をつけるといいだろうと筆者は考えています。

* うるう秒を気にしなくてよく、昔の日付時刻を扱う必要もなければ、内部表現を UNIX 時間で持ち回れないか検討する。
* 日付時刻データを、特に外部コンポーネントとのインターフェースに使う場合や、外部に保存する場合 :
    * 特別に省略する必要性がない限り、タイムゾーン情報は省略しない。
    * タイムゾーン情報が必要ない場合は明示的に UTC に変換して、データにも明示的に UTC と持たせる。
    * タイムゾーンが必要でも固定オフセット (`"+09:00"` など) で済む用途なら、なるべく固定オフセットを使う。
    * 地域ベースのタイムゾーンが必要な場合は、オフセットの追記ができないか検討する。
* コード内で日付時刻データを扱う場合 :
    * タイムゾーン無しの日付時刻や地域ベースのタイムゾーンを扱う範囲を、コードの一部に限定できないか検討する。
* 地域ベースタイムゾーンを使う場合は、実行環境 (OS, ランタイム) やライブラリの仕様を調べて tz database の更新戦略を立てる。
* 3文字/4文字のタイムゾーン略語は使わず、地域ベースのタイムゾーンが必要な場合は、できるだけ tz database 名を使う。略語を使わざるをえない場合は、どの略語がどのタイムゾーンに対応するか、仕様から明示する。
