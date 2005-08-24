# blog-category.rb $Revision: 1.9 $
#
# Usage:
#
#  Select blog-category.rb in 'Preferece' -> 'sp'.
#  You should initialize the category index file in 'Prefernce' -> 'Categorize blogkit'.
#  You can read the detailed documentation in the same page.
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

require 'pstore'

def blog_category
	cat = @cgi.params['blogcategory'][0]
	if cat and !cat.empty?
		cat
	else
		nil
	end
end

if /^(latest|month|day|append|replace|comment|showcomment|saveconf|trackbackreceive|pingbackreceive)$/ =~ @mode
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
if /^showcomment$/ =~ @mode then
	eval(<<-'MODIFY_CLASS', TOPLEVEL_BINDING)
		module TDiary
			module DiaryBase
				def title
					return @title ? @title : ''
				end
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

add_conf_proc( 'blog_category', @blog_category_conf_label, 'basic' ) do
	if @mode == 'saveconf' and @cgi.valid?('blog_category_initialize')
		blog_category_cache_initialize
	end

	r = ''
	r << @blog_category_desc_label unless @conf.mobile_agent?
	r << @blog_category_desc_label_for_mobile if @conf.mobile_agent?
	r
end

# vim: ts=3
