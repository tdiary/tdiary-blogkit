# blog-category.rb $Revision: 1.2 $
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
# 使い方：
#
#  pluginディレクトリにコピーして，設定画面の「blogkitカテゴリ」から
#  カテゴリインデックスの初期化を行って下さい．
#  その他，利用方法の概要は設定画面に記述してあります．
#

def blog_category
	cat = @cgi.params['blogcategory'][0]
	if cat and !cat.empty?
		cat
	else
		nil
	end
end

if /(latest|month|day|append|replace|saveconf)/ === @mode
	eval(<<-'MODIFY_CLASS', TOPLEVEL_BINDING)
		module TDiary
			module DiaryBase
				def title
					return '' unless @title
					categories.map do |c|
						%Q|<%= blog_category_anchor("#{c}") %>|
					end.join + " #{stripped_title}"
				end

				def stripped_title
					return '' unless @title
					stripped = @title.sub(/^(\[(.*?)\])+\s*/,'')
				end

				def categories
					return [] unless @title
					cat = /^(\[([^\[]+?)\])+/.match(@title).to_a[0]
					return [] unless cat
					cat.scan(/\[(.*?)\]/).collect do |c|
						c[0].split(/,/)
					end.flatten
				end
			end

			class TDiaryMonth
				attr_reader :diaries
			end
		end
	MODIFY_CLASS
end

if blog_category and @mode == 'latest'
	eval(<<-'MODIFY_CLASS', TOPLEVEL_BINDING)
		module TDiary
			class TDiaryBase
				def cache_enable?( prefix )
					false
				end

				def store_cache( cache, prefix )
				end
			end
		end
	MODIFY_CLASS

	years = @years.collect{|y,ms| ms.collect{|m| "#{y}#{m}"}}.flatten.sort.reverse
	@diaries.keys.each {|date| years.delete(date[0, 6])}

	@diaries.delete_if do |date, diary|
		!diary.categories.include?(blog_category)
	end

	cgi = CGI.new
	def cgi.referer; nil; end
	years.each do |ym|
		break if @diaries.keys.size >= @conf.latest_limit
		cgi.params['date'] = [ym]
		m = TDiaryMonth.new(cgi, '', @conf)
		m.diaries.delete_if do |date, diary|
			!diary.categories.include?(blog_category)
		end
		@diaries.update(m.diaries)
	end
end

alias :navi_user_blog_category :navi_user
def navi_user
	r = navi_user_blog_category
	r << %Q[<span class="adminmenu"><a href="#{@index}">#{navi_latest}</a></span>\n] if @mode == 'latest' and blog_category
	r
end

def blog_category_anchor(c)
	%Q|[<a href="#{@index}?blogcategory=#{CGI::escape(c)}">#{c}</a>]|
end

def blog_category_cache
	"#{@cache_path}/blog_category"
end

def blog_category_cache_add(diary)
	PStore.new(blog_category_cache).transaction do |db|
		db['blog_category'] = Hash.new unless db.root?('blog_category')
		diary.categories.each do |c|
			db['blog_category'][c] = Hash.new unless db['blog_category'][c]
			db['blog_category'][c][diary.date.strftime('%Y%m%d')] = diary.stripped_title
		end
	end
end

def blog_category_cache_restore
	return nil unless File.exists?(blog_category_cache)
	cache = {}
	PStore.new(blog_category_cache).transaction do |db|
		cache.update(db['blog_category'])
		db.abort
	end
	cache
end

def blog_category_entry(limit = 20)
	cache = blog_category_cache_restore
	return '' if (blog_category.nil? or cache.nil?)

	n_shown = @diaries.keys.size
	n_shown = @conf.latest_limit if n_shown > @conf.latest_limit
	dates = cache[blog_category].keys.sort.reverse[n_shown..-1]
	return '' if dates.empty?

	r = "<ul>\n"
	dates.each do |date|
		r << %Q|	<li><a href="#{@index}#{anchor date}">#{@conf.shorten(cache[blog_category][date], limit)}</a></li>\n|
	end
	r << "</ul>\n"
end

def blog_category_form
	cache = blog_category_cache_restore
	return '' if cache.nil?

	r = <<HTML
<form method="get" action="#{@index}">
	<div>
		<select name="blogcategory">
			<option value="">select...</option>
HTML
	cache.keys.sort.each do |cat|
		r << %Q|			<option value="#{cat}"#{cat == blog_category ? " selected" : ""}>#{cat}</option>\n|
	end
	r << <<HTML
		</select>
		<input type="submit" value="show">
	</div>
</form>
HTML
end

add_update_proc do
	if @mode != 'comment'
		diary = @diaries[@date.strftime('%Y%m%d')]
		blog_category_cache_add(diary)
	end
end

def blog_category_cache_initialize
	cgi = CGI::new
	def cgi.referer; nil; end

	PStore.new(blog_category_cache).transaction do |db|
		db['blog_category'] = Hash.new
		@years.each do |y, ms|
			ms.each do |m|
				cgi.params['date'] = ["#{y}#{m}"]
				m = TDiaryMonth.new(cgi, '', @conf)
				m.diaries.each do |k, diary|
					diary.categories.each do |c|
						db['blog_category'][c] = Hash.new unless db['blog_category'][c]
						db['blog_category'][c][diary.date.strftime('%Y%m%d')] = diary.stripped_title
					end
				end
			end
		end
	end
end

add_conf_proc('blog_category', 'blogkitカテゴリ') do
	if @mode == 'saveconf' and @cgi.valid?('blog_category_initialize')
		blog_category_cache_initialize
	end

	r = ''
	r << <<-HTML unless @conf.mobile_agent?
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
	HTML
	r << <<-HTML
	<h3 class="subtitle">カテゴリイデックスの初期化</h3>
	#{"<p>blogkitのカテゴリ機能はカテゴリインデックスを初期化しないと使用できません．下のOKボタンを押すとカテゴリインデックスの初期化を実行します．記事の量が多い場合は多少時間がかかるかもしれません．</p>" unless @conf.mobile_agent?}
	#{"<p>記事を追加したり更新した時は，自動的にカテゴリ情報がインデックスに追加されますので，初期化は一度で結構です．</p>" unless @conf.mobile_agent?}
	#{"<p>キャッシュディレクトリにあるblog_categoryというファイルを消してしまったり，カテゴリの情報がおかしくなってしまった場合は，再度カテゴリインデックスを初期化してください．</p>" unless @conf.mobile_agent?}
	<input type="hidden" name="blog_category_initialize" value="true">
	HTML
end

# vim: ts=3
