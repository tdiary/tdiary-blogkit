# recent_entry.rb $Revision: 1.5 $
#
# recent_entry: modified 'title_list' for Blogkit.
#   parameter(default):
#     max:       maximum list items (5)
#     limit:     max lengh of each items (20)
#
#   notice:
#     This plugin CAN run on secure mode.
#     This plugin is lightweight. But when on month or day mode,
#     it will show wrong list sometimes. If you want to show recent entries
#     on month or day mode, try to use recent-entry2.rb.
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
=begin ChengeLog
2002-11-21 TADA Tadashi <sho@spc.gr.jp>
	* modified for Blogkit.
=end

def recent_entry( max = 5, limit = 20 )
	max = max.to_i
	limit = limit.to_i

	result = "<ul>\n"
	@diaries.keys.sort.reverse.each_with_index do |date, idx|
		break if idx >= max
		diary = @diaries[date]
		next unless diary.visible?
		result << %Q[<li><a href="#{@index}#{anchor date}">#{@conf.shorten( diary.title, limit )}</a></li>\n]
	end
	result << "</ul>\n"
	apply_plugin( result )
end

