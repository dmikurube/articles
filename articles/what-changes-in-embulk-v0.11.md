---
title: "Embulk v0.11 でなにが変わるのか: ユーザーの皆様へ"
emoji: "🚢" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [ "embulk" ]
layout: default
published: true
---


### Embulk System Properties とディレクトリ

Embulk のシステム全体の設定を行っていた "System Config" の代わりに Embulk v0.11 では "Embulk System Properties" が導入されました。旧 System Config が Embulk の `ConfigSource` をベースにしていたのと違って Embulk System Properties は [Java の `Properties`](https://docs.oracle.com/javase/jp/8/docs/api/java/util/Properties.html) をベースにしています。

Java の `Properties` は、実際のところ JSON と同等の表現力があった `ConfigSource` より表現力が弱いです。それでも Properties を使うことにしたのは、外部ライブラリを追加することなく Java プロセスの一番最初からロードできるからです。

旧 System Config は `ConfigSource` の高い表現力を活用していませんでした。 System Config を設定するコマンドラインオプションの `-X` は Properties と同様の、文字列のキーに対して文字列の値を設定するだけのものでした。内部的には、いくつかの System Config はリストのような複雑な構造を使っていましたが、どれも単純な文字列に置き換えることができるものでした。実際のところ `ConfigSource` ほどの表現力は必要なかったのです。

ユーザー視点では、旧 System Config からなにか悪くなったようには見えないでしょう。その一方で、以下で説明していくようなメリットが Properties の力で実現できました。

#### Embulk home

Embulk v0.11 では "Embulk home" ディレクトリという新しいコンセプトを導入しました。これは v0.9 までハードコードされていた `~/.embulk/` と同等のものです。

特別な設定や特別なファイルを用意しない限り Embulk v0.11 は v0.9 と同様に `~/.embulk/` を Embulk home として動きます。 Embulk home ディレクトリは、以下のルールで選ばれます。

1. コマンドラインからオプション `-X` で Embulk System Properties `embulk_home` を設定すると Embulk home ディレクトリを最高優先度で設定できます。これは絶対パスか、またはカレント・ディレクトリ ([Java `user.dir`](https://docs.oracle.com/javase/tutorial/essential/environment/sysprop.html)) からの相対パスです。
2. 環境変数 `EMBULK_HOME` を設定すると、二番目の優先度で Embulk home ディレクトリを設定することができます。これは絶対パスのみです。
3. 1 と 2 のどちらも設定されていなければ Embulk は、カレント・ディレクトリ ([Java `user.dir`](https://docs.oracle.com/javase/tutorial/essential/environment/sysprop.html)) から親ディレクトリに向かって順に移動しながら `.embulk/` という名前で、かつ `embulk.properties` という名前の通常ファイルを直下に含むディレクトリを探します。そのようなディレクトリが見つかれば、、そのディレクトリが Embulk home ディレクトリとして設定されます。
    * もしカレント・ディレクトリがユーザーのホーム・ディレクトリ ([Java `user.home`](https://docs.oracle.com/javase/tutorial/essential/environment/sysprop.html)) 以下であれば、探索はホーム・ディレクトリで止まります。そうでなければ、探索はルート・ディレクトリまで続きます。
4. もし上記のいずれにも当たらなければ Embulk home ディレクトリは今までどおりの `~/.embulk` に設定されます。

それから Embulk home ディレクトリ直下にある `embulk.properties` ファイル ([Java の `.properties` フォーマット](https://docs.oracle.com/javase/jp/8/docs/api/java/util/Properties.html#load-java.io.Reader-)) が、自動的に Embulk System Properties としてロードされます。

最後に Embulk System Property `embulk_home` が、見つかった Embulk home ディレクトリで強制的に上書きされます。

#### m2_repo, gem_home, and gem_path

次に重要なディレクトリの設定が、どこから Embulk プラグインをロードするかです。それも Embulk System Properties `m2_repo`, `gem_home`, `gem_path` と Embulk home ディレクトリから設定されます。

Embulk System Properties `gem_home` と `gem_path` 

The Embulk System Properties `gem_home` and `gem_path` are used to configure JRuby by calling [`Gem.use_paths`](https://www.rubydoc.info/stdlib/rubygems/Gem.use_paths). Note that environment variables `GEM_HOME` and `GEM_PATH` are untouched. The Gem configurations could be reset unexpecteldy with the environment variables in case `Gem.clear_paths` is called somewhere.

1. If Embulk System Properties `m2_repo`, `gem_home`, or `gem_path` are set from the command line (`-X`), the Embulk System Propertis are set to those in the highest priority. The settings should be absolute paths, or relative paths from the working directory ([Java `user.dir`](https://docs.oracle.com/javase/tutorial/essential/environment/sysprop.html)). Then, these Embulk System Properties are reset to their absolute paths.
2. If Embulk System Property `m2_repo`, `gem_home`, or `gem_path` are set in the `embulk.properties` file, the Embulk System Properties are set to those in the second priority. The settings should be absolute paths, or relative paths from the Embulk home directory. Then, these Embulk System Properties are reset to their absolute paths.
3. If environment variables `M2_REPO`, `GEM_HOME`, or `GEM_PATH` are set, the corresponding Embulk System Properties are set to those in the third priority. The settings should be absolute paths.
4. If none of the above does not match, `m2_repo` is set to `${embulk_home}/lib/m2/repository`, `gem_home` is set to `${embulk_home}/lib/gems`, and `gem_path` is set to empty.

The Embulk System Properties `m2_repo`, `gem_home`, and `gem_path` are finally reset forcibly to absolute paths of the directories identified.
