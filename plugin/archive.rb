# archive.rb $Revision: 1.7 $
#
# archive: show list of past news archive
#   parameter: none.
#
# archive_dropdown: show list of past news archive in dropdown.
#   parameter(default):
#      label: label of submit button ('Go')
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
def archive_make_list
	list = []
	@years.keys.sort.reverse_each do |year|
		@years[year.to_s].sort.reverse_each do |month|
			list << "#{year}#{month}"
		end
	end
	list
end

def archive
	result = %Q[<ul>\n]
	list = archive_make_list
	count = list.length
	list.each do |month|
		result << %Q[<li><a href="#{@index}#{anchor "#{month}"}">#{'%05d' % count}</a></li>\n]
		count -= 1
	end
	result << %Q[</ul>\n]
end

def archive_dropdown( label = 'Go' )
	result = %Q[<form method="get" action="#{@index}"><div>\n]
	result << %Q[<select name="date">\n]
	list = archive_make_list
	count = list.length
	list.each do |month|
		result << %Q[<option value="#{month}">#{'%05d' % count}</option>\n]
		count -= 1
	end
	result << %Q[</select>\n<input type="submit" value="#{label}">\n]
	result << %Q[</div></form>\n]
end

if @mode == 'month'
	alias navi_user_archive navi_user
	def navi_user
		list = archive_make_list.sort.push(nil).unshift(nil)
		this = @date.strftime("%Y%m")
		index = list.index(this)
		pre, cur, nex = list[index - 1, 3]
		r = ''

		if pre
			r << %Q[<span class="adminmenu"><a href="#{@index}#{anchor pre}">&laquo;#{'%05d' % (index - 1)}</a></span>\n]
		end
		r << navi_user_archive
		if nex
			r << %Q[<span class="adminmenu"><a href="#{@index}#{anchor nex}">#{'%05d' % (index + 1)}&raquo;</a></span>\n]
		end
		r
	end
end

