---
title: "Get ready for Embulk v0.11 and v1.0! プラグイン開発者の皆様へ"
emoji: "🌐" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [ "embulk" ]
layout: default
---

プラグイン型 Bulk Data Loader の [Embulk](https://www.embulk.org/) をメンテナンスしている @dmikurube です。

今後の Embulk のロードマップについて、一年ほど前に、記事を (英語ですが) 出したり、ミートアップで話したりしていました。その内容は、開発版 (非安定版) として Embulk v0.10 でしばらく大改造を行い、そこから次期安定版の v0.11 を経て v1.0 を出しますよ、というものでした。

* [Embulk v0.10 series, which is a milestone to v1.0](https://www.embulk.org/articles/2020/03/13/embulk-v0.10.html)
* [More detailed plan of Embulk v0.10, v0.11, and v1 -- Meetup!](https://www.embulk.org/articles/2020/07/01/meetup-20200709.html)
* [Java plugins to catch up with Embulk v0.10 from v0.9](https://dev.embulk.org/topics/catchup-with-v0.10.html)

それから一年経ち、その v0.11.0 のリリースがいよいよ視界に入り、プラグインの API/SPI (再)定義もほぼ固まりました。本記事は Embulk プラグインを v0.11 / v1.0 対応させる手順を解説するものです。 ([https://dev.embulk.org/ にある英語版](https://dev.embulk.org/topics/get-ready-for-v0.11-and-v1.0.html) の翻訳ですが、同一人物が書いているので、おそらく同じ内容になっていると思います。もし違いがありましたら、英語版の方を一次情報として解釈しつつ、ぜひ筆者までご連絡ください)

### まず、どうなったら「このプラグインは Embulk v0.11 / v1.0 対応です」と言えるの?

プラグインが以下の条件を満たしたら、そのプラグインは「Embulk v0.11 / v1.0 対応」と言って大丈夫です。

* Maven アーティファクトの `org.embulk:embulk-core` に依存していない。
* `org.embulk:embulk-api` と `org.embulk:embulk-spi` に `compileOnly` で依存している。
* Gradle プラグインの `org.embulk.embulk-plugins` でビルドされている。

こうすると `build.gradle` は以下のようになります。

```
plugins {
    id "java"
    id "maven-publish"
    id "org.embulk.embulk-plugins" version "0.4.2"  // 2021/04/27 時点の最新が 0.4.2
}

group = "your.maven.group"  // "io.github.your_github_username" など、ご自身の Maven groupId を設定してください ("org.embulk" 以外)
version = "X.Y.Z"

dependencies {
    // 0.11 から "embulk-api" と "embulk-spi" は違うバージョン体系になります。
    compileOnly "org.embulk:embulk-api:0.10.??"
    compileOnly "org.embulk:embulk-spi:0.10.??"
    // NO! compileOnly "org.embulk:embulk-core:0.10.??"
    // NO! compileOnly "org.embulk:embulk-deps:0.10.??"

    // この Gradle プラグインは、新しい Gradle の "implementation" にまだ対応していません。 "compile" である必要があります。
    // そのため Gradle 7 ではなく 6 である必要があります。 (Gradle 7 をサポートできるようにする予定です)

    // "org.embulk:embulk-util-*" というライブラリがいくつかあります。 "embulk-core" に直接依存する代わりにそれらを使ってください。
    compile "org.embulk:embulk-util-config:0.3.0"  // 2021/04/27 時点の最新が 0.3.0

    // ...

    testCompile "org.embulk:embulk-api:0.10.??"
    testCompile "org.embulk:embulk-spi:0.10.??"
    testCompile "org.embulk:embulk-junit4:0.10.??"
    testCompile "org.embulk:embulk-core:0.10.??"  // "testCompile" では "embulk-core" を使っても大丈夫です
    testCompile "org.embulk:embulk-deps:0.10.??"  // "testCompile" では "embulk-deps" を使っても大丈夫です
}
```

言い換えると、もしプラグインをビルドするのに `org.embulk:embulk-core` が必要なら、そのプラグインはまだ Embulk v0.11 対応とは言えません。

### Ruby プラグインはどうすれば?

JRuby は Embulk v0.11 以降にビルトインでは入っていません。 Embulk v1.0 以降の JRuby との連携は、あまりアクティブにはメンテナンスされない予定です。言い換えると Ruby (プラグイン) は Embulk の第一線の機能としてはサポートされなくなります。

Embulk v1.0.0 以降のどこかで急に一部の Ruby プラグインが動かなくなる、というようなことがありうると想定しておいてください。 Ruby プラグインを新しく作ることはお勧めしません。また、既存の Ruby プラグインもできれば Java に書き換えていくことをお勧めします。 (とはいえ JRuby 連携のメンテナンスに参加してくれる方は今も歓迎です)

### で、どうすれば Embulk v0.11 対応できるの?

#### Gradle wrapper を Gradle 6 に上げる

```
./gradlew wrapper --gradle-version=6.8.3
```

(2021/04/27 時点の最新が 6.8.3)

前述の通り、まだ Gradle 7 には対応していません。

#### Gradle プラグイン `org.embulk.embulk-plugins` を適用する。

Gradle プラグインのガイドに従って適用してみてください: [https://github.com/embulk/gradle-embulk-plugins](https://github.com/embulk/gradle-embulk-plugins)

#### Maven `groupId` を決める

前述のとおり JRuby は Embulk v0.11 以降にはビルトインされません。 Ruby gems は、今後 Embulk プラグインで最も使われるフォーマットではなくなっていきます。 それらは Maven リポジトリにリリースされる Maven artifacts がその代わりになっていきます。

オープンソースの Embulk プラグインは、いくつかある他の Maven リポジトリではなく [Maven Central](https://search.maven.org/) にリリースするのをお勧めしています。 ([Bintray and JCenter が終了する](https://jfrog.com/blog/into-the-sunset-bintray-jcenter-gocenter-and-chartcenter/)のは見ましたよね?)

Maven Central にリリースするには Maven の `groupId` を、あなたがリリース権限を持つ名前に設定する必要があります。以下の Maven と Java のガイドラインに従って `groupId` を決めてください。

* Maven's [Guide to naming conventions on groupId, artifactId, and version](http://maven.apache.org/guides/mini/guide-naming-conventions.html)
* Java's [Unique Package Names](https://docs.oracle.com/javase/specs/jls/se6/html/packages.html#7.7)

例えば GitHub ドメイン名を使って `io.github.your_github_username` などどする案があります。その場合は、リリースする前に [GitHub Pages を設定・公開](https://docs.github.com/ja/pages/getting-started-with-github-pages/about-github-pages) しておくことをおすすめします。

あなたのプラグインの `groupId` に `org.embulk` を使わないでください。 `org.embulk` は [https://github.com/embulk](https://github.com/embulk) 以下で管理しているプラグイン用としています。

#### Maven リポジトリに Embulk プラグインをリリースする設定をする

他へのリリースが制限されているわけではありませんが、前述のとおり、オープンソースの Embulk プラグインは [Maven Central](https://search.maven.org/) にリリースするのをおすすめしています。しかしリリース先によらず、どんな Maven リポジトリにリリースするのでも、そのリポジトリ用に `build.gradle` を設定する必要があります。

その設定は以下のようになります。 Maven Cetnral であれば [Maven のガイド (Getting started)](https://central.sonatype.org/publish/publish-guide/) や [必要事項](https://central.sonatype.org/pages/requirements.html) をチェックしてください。

```
// Maven Central では "-javadoc" and "-sources" JAR もリリースする必要があります。
// Gradle 6 以降なら、この設定でそれらを自動的に生成できます。
java {
    withJavadocJar()
    withSourcesJar()
}

// 以下の設定で "./gradlew publishMavenPublicationToMavenCentralRepository" を実行すると Maven Central にリリースできます。
// ただし Sonatype OSSRH JIRA の設定をし、その JIRA にチケットを作って新しいプロジェクトの登録をして PGP も用意しておく必要があります。
publishing {
    publications {
        maven(MavenPublication) {
            groupId = "${project.group}"
            artifactId = "${project.name}"

            from components.java

            // Maven Central では "-javadoc" and "-sources" JAR もリリースする必要があります。
            // "javadocJar" と "sourcesJar" は、上の "java.withJavadocJar()" and "java.withSourcesJar()" があれば自動で追加されます。
            // See: https://docs.gradle.org/current/javadoc/org/gradle/api/plugins/JavaPluginExtension.html

            pom {  // https://central.sonatype.org/pages/requirements.html
                packaging "jar"

                name = "${project.name}"
                description = "${project.description}"
                // url = "https://github.com/your-github-username/your-plugin-name"

                licenses {
                    // Maven Central ではライセンスを明示的に指定する必要があります。
                    // これは MIT License の例です。
                    license {
                        // http://central.sonatype.org/pages/requirements.html#license-information
                        name = "MIT License"
                        url = "http://www.opensource.org/licenses/mit-license.php"
                    }
                }

                developers {
                    developer {
                        name = "Your Name"
                        email = "you@example.com"
                    }
                }

                scm {
                    connection = "scm:git:git://github.com/your_github_username/your_repository.git"
                    developerConnection = "scm:git:git@github.com:your_github_username/your_repository.git"
                    url = "https://github.com/your_github_username/your_repository"
                }
            }
        }
    }

    repositories {
        maven {
            name = "mavenCentral"
            if (project.version.endsWith("-SNAPSHOT")) {
                url "https://oss.sonatype.org/content/repositories/snapshots"
            } else {
                url "https://oss.sonatype.org/service/local/staging/deploy/maven2"
            }

            // この設定は "~/.gradle/gradle.properties" に "ossrhUsername" と "ossrhPassword" があることを前提にしています。
            // Sonatype OSSRH のユーザー名とパスワードを "~/.gradle/gradle.properties" に入れてください。
            // https://central.sonatype.org/publish/publish-gradle/#credentials
            credentials {
                username = project.hasProperty("ossrhUsername") ? ossrhUsername : ""
                password = project.hasProperty("ossrhPassword") ? ossrhPassword : ""
            }
        }
    }
}

// Maven Central では PGP 署名が必要です。
// https://central.sonatype.org/publish/requirements/gpg/
// https://central.sonatype.org/publish/publish-gradle/#credentials
signing {
    sign publishing.publications.maven
}
```

#### 依存関係の整理

最初に挙げたとおり Embulk v0.11 以降に対応したプラグインは `org.embulk:embulk-core` に依存できません。つまり、最新のプラグインは `org.embulk:embulk-core` だけにあって `org.embulk:embulk-api` か `org.embulk:embulk-spi` に入っていないクラスを使えません。

これがプラグインの互換性にとても大きな影響があることは理解しています。ですが、将来の Embulk プラグインが複雑な依存関係の問題から解放されるように、これを強行することにしました。

たとえば `org.embulk:embulk-core` は Jackson 2.6.7 に依存しています。プラグインは `org.embulk:embulk-core` の元でロードされるので、プラグインは Jackson 2.6.7 がとても古いことをわかっていながら 2.6.7 を使わなければなりません。一方 `org.embulk:embulk-core` の Jackson を新しくするのは既存の Jackson 2.6.7 を期待しているプラグインに影響するので、簡単ではありません。板挟みになっていたのです。

また `org.embulk:embulk-core` には、プラグインのためのユーティリティクラスもたくさんありました。Embulk の開発チームが新しい機能のために 変更を加えたときに、予想外に多くのプラグインが影響を受けるようなことが何度もありました。そのため Embulk 本体に改善を加えることをためらうようになっていました。

ひとたびほとんどのプラグインが v0.11 対応になったら、どの Jackson バージョンを使うかは完全にプラグインの自由になります。また Embulk 本体の変更からも影響を受けにくくなります。

Embulk v0.11 以降 `org.embulk:embulk-api` と `org.embulk:embulk-spi` は Embulk 本体とプラグインの間の「契約 (contract)」になります。これらはあまり頻繁には更新されず、プラグインが本体側の変更に影響されないよう、互換性を保つように注意深くメンテナンスされます。一方 `org.embulk:embulk-core` の方は、新しい機能のためにもっと頻繁に更新されます。

`org.embulk:embulk-api` と `org.embulk:embulk-spi` は `org.embulk:embulk-core` とは異なるバージョン体系になります。 `embulk-api` と `embulk-spi` のバージョンは `org.embulk:embulk-core` と違って、単に `0.11`, `1.0`, `1.1`, `1.2` のようになります。この一桁目と二桁目も同期しません。たとえば `org.embulk:embulk-core:1.3.2` が `org.embulk:embulk-api:1.1` and `org.embulk:embulk-spi:1.1` を想定する、というようなこともありえます。

`org.embulk:embulk-api:0.11` と `org.embulk:embulk-spi:0.11` は Embulk v0.11.0 と同時にリリースされます。同様に `org.embulk:embulk-api:1.0` と `org.embulk:embulk-spi:1.0` は Embulk v1.0.0 と同時にリリースされます。しかし、以降のバージョンのリリースはあまり頻繁ではなく API と SPI に変更があったときのみリリースされます。

##### Embulk config の処理

これまで Embulk プラグインは config を処理するのに `org.embulk.config.ConfigSource#loadConfig` と `org.embulk.config.TaskSource#loadTask` を使ってきました. しかし、これらはもう非推奨です。外部ライブラリになった [`org.embulk:embulk-util-config`](https://dev.embulk.org/embulk-util-config/) を代わりに使ってください。

```
compile "org.embulk:embulk-util-config:0.3.0"
```

使い方はそこまで複雑ではありません。まず `@Config`, `@ConfigDefault`, `Task` を `embulk-util-config` のものに置き換えてください。

```
- import org.embulk.config.Config;
- import org.embulk.config.ConfigDefault;
- import org.embulk.config.Task;
+ import org.embulk.util.config.Config;
+ import org.embulk.util.config.ConfigDefault;
+ import org.embulk.util.config.Task;
```

そしてプラグインの `Task` 定義をチェックしてください。これが `Task` (`org.embulk.config.Task` => `org.embulk.util.config.Task`) のみを継承しているなら、特に問題はありません。もしこれが他の古い interface を継承していたら (典型的なのはたとえば `TimestampParser.Task`) 代わりになる `org.embulk.util.config.*` を使った新しいものを探すか、ユーザーから見て互換になるように中のメソッド定義をコピーしてきてください。

```
public interface PluginTask extends Task, org.embulk.spi.time.TimestampParser.Task {  // => TimestampParser.Task を消す
    // ...

    // org.embulk.spi.time.TimestampParser.Task からコピー
    @Config("default_timezone")
    @ConfigDefault("\"UTC\"")
    String getDefaultTimeZoneId();

    // org.embulk.spi.time.TimestampParser.Task からコピー
    @Config("default_timestamp_format")
    @ConfigDefault("\"%Y-%m-%d %H:%M:%S.%N %z\"")
    String getDefaultTimestampFormat();

    // org.embulk.spi.time.TimestampParser.Task からコピー
    @Config("default_date")
    @ConfigDefault("\"1970-01-01\"")
    String getDefaultDate();
}
```

次に `org.embulk.util.config.ConfigMapperFactory` のインスタンスを用意してください。

```
import org.embulk.util.config.ConfigMapperFactory;

private static final ConfigMapperFactory CONFIG_MAPPER_FACTORY = ConfigMapperFactory.builder().addDefaultModules().build();
```

Embulk config から標準的ではないクラスへのマッピングが必要なときは、任意の Jackson [Module](https://fasterxml.github.io/jackson-databind/javadoc/2.6/com/fasterxml/jackson/databind/Module.html) を追加できます。

```
private static final ConfigMapperFactory CONFIG_MAPPER_FACTORY =
        ConfigMapperFactory.builder().addDefaultModules().addModule(new SomeJacksonModule()).build();
```

Apache BVal を使って config の検証を有効にすることもできます。

```
import javax.validation.Validation;
import javax.validation.Validator;
import org.apache.bval.jsr303.ApacheValidationProvider;

private static final Validator VALIDATOR =
        Validation.byProvider(ApacheValidationProvider.class).configure().buildValidatorFactory().getValidator();

private static final ConfigMapperFactory CONFIG_MAPPER_FACTORY =
        ConfigMapperFactory.builder().addDefaultModules().withValidator(VALIDATOR).build();
```

最後に `loadConfig` と `loadTask` を `org.embulk.util.config.ConfigMapper#map` と `org.embulk.util.config.TaskMapper#map` にそれぞれ置き換えてください。

```
+ import org.embulk.util.config.ConfigMapper;
+ import org.embulk.util.config.TaskMapper;

- PluginTask task = config.loadConfig(PluginTask.class);
+ final ConfigMapper configMapper = CONFIG_MAPPER_FACTORY.createConfigMapper();
+ final PluginTask task = configMapper.map(config, PluginTask.class);

- PluginTask task = taskSource.loadTask(PluginTask.class);
+ final TaskMapper taskMapper = CONFIG_MAPPER_FACTORY.createTaskMapper();
+ final PluginTask task = taskMapper.map(taskSource, PluginTask.class);
```

`embulk-util-config` 自体が Jackson に依存しているので、これを使うとプラグインは Jackson への依存を直接持つようになります。

プラグインが Embulk v0.9 でもしばらくは動くようにするためには、新しい Embulk v0.11.0 がリリースされてもしばらく Jackson 2.6.7 のままにしておくことを、ぜひ検討してください。他の多くのプラグインが v0.11 対応になり、多くのユーザーが v0.11 以降を使うようになったら、どの Jackson バージョンを使っても動くはずです!

##### 日付・時刻とタイムゾーンの扱い

[Joda-Time](https://www.joda.org/joda-time/) is removed from Embulk. `org.embulk.spi.time.TimestampFormatter` and `org.embulk.spi.time.TimestampParser` are deprecated. Please use Java 8's `java.time` standard classes, and an external library [`org.embulk:embulk-util-timestamp`](https://dev.embulk.org/embulk-util-timestamp/) instead.

```
compile "org.embulk:embulk-util-timestamp:0.2.1"
```

Embulk's [`org.embulk.spi.time.Timestamp`](https://dev.embulk.org/embulk-api/0.10.31/javadoc/org/embulk/spi/time/Timestamp.html) is deprecated. Use [`java.time.Instant`](https://docs.oracle.com/javase/jp/8/docs/api/java/time/Instant.html) instead.

Joda-Time's [`DateTime`](https://www.joda.org/joda-time/apidocs/org/joda/time/DateTime.html) would be replaced with [`java.time.OffsetDateTime`](https://docs.oracle.com/javase/8/docs/api/java/time/OffsetDateTime.html) or [`java.time.ZonedDateTime`](https://docs.oracle.com/javase/8/docs/api/java/time/ZonedDateTime.html). If `OffsetDateTime` is sufficient for you, we'd suggest `OffsetDateTime`. The complexity of time zones based on geographical regions would easily get everything messed up. (Imagine that your plugin receives `2017-03-12 02:30:00` against a default time zone setting `America/Los_Angeles`.)

Joda-Time's [`DateTimeZone`](https://www.joda.org/joda-time/apidocs/org/joda/time/DateTimeZone.html) would be replaced with [`java.time.ZoneOffset`](https://docs.oracle.com/javase/8/docs/api/java/time/ZoneOffset.html) or [`java.time.ZoneId`](https://docs.oracle.com/javase/8/docs/api/java/time/ZoneId.html). For reasons similar to the above, we'd suggest to restrict it to `ZoneOffset` if it is sufficient for you.

Embulk's `org.embulk.spi.time.TimestampFormatter` and `org.embulk.spi.time.TimestampParser` are deprecated. Use `embulk-util-timestamp`'s [`org.embulk.util.timestamp.TimestampFormatter`](https://dev.embulk.org/embulk-util-timestamp/0.2.1/javadoc/org/embulk/util/timestamp/TimestampFormatter.html) instead. The typical "as-is" migration would be like below:

```
// Define your own PluginTask with embulk-util-config's org.embulk.util.config.Task.
private interface PluginTask extends org.embulk.util.config.Task {
    // ...

    // From org.embulk.spi.time.TimestampParser.Task.
    @Config("default_timezone")
    @ConfigDefault("\"UTC\"")
    String getDefaultTimeZoneId();

    // From org.embulk.spi.time.TimestampParser.Task.
    @Config("default_timestamp_format")
    @ConfigDefault("\"%Y-%m-%d %H:%M:%S.%N %z\"")
    String getDefaultTimestampFormat();

    // From org.embulk.spi.time.TimestampParser.Task.
    @Config("default_date")
    @ConfigDefault("\"1970-01-01\"")
    String getDefaultDate();
}

// Define your own TimestampColumnOption compatible with org.embulk.spi.time.Timestamp{Formatter|Parser}.TimestampColumnOption.
private interface TimestampColumnOption extends org.embulk.util.config.Task {
    @Config("timezone")
    @ConfigDefault("null")
    java.util.Optional<String> getTimeZoneId();

    @Config("format")
    @ConfigDefault("null")
    java.util.Optional<String> getFormat();

    @Config("date")
    @ConfigDefault("null")
    java.util.Optional<String> getDate();
}

// Get the entire configuration.
final PluginTask task = configMapper.map(configSource, PluginTask.class);

// Get per-column option with embulk-util-config.
final TimestampColumnOption columnOption = configMapper.map(columnConfig.getOption(), TimestampColumnOption.class);

// Build TimestampFormatter.
final TimestampFormatter formatter = TimestampFormatter
        .builder(columnOption.getFormat().orElse(task.getDefaultTimestampFormat(), true)
        .setDefaultZoneFromString(columnOption.getTimeZoneId().orElse(task.getDefaultTimeZoneId()))
        .setDefaultDateFromString(columnOption.getDate().orElse(task.getDefaultDate()))
        .build();

Instant instant = formatter.parse("2019-02-28 12:34:56 +09:00");
System.out.println(instant);  // => "2019-02-28T03:34:56Z"

String formatted = formatter.format(Instant.ofEpochSecond(1009110896));
System.out.println(formatted);  // => "2017-12-23 12:34:56 UTC"
```

##### Using Jackson and JSON

`org.embulk:embulk-core` no longer has dependencies on Jackson. If your plugin needs Jackson for itself, it needs to have dependencies on Jackson by itself.

If your plugin has started to use `org.embulk:embulk-util-config` described above, your plugin should already have dependencies on Jackson (2.6.7). You can add some more Jackson sub-librarires by yourself.

Embulk's `org.embulk.spi.json.JsonParser` is deprecated. Use [`org.embulk:embulk-util-json`](https://dev.embulk.org/embulk-util-json/) instead. The usage is almost the same.

As described above, please consider keeping your plugin with Jackson 2.6.7 for a while from Embulk v0.11.0 so that the plugin can still work with the old stable Embulk v0.9.

##### Using Google Guava and/or Apache Commons Lang 3

`org.embulk:embulk-core` no longer has dependencies on Google Guava nor Apache Commons Lang 3. If your plugin uses them, it needs to be rewritten to Java 8's standard classes, or to have dependencies on them by itself.

Java 8 is powerful enough. Unless your plugin has a heavy use of Google Guava or Apache Commons Lang 3, we'd basically recommend you to rewrite them with Java 8's standard classes. They (especially Guava) often introduce incompatibility that could frustrates you.

At least, Guava's [`com.google.common.base.Optional`](https://guava.dev/releases/18.0/api/docs/com/google/common/base/Optional.html) no longer works with `embulk-util-config`. It needs to be replaced with [`java.util.Optional`](https://docs.oracle.com/javase/8/docs/api/java/util/Optional.html).

For typical use-cases of Guava:

* Guava's immutable collections could be replaced with [`java.util.Collections`](https://docs.oracle.com/javase/8/docs/api/java/util/Collections.html) `unmodifiable*`.
* Guava's [`Throwables`](https://guava.dev/releases/18.0/api/docs/com/google/common/base/Throwables.html) has been deprecated. Read [Guava's document](https://github.com/google/guava/wiki/Why-we-deprecated-Throwables.propagate).
* Guava's [`Preconditions`](https://guava.dev/releases/18.0/api/docs/com/google/common/base/Preconditions.html) can be replaced simply.

##### Using Guice

Stop using Guice in your plugin if possible.

If it does not seem possible, for example if another dependency has a dependency on Guice, we'd suggest to have a dependency on Guice explicitly. But, note that it may make your plugin not to work with older Embulk v0.9.

##### Using JRuby (`org.jruby` classes)

Stop using JRuby in your plugin.

A typical use-case of JRuby has been to use Ruby's date-time formatter. It can be replaced with [`embulk-util-timestamp`](https://dev.embulk.org/embulk-util-timestamp/) or [`embulk-util-rubytime`](https://dev.embulk.org/embulk-util-rubytime/).

##### Using FindBugs

`org.embulk:embulk-core` no longer has a dependency on FindBugs `com.google.code.findbugs:annotations` (for `@SuppressFBWarnings`).

[FindBugs](http://findbugs.sourceforge.net/) is known to be no longer maintained. We'd at least suggest to stop using FindBugs.

[SpotBugs](https://spotbugs.github.io/) can be a good alternative to FindBugs. But, the Embulk core will not provide any special support for plugins to use SpotBugs. Please give it a try by yourself.

##### Prepare for Java 11+

The Java eco-system needs to be prepared for later Java versions. A big jump there is from Java 8 to Java 11+. Java EE classes are removed from the Java runtime environments from Java 11. If your plugin uses those classes, it will stop working with Java 11+. JAXB `javax.xml.*` is a typical use-case. See [JEP 320](https://openjdk.java.net/jeps/320) for the details.

When Embulk (v0.11+) detects a plugin using a class that is removed by JEP 320, it just logs a warning message like an example below even on Java 8.

```
Class javax.xml.bind.JAXB is loaded by the parent ClassLoader, which is removed by JEP 320. The plugin needs to include it on the plugin side. See https://github.com/embulk/embulk/issues/1270 for more details.
```

Embulk, as a framework, will not provide any more special help with them. If your plugin uses those Java EE classes, please add alternative dependencies in the plugin by yourself.

Some typical examples are shown below.

```
// Adding dependencies on JAXB explicitly.

// JAXB 2.2.11 is chosen here because:
// 1. JDK 8's bundled JAXB is 2.2.8. Better with a closer version while we are on Java 8.
//    https://javaee.github.io/jaxb-v2/doc/user-guide/ch02.html#a-2-2-8
// 2. Neither com.sun.xml.bind:jaxb-core:2.2.8 nor com.sun.xml.bind:jaxb-impl:2.2.8 does not exist on Maven Central.
// 3. 2.2.11 looks to be used by the most Java libraries among JAXB 2.2.
//    https://mvnrepository.com/artifact/javax.xml.bind/jaxb-api
//    https://mvnrepository.com/artifact/com.sun.xml.bind/jaxb-core
//    https://mvnrepository.com/artifact/com.sun.xml.bind/jaxb-impl
// 4. JAXB 2.2.8 and 2.2.11 look to have the same set of classes.
//    Although their internal implementations are a bit different, class loaders would not be confused.
compile "javax.xml.bind:jaxb-api:2.2.11"
compile "com.sun.xml.bind:jaxb-core:2.2.11"
compile "com.sun.xml.bind:jaxb-impl:2.2.11"
```

```
// Adding a dependency on the Activation Framework explicitly.

// The Activation Framework is often required along with JAXB.
// 1.1.1 is chosen because it was the latest version when JAXB 2.2.11 was released.
compile "javax.activation:activation:1.1.1"
```

```
// Adding a dependency on the Annotation API explicitly.

// 1.2 is chosen because only 1.2 should have been available in the age of Java 8.
// https://mvnrepository.com/artifact/javax.annotation/javax.annotation-api
compile "javax.annotation:javax.annotation-api:1.2"
```

##### Log

`Exec.getLogger` is deprecated. Use [SLF4J](http://www.slf4j.org/)'s [`org.slf4j.LoggerFactory.getLogger`](https://www.javadoc.io/doc/org.slf4j/slf4j-api/1.7.30/org/slf4j/LoggerFactory.html) directly.

##### Other utility classes in `org.embulk:embulk-core`

* Processing file-like byte sequence (ex. `FileInputInputStream` and `FileOutputOutputStream` in `org.embulk.spi.util`)
    * Exported as [`embulk-util-file`](https://dev.embulk.org/embulk-util-file/)
* Processing text (ex. `LineDecoder` and `LineEncoder` in `org.embulk.spi.util`)
    * Exported as [`embulk-util-text`](https://dev.embulk.org/embulk-util-text/)
* Dynamic column setter (ex. `DynamicColumnSetter` in `org.embulk.spi.util`)
    * Exported as [`embulk-util-dynamic`](https://dev.embulk.org/embulk-util-dynamic/)
* Retries (ex. `RetryExecutor` in `org.embulk.spi.util`)
    * Exported as [`embulk-util-retryhelper`](https://dev.embulk.org/embulk-util-retryhelper/)

#### Summary of replacement

##### Processing Embulk configurations

| Old | New |
|---|---|
| `@Config` | `@org.embulk.util.config.Config` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) |
| `@ConfigDefault` | `@org.embulk.util.config.ConfigDefault` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) |
| `@ConfigInject` | `Exec.get???()` (for example, `Exec.getBufferAllocator`) |
| `ConfigSource#loadConfig` | `ConfigMapper#map` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) |
| `TaskSource#loadTask` | `TaskMapper#map` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) |
| `Task` | `org.embulk.util.config.Task` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) |
| `ColumnConfig` | `org.embulk.util.config.units.ColumnConfig` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) |
| `SchemaConfig` | `org.embulk.util.config.units.SchemaConfig` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) |
| `ModelManager` | Stop using it, and build your own Jackson `ObjectMapper` |
| `LocalFile` in `PluginTask` | Use `org.embulk.util.config.modules.LocalFileModule` and `org.embulk.util.config.units.LocalFile` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) |
| `Charset` in `PluginTask` | Use `org.embulk.util.config.modules.CharsetModule` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) |
| `Column` in `PluginTask` | Use `org.embulk.util.config.modules.ColumnModule` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) |
| `Schema` in `PluginTask` | Use `org.embulk.util.config.modules.SchemaModule` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) |
| `Type` in `PluginTask` | Use `org.embulk.util.config.modules.TypeModule` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) |

##### Handling date/time and time zones

| Old | New |
|---|---|
| `org.joda.time.DateTime` | `java.time.OffsetDateTime` or `java.time.ZonedDateTime` |
| `org.joda.time.DateTimeZone` | `java.time.ZoneOffset` or `java.time.ZoneId` |
| `org.joda.time.DateTimeZone` in `PluginTask` | `java.time.ZoneId` with `org.embulk.util.config.modules.ZoneIdModule` in [embulk-util-config](https://dev.embulk.org/embulk-util-config/) if needed |
| `Timestamp` | `java.time.Instant` as far as possible |
| `TimestampFormatter` | `org.embulk.util.timestamp.TimestampFormatter` in [embulk-util-timestamp](https://dev.embulk.org/embulk-util-timestamp/) |
| `TimestampParser` | `org.embulk.util.timestamp.TimestampFormatter` in [embulk-util-timestamp](https://dev.embulk.org/embulk-util-timestamp/) |

##### Using Jackson and JSON

| Old | New |
|---|---|
| `org.embulk.spi.json.*` | `org.embulk.util.json.*` in [embulk-util-json](https://dev.embulk.org/embulk-util-json/) |

##### Using Google Guava and/or Apache Commons Lang 3

| Old | New |
|---|---|
| Guava `Optional` | `java.util.Optional` |
| Guava `Throwables` | Read [Guava's document](https://github.com/google/guava/wiki/Why-we-deprecated-Throwables.propagate) |

##### Using JRuby (`org.jruby` classes)

| Old | New |
|---|---|
| `org.jruby.*` | Stop using it -- [embulk-util-rubytime](https://dev.embulk.org/embulk-util-rubytime/) may work for parsing date-time  |

##### Using FindBugs

| Old | New |
|---|---|
| `@SuppressFBWarnings` | Remove it now |

##### Prepare for Java 11+

| Old | New |
|---|---|
| `javax.*` | See [JEP 320](https://openjdk.java.net/jeps/320), and check if it's removed in Java 11+ ([Issue](https://github.com/embulk/embulk/issues/1270)) |

##### Log

| Old | New |
|---|---|
| `Exec.getLogger` | `org.slf4j.LoggerFactory.getLogger` |

##### Other utility classes in `org.embulk:embulk-core`

| Old | New |
|---|---|
| `org.embulk.spi.util.*` | [embulk-util-file](https://dev.embulk.org/embulk-util-file/), [embulk-util-text](https://dev.embulk.org/embulk-util-text/), [embulk-util-dynamic](https://dev.embulk.org/embulk-util-dynamic/), or [embulk-util-retryhelper](https://dev.embulk.org/embulk-util-retryhelper/) |

#### Tests

Tests still need to depend on `org.embulk:embulk-core`, and in addition, `org.embulk:embulk-deps`.

```
testCompile "org.embulk:embulk-core:0.10.??"
testCompile "org.embulk:embulk-deps:0.10.??"
```

You may want to use some internal (`embulk-core`-only) classes in tests. Typical instances can be retrieved from `org.embulk.spi.ExecInternal`, such as `ExecInternal.getModelManager()` to get `org.embulk.config.ModelManager`.

Note that such internal classes may easily drop its compatibility. For example, `ModelManager` has already dropped `public <T> T readObject(Class<T>, com.fasterxml.jackson.core.JsonParser)` and `public <T> T readObjectWithConfigSerDe(Class<T>, com.fasterxml.jackson.core.JsonParser)`.

The testing framework would be improved through v0.11.
