# whatsnew-list.rb: what's new list plugin $Revision: 1.3 $
#
# whatsnew_list: show what's new list
#   parameter (default):
#      max:   max of list items (5)
#      extra_erb: do ERb to list (false)
#      limit: max length of each items (20)
#
#   notice:
#     This plugin dose NOT run on secure mode.
#     This plugin keep only recent 10 items.
#
# Copyright (c) 2002 by TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
require 'pstore'

add_update_proc do
	diary = @diaries[@date.strftime('%Y%m%d')]
	new = [diary.date.strftime('%Y%m%d'), diary.title, Time::now.strftime('%Y%m%d')]
	PStore::new( "#{@cache_path}/whatsnew-list" ).transaction do |db|
		wn = []
		begin
			db['whatsnew'].each_with_index do |item, i|
				wn << item unless item[0] == new[0]
				break if i > 10
			end
		rescue PStore::Error
		end
		wn.unshift new
		db['whatsnew'] = wn
	end
end

def whatsnew_list( max = 5, extra_erb = false, limit = 20 )
	max = max.to_i
	limit = limit.to_i

	r = "<ul>\n"
	PStore::new( "#{@cache_path}/whatsnew-list" ).transaction do |db|
		begin
			wn = db['whatsnew']
			wn.each_with_index do |item,i|
				break if i >= max
				r << %Q|<li><a href="#{@index}#{anchor item[0]}">#{item[1].shorten( limit )}</a></li>\n|
			end
			db.abort
		rescue
		end
	end
	r << "</ul>\n"
	if extra_erb and /<%=/ =~ result
		r.untaint if $SAFE < 3
		ERbLight.new( r ).result( binding )
	else
		r
	end
end

