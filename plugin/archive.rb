# archive.rb $Revision: 1.1.1.1 $
#
# archive: 過去記事のアーカイブ一覧を表示する
#   パラメタ: なし
#
def archive
	count = 1
	result = %Q[<ul>\n]
	@years.keys.sort.reverse_each do |year|
		@years[year.to_s].sort.reverse_each do |month|
			result << %Q[<li><a href="#{@index}#{anchor "#{year}#{month}"}">#{'%05d' % count}</a></li>\n]
			count += 1
		end
	end
	result << %Q[</ul>\n]
end
