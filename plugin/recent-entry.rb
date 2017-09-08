# recent_entry.rb $Revision: 1.13 $
#
# recent_entry: modified 'title_list' for Blogkit.
#   parameter(default):
#     max:       maximum list items (5)
#     limit:     max lengh of each items (20)
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Copyright (c) 2001,2002 Junichiro KITA <kita@kitaj.no-ip.com>
# You can redistribute it and/or modify it under GPL2.
#

eval( <<MODIFY_CLASS, TOPLEVEL_BINDING )
module TDiary
	class TDiaryMonth
		attr_reader :diaries
	end
end
MODIFY_CLASS

def recent_entry( max = 5, limit = 20 )
	max = max.to_i
	limit = limit.to_i

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
					title = if m.diaries[date].respond_to?( :stripped_title ) then
						title = m.diaries[date].stripped_title.gsub( /<[^>]*>/, '' )
					else
						title = m.diaries[date].title.gsub( /<[^>]*>/, '' )
					end
					title = 'no title' if title.empty?
					result << %Q|<li><a href="#{h @index}#{anchor date}">#{@conf.shorten( title, limit )}</a></li>\n|
					max -= 1
					throw :exit if max == 0
				end
			end
		end
	}

	result << "</ul>\n"
	apply_plugin( result )
end

def recent_entry_insecure( max = 5, limit = 20 )
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
