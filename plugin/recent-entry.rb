# recent_entry.rb $Revision: 1.10 $
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

def recent_entry( max = 5, limit = 20 )
	result = "<ul>\n"
	if @conf.secure then
		result << recent_entry_secure( max, limit )
	else
		result << recent_entry_insecure( max, limit )
	end
	result << "</ul>\n"
	apply_plugin( result )
end


#---- private ----#
def recent_entry_secure( max = 5, limit = 20 )
	max = max.to_i
	limit = limit.to_i

	result = ''
	@diaries.keys.sort.reverse.each_with_index do |date, idx|
		break if idx >= max
		diary = @diaries[date]
		next unless diary.visible?
		title = diary.title.gsub( /<[^>]*>/, '' )
		result << %Q[<li><a href="#{@index}#{anchor date}">#{@conf.shorten( title, limit )}</a></li>\n]
	end
	result
end

eval( <<MODIFY_CLASS, TOPLEVEL_BINDING )
module TDiary
	class TDiaryMonth
		attr_reader :diaries
	end
end
MODIFY_CLASS

def recent_entry_insecure( max = 5, limit = 20 )
	max = max.to_i
	limit = limit.to_i

	cgi = CGI::new
	def cgi.referer; nil; end

	result = ''
	catch( :exit ) {
		@years.keys.sort.reverse_each do |year|
			@years[year].sort.reverse_each do |month|
				cgi.params['date'] = ["#{year}#{month}"]
				m = TDiaryMonth::new( cgi, '', @conf )
				m.diaries.keys.sort.reverse_each do |date|
					next unless m.diaries[date].visible?
					title = m.diaries[date].title.gsub( /<[^>]*>/, '' )
					result << %Q|<li><a href="#{@index}#{anchor date}">#{@conf.shorten( title, limit )}</a></li>\n|
					max -= 1
					throw :exit if max == 0
				end
			end
		end
	}
	result
end

