# recent-entry2.rb $Revision: 1.1 $
#
# recent_entry2: modified 'recent_list' for Blogkit.
#   parameters(default):
#     max:       maximum list items (5)
#     extra_erb: do ERb to list (false)
#
#   notice:
#     This plugin dose NOT run on secure mode.
#     This plugin always show really recent entries, but need more CPU power
#     than recent-entry.rb. If you want to show the list only on latest mode,
#     you have to usr recent-entry.rb.
#
# Copyright (c) 2001,2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Modified by TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
=begin ChengeLog
2002-11-21 TADA Tadashi <sho@spc.gr.jp>
	* modified for Blogkit.
=end

eval( <<MODIFY_CLASS, TOPLEVEL_BINDING )
module TDiary
	class TDiaryMonth
		attr_reader :diaries
	end
end
MODIFY_CLASS

def recent_entry( max = 5, extra_erb = false )
	max = max.to_i

	result = "<ul>\n"
	cgi = CGI::new
	def cgi.referer; nil; end

	catch( :exit ) {
		@years.keys.sort.reverse_each do |year|
			@years[year].sort.reverse_each do |month|
				cgi.params['date'] = ["#{year}#{month}"]
				m = TDiaryMonth::new( cgi, '', @conf )
				m.diaries.keys.sort.reverse_each do |date|
					next unless m.diaries[date].visible?
					result << %Q|<li><a href="#{@index}#{anchor date}">#{m.diaries[date].title}</a></li>\n|
					max -= 1
					throw :exit if max == 0
				end
			end
		end
	}
	result << "</ul>\n"
	if extra_erb and /<%=/ =~ result
		ERbLight.new( result.untaint ).result( binding )
	else
		result
	end
end

