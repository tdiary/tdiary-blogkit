# recent_entry.rb $Revision: 1.2 $
#
# recent_entry: modified 'title_list' for Blogkit.
#   parameter(default):
#     max:       maximum list items (5)
#     extra_erb: do ERb to list (false)
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

def recent_entry( max = 5, extra_erb = false )
	result = "<ul>\n"
	@diaries.keys.sort.reverse.each_with_index do |date, idx|
		break if idx >= max
		diary = @diaries[date]
		next unless diary.visible?
		result << %Q[<li><a href="#{@index}#{anchor date}">#{diary.title}</a></li>\n]
	end
	result << "</ul>\n"
	if extra_erb and /<%=/ === result
		result.untaint if $SAFE < 3
		ERbLight.new( result ).result( binding )
	else
		result
	end
end

