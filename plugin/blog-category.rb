# blog-category.rb $Revision: 1.14 $
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

def blog_category
	cat = @cgi.params['blogcategory'][0]
	if cat and !cat.empty?
		cat
	else
		nil
	end
end

# NOTICE: very illegal usage
@title_procs.insert( 0, Proc::new {|d, t| categorized_title_of_day( d, t ) } )

def categorized_title_of_day( date, title )
	r = ''
	cats, stripped = title.scan( /^((?:\[[^\]]+\])+)\s*(.*)/ )[0]
	if cats then
		cats.scan( /\[([^\]]+)\]+/ ).flatten.each do |c|
			r << %Q|[<a href="#{h @index}?blogcategory=#{h c}">#{c}</a>]|
		end
	else
		stripped = title
	end
	r + ' ' + stripped
end

if /^(latest|month|day|append|replace|comment|showcomment|saveconf|trackbackreceive|pingbackreceive)$/ =~ @mode
	eval(<<-'MODIFY_CLASS', TOPLEVEL_BINDING)
		module TDiary
			module Style
				module BaseDiary
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
			end

			class TDiaryMonth
				attr_reader :diaries
			end
		end
	MODIFY_CLASS
end

if category_param = blog_category and @mode == 'latest'
	eval(<<-'MODIFY_CLASS', TOPLEVEL_BINDING)
		module TDiary
			module Cache
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
		!diary.categories.include?(category_param)
	end

	cgi = CGI.new
	def cgi.referer; nil; end
	years.each do |ym|
		break if @diaries.keys.size >= @conf.latest_limit
		cgi.params['date'] = [ym]
		m = TDiaryMonth.new(cgi, '', @conf)
		m.diaries.delete_if do |date, diary|
			!diary.categories.include?(category_param)
		end
		@diaries.update(m.diaries)
	end
end

alias :navi_user_blog_category :navi_user
def navi_user
	r = navi_user_blog_category
	r << %Q[<span class="adminmenu"><a href="#{h @index}">#{navi_latest}</a></span>\n] if @mode == 'latest' and blog_category
	r
end

def blog_category_cache
	"blog_category"
end

def blog_category_cache_add(diary)
	transaction(blog_category_cache) do |db|
		cache = JSON.load(db.get('blog_category')) || Hash.new
		diary.categories.each do |c|
			cache[c] ||= Hash.new
			cache[c][diary.date.strftime('%Y%m%d')] = diary.stripped_title
		end
		db.set('blog_category', cache.to_json)
	end
end

def blog_category_cache_restore
	transaction(blog_category_cache) do |db|
		JSON.load(db.get('blog_category'))
	end
end

def blog_category_entry(limit = 20)
	return 'DO NOT USE IN SECURE MODE' if @conf.secure

	cache = blog_category_cache_restore
	return '' if (blog_category.nil? or cache.nil?)
	n_shown = @diaries.keys.size
	n_shown = @conf.latest_limit if n_shown > @conf.latest_limit
	dates = cache[blog_category].keys.sort.reverse[n_shown..-1]
	return '' if dates.empty?

	r = "<ul>\n"
	dates.each do |date|
		r << %Q|	<li><a href="#{h @index}#{anchor date}">#{@conf.shorten(cache[blog_category][date], limit)}</a></li>\n|
	end
	r << "</ul>\n"
end

def blog_category_form
	cache = blog_category_cache_restore
	return '' if cache.nil?

	r = <<HTML
<form method="get" action="#{h @index}">
	<div>
		<select name="blogcategory">
			<option value="">select...</option>
HTML
	cache.keys.sort.each do |cat|
		r << %Q|			<option value="#{h cat}"#{" selected" if cat == blog_category}>#{cat}</option>\n|
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

	transaction(blog_category_cache) do |db|
		cache = Hash.new
		@years.each do |y, ms|
			ms.each do |m|
				cgi.params['date'] = ["#{y}#{m}"]
				m = TDiaryMonth.new(cgi, '', @conf)
				m.diaries.each do |k, diary|
					diary.categories.each do |c|
						cache[c] ||= Hash.new
						cache[c][diary.date.strftime('%Y%m%d')] = diary.stripped_title
					end
				end
			end
		end
		db.set('blog_category', cache.to_json)
	end
end

add_conf_proc( 'blog_category', @blog_category_conf_label, 'basic' ) do
	if @mode == 'saveconf' and @cgi.valid?('blog_category_initialize')
		blog_category_cache_initialize
	end

	r = ''
	r << @blog_category_desc_label
	r
end

def blog_category_edit
	cache = blog_category_cache_restore
	return '' if cache.nil?

	ret = ''
   unless cache.keys.size == 0 then
		ret << %Q[
		<script type="text/javascript">
		<!--
		function inj_c(val){
			target = window.document.forms[0].title
			target.focus();
			target.value += val
		}
		//-->
		</script>
		]

		ret << '<div class="field title">'
		ret << "#{@blog_category_conf_label}:\n"

		cache.keys.sort.each do |cat|
			ret << %Q!| <a href="javascript:inj_c(&quot;[#{h cat}]&quot;)">#{h cat}</a>\n!
		end
		ret << "|\n</div>\n<br>\n"
	end
end

add_edit_proc do
	blog_category_edit
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
