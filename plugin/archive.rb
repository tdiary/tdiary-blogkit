# archive.rb $Revision: 1.2 $
#
# archive: 過去記事のアーカイブ一覧を表示する
#   パラメタ: なし
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
	archive_make_list.each_with_index do |month, count|
		result << %Q[<li><a href="#{@index}#{anchor "#{month}"}">#{'%05d' % (count+1)}</a></li>\n]
	end
	result << %Q[</ul>\n]
end

def archive_dropdown( label = 'Go' )
	result = %Q[<form method="get" action="#{@index}">\n]
	result << %Q[<select name="date">\n]
	archive_make_list.each_with_index do |month, count|
		result << %Q[<option value="#{month}">#{'%05d' % (count+1)}</option>\n]
	end
	result << %Q[</select>\n<input type="submit" value="#{label}">\n]
	result << %Q[</form>\n]
end
