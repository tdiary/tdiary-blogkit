# blog-category.rb $Revision: 1.3 $
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
# �Ȥ�����
#
#  plugin�ǥ��쥯�ȥ�˥��ԡ����ơ�������̤Ρ�blogkit���ƥ���פ���
#  ���ƥ��ꥤ��ǥå����ν������ԤäƲ�������
#  ����¾��������ˡ�γ��פ�������̤˵��Ҥ��Ƥ���ޤ���
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

add_conf_proc('blog_category', 'blogkit���ƥ���') do
	if @mode == 'saveconf' and @cgi.valid?('blog_category_initialize')
		blog_category_cache_initialize
	end

	r = ''
	r << <<-HTML unless @conf.mobile_agent?
	<h3 class="subtitle">���ƥ��굡ǽ�λȤ���</h3>
	<p>blogkit�Ǥϡ������Υ����ȥ�Ǥ��ε����Υ��ƥ������ꤷ�ޤ������ƥ���̾�� [ ] �ǰϤ�ǻ��ꤷ�ޤ���</p>
	<p>�㡧</p>
	<pre>[blogkit] ���ƥ��굡ǽ��Ƴ�����ޤ���</pre>
	<p>���Τ褦�˽񤯤ȡ��ºݤ˵�����ɽ������ݤ� [blogkit] ����ʬ�����ƥ���ɽ�����̤ؤΥ�󥯤ؼ�ưŪ���Ѵ�����ޤ�����Ĥε����ˤ����ĤǤ⥫�ƥ������ꤹ�뤳�Ȥ��Ǥ��ޤ���</p>
	<p>�����ɥС��ʤɤ˥��ƥ���˴�Ϣ��������ɽ�������������ϡ�<a href="#{@update}?conf=header">�إå����եå�</a>�ǥإå���եå��˼��Τ褦��������ɲä��ޤ��礦��</p>
	<pre>&lt;div class="sidemenu"&gt;Category: &lt;/div&gt;
&lt;%=blog_category_form%&gt;
&lt;%=blog_category_entry%&gt;</pre>
	<dl>
		<dt>blog_category_form</dt>
		<dd>ɽ�����륫�ƥ��������Ǥ���ɥ��åץ�����ꥹ�Ȥ�ɽ�����ޤ���</dd>
		<dt>blog_category_entry</dt>
		<dd>���򤷤����ƥ���ε����Τ���ɽ��������ʤ��ä������Υ����ȥ������ɽ�����ޤ���</dd>
	</dl>
	<p>blog_category_cache_restore�Ȥ����᥽�åɤǡ��������Υ��ƥ���ȥ����ȥ������Ǥ���Τǡ����ξ�����Ѥ����ȼ���ɽ����ˡ������ळ�Ȥ��ǽ�Ǥ���</p>
	HTML
	r << <<-HTML
	<h3 class="subtitle">���ƥ��ꥤ�ǥå����ν����</h3>
	#{"<p>blogkit�Υ��ƥ��굡ǽ�ϥ��ƥ��ꥤ��ǥå������������ʤ��Ȼ��ѤǤ��ޤ��󡥲���OK�ܥ���򲡤��ȥ��ƥ��ꥤ��ǥå����ν������¹Ԥ��ޤ����������̤�¿������¿�����֤������뤫�⤷��ޤ���</p>" unless @conf.mobile_agent?}
	#{"<p>�������ɲä����깹���������ϡ���ưŪ�˥��ƥ�����󤬥���ǥå������ɲä���ޤ��Τǡ�������ϰ��٤Ƿ빽�Ǥ���</p>" unless @conf.mobile_agent?}
	#{"<p>����å���ǥ��쥯�ȥ�ˤ���blog_category�Ȥ����ե������ä��Ƥ��ޤä��ꡤ���ƥ���ξ��󤬤��������ʤäƤ��ޤä����ϡ����٥��ƥ��ꥤ��ǥå������������Ƥ���������</p>" unless @conf.mobile_agent?}
	<input type="hidden" name="blog_category_initialize" value="true">
	HTML
end

# vim: ts=3