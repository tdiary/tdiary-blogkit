# tDiary BlogKit: tDiaryをblog風に運用する

## はじめに

tDiary BlogKitは、tDiaryをblogのように日単位でなく記事単位で管理するシステムに改造するキットです。BlogKitを全面的に適用したtDiaryは、日記システムとしてのtDiaryに対して、以下のような違いを持ちます。

 * 日付が意味を持たなくなる(記事番号扱いになる)
 * 記事に「最終更新時刻(Last-Modified)」が付くようになる
 * 最新表示時には、記事の最初のセクションだけが表示される(似非サマリ)
 * 「更新」を選ぶと、自動的に空いている記事番号を割り当ててくれる
 * Recent EntoriesやWhat's Newで更新情報が公開される

tDiary BlogKitは、tDiaryには影響を与えずに、すべてファイル追加のみで導入できます。

## インストール

すでにtDiaryはインストール済みだとします。tDiaryは2.1.3もしくはそれ以降のできるだけ新しいものを推奨します。すでに運用中の日記ではなく、新たにblog系サイトを作るという前提で説明します。すでに運用中の日記に適用する場合には、tdiary.confのマージ作業などが必要になります(ただし日記とは管理単位が異なるので、すでにある日記にBlogKitを適用するのはオススメできません)。
### tdiary.confを作成

付属のtdiary.conf.sample\_jaを、tDiaryのインストールディレクトリにtdiary.confとしてコピーします。そして、@data\_pathをデータの保存場所に書き換えます。詳しくはtDiaryのドキュメントを参照してください。付属のサンプルには、ヘッダやフッタなどにblog風のレイアウト指定が施されています。これらのカスタマイズは、運用開始後に設定画面から行ってください。

tdiary.conf.sample_jaは日本語向けのサンプルです。英語向けにはtdiary.conf.sampleを使ってください。

### スタイルをコピー

tdiary/style/blog.rbを、tDiaryインストールディレクトリのtdiary/styleの下にコピーします。このファイルは、BlogKit向けのさまざまな機能拡張を含んでいるので、他のスタイルを使う場合にもかならずコピーする必要があります。

tDiaryではさまざまな記法を使えます(スタイル機能)。BlogKitでは、すでに提供されているスタイルをベースに、blog向けにカスタマイズした専用のスタイルをいくつか提供しています。以下の3種類が提供されているので、好みの応じて使うようにして下さい。

なお、必要のないスタイルファイル(style/*.rb)をインストールすると、エラーの原因になりますので、以下の説明をよく読んで、不要なファイルを入れないように注意してください。ただし、先に書いたように、style/blog.rbはかならずコピーしてください。これを忘れると、記事の自動採番機能が効かなくなります。

#### tDiaryスタイルを使う場合

必要なファイル(tdiary/style/blog.rb)のコピーは済んでいると思います。スタイルの指定も、先に作成したのtdiary.confに「@style = 'Blog'」の指定がすでにあるはずなので、確認してください。

#### Wikiスタイルを使う場合

style/blogwiki.rbをtdiary/style下にコピーし、@styleには'BlogWiki'を指定します。Wikiスタイルを使用しない場合には、この作業は行わないで下さい。

#### RDスタイルを使う場合

まずRDスタイルを導入して下さい(tdiary-style-rd gemをインストールします)。その上で、style/blogrd.rbをtdiary下にコピーし、@styleには'BlogRD'を指定します。RDスタイルを使用しない場合には、この作業は行わないで下さい。

### テーマをコピー

theme/blogを、tDiaryのインストールディレクトリにあるthemeにコピーします。このblogテーマはtDiaryの標準的テーマですが、サイドバーを使ったレイアウトのための設定や、blog用プラグインのための設定が追加されています。もちろん、通常のtDiary向けテーマも使えますが、微調整が必要かもしれません。

### プラグインの設定

tDiary 2.0.1からは、プラグイン選択が設定画面からできるようになっています。BlogKit専用のプラグインも、ここから選択できるようにします。プラグイン選択がBlogKitを展開したディレクトリを参照できるように、tdiary.confにある以下の設定を修正してください。

    @options['sp.path'] = ['misc/plugin', 'blogkit/plugin']

このオプションは複数のパスを指定できます。ひとつ目はtDiaryのプラグイン集のパスを指定してあるので、ふたつ目をBlogKitで配布されているプラグインのパスにしてあります。

もちろん、tDiaryのpluginディレクトリに、必要なプラグインをコピーする従来のインストール方法でもかまいません。

### あとはtDiary同様に動かすだけ

記事を追加するときには、画面下の「更新」をクリックします。日付は最新のものが自動的に入るので、「更新」時には常に新しい記事の追加になります。また、既存の記事の編集は、その記事を開いてから画面下の「編集」をクリックすることで行えます。

まず最初に、設定画面に入って、必要なプラグインを選択しましょう。

## プラグイン解説

ここでは各プラグインの概要のみ解説します。指定方法などは個々のプラグインファイルを見てください。

### archive.rb

#### archiveプラグイン

過去記事一覧を表示します。サイドバーにデフォルトで配置されています。記事はグループ化されており(ようするに月単位ですが、BlogKitでは日付に意味がないので00001からの連番です)、新しい順に表示します。

#### archive\_dropdownプラグイン

archiveと同様の一覧を、ドロップダウンリストで表示します。

### blog-style.rb

tDiaryとはやや異なった用語を使うblogツールに合わせて、各所の文字列を置き換えるプラグインです。また、タイトルの表現を変えるなど、1ページに1トピックというblog風体裁を整えるためには導入必須のプラグインだと考えてください。

### lm.rb

Last-Modifiedを表示するプラグインです。タイトル下か、記事最下部のどちらに表示するか、tdiary.confで選択可能です。

### recent-entry.rb

最新の記事一覧を、新しい順に表示します。

### title-navi.rb

tDiaryでは「前日」「翌日」になっていたナビゲーションボタンを、記事のタイトルで置き換えます。ただし、月をまたぐ場合には、「Prev」「Next」という表記になります。

### whatsnew-list.rb

記事が更新された順に一覧表示を行います。recent-entryと違い、過去の記事を更新しても上位に入れ替わります。secureモードでは動きません。また、設定画面からの指定によって、RDFファイルを生成することが可能です。

### blog-category.rb

カテゴリ機能を追加します。タイトル中の [ ] で囲んだ文字列がカテゴリ名として認識されます。カテゴリ名をクリックするとそのカテゴリの記事のみを表示する画面に移ります。設定画面からカテゴリインデックスの初期化を行う必要があります。

#### blog\_category\_entryプラグイン

カテゴリ別画面に表示しきれなかった記事のタイトルを新しい順に表示します。

#### blog\_category\_formプラグイン

表示するカテゴリを選択できるドロップダウンリストを表示します。

### title-link.rb

記事のタイトル全体をPermalinkへのリンクにします。従来のアンカー文字よりもPermalinkであることがよりわかりやすくなります。ただし、タイトル中にリンクを含めることができなくなりますので、運用に照らし合わせて使ってください。

## ライセンス

GPLの元で改造、配布が可能です。

作者はただただし<sho@spc.gr.jp>です。

BlogKitに関する最新情報は、http://www.tdiary.org/ で得られます。
