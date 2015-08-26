# -*- coding: utf-8 -*-
# blog-category.rb $Revision: 1.4 $
#
#  resource file for blog-category.rb
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

@blog_category_conf_label = 'BlogKitカテゴリ'
@blog_category_desc_label = <<HTML
	<h3 class="subtitle">カテゴリイデックスの初期化</h3>
	<p>BlogKitのカテゴリ機能はカテゴリインデックスを初期化しないと使用できません。下のOKボタンを押すとカテゴリインデックスの初期化を実行します。記事の量が多い場合は多少時間がかかるかもしれません。</p>
	<p>記事を追加したり更新した時は，自動的にカテゴリ情報がインデックスに追加されますので、初期化は一度で結構です。</p>
	<p>キャッシュディレクトリにあるblog_categoryというファイルを消してしまったり、カテゴリの情報がおかしくなってしまった場合は、再度カテゴリインデックスを初期化してください。</p>
	<input type="hidden" name="blog_category_initialize" value="true">
HTML

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
