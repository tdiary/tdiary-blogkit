# blog-category.rb $Revision: 1.1 $
#
#  resource file for blog-category.rb
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

@blog_category_conf_label = 'blogkitカテゴリ'
@blog_category_desc_label = <<HTML
	<h3 class="subtitle">カテゴリ機能の使い方</h3>
	<p>blogkitでは，記事のタイトルでその記事のカテゴリを指定します．カテゴリ名を [ ] で囲んで指定します．</p>
	<p>例：</p>
	<pre>[blogkit] カテゴリ機能を導入しました</pre>
	<p>このように書くと，実際に記事を表示する際に [blogkit] の部分がカテゴリ表示画面へのリンクへ自動的に変換されます．一つの記事にいくつでもカテゴリを指定することができます．</p>
	<p>サイドバーなどにカテゴリに関連する情報を表示させたい場合は，<a href="#{@update}?conf=header">ヘッダ・フッタ</a>でヘッダやフッタに次のような設定を追加しましょう．</p>
	<pre>&lt;div class="sidemenu"&gt;Category: &lt;/div&gt;
&lt;%=blog_category_form%&gt;
&lt;%=blog_category_entry%&gt;</pre>
	<dl>
		<dt>blog_category_form</dt>
		<dd>表示するカテゴリを選択できるドロップダウンリストを表示します．</dd>
		<dt>blog_category_entry</dt>
		<dd>選択したカテゴリの記事のうち表示しきれなかった記事のタイトル一覧を表示します．</dd>
	</dl>
	<p>blog_category_cache_restoreというメソッドで，全記事のカテゴリとタイトルを取得できるので，この情報を用いて独自の表示方法を作り込むことも可能です．</p>
	<h3 class="subtitle">カテゴリイデックスの初期化</h3>
	<p>blogkitのカテゴリ機能はカテゴリインデックスを初期化しないと使用できません．下のOKボタンを押すとカテゴリインデックスの初期化を実行します．記事の量が多い場合は多少時間がかかるかもしれません．</p>
	<p>記事を追加したり更新した時は，自動的にカテゴリ情報がインデックスに追加されますので，初期化は一度で結構です．</p>
	<p>キャッシュディレクトリにあるblog_categoryというファイルを消してしまったり，カテゴリの情報がおかしくなってしまった場合は，再度カテゴリインデックスを初期化してください．</p>
	<input type="hidden" name="blog_category_initialize" value="true">
HTML
@blog_category_desc_label_for_mobile = <<HTML
	<H3>カテゴリインデックスの初期化</H3>
	<P>下のボタンを押すとカテゴリインデックスが初期化されます．</P>
HTML

# vim: ts=3
