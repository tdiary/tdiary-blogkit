# whatsnew-list.rb: what's new list plugin $Revision: 1.10 $
#
# whatsnew_list: show what's new list
#   parameter (default):
#      max:   max of list items (5)
#      limit: max length of each items (20)
#
#  options in tdiary.conf (default):
#      @options['apply_plugin']:
#         if this is true, apply plugin to result. (false)
#      @options['whatsnew_list.rdf']
#         RDF file path. (nil)
#      @options['whatsnew_list.rdf.description']
#         description of the site in RDF. (@html_title)
#
#   notice:
#     This plugin dose NOT run on secure mode.
#     This plugin keep only recent 15 items.
#
# Copyright (c) 2002 by TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
require 'pstore'

def whatsnew_list( max = 5, limit = 20 )
	max = max.to_i
	limit = limit.to_i
	
	wl = "#{@cache_path}/whatsnew-list"
	begin
		if @mode == 'latest' then
			diary = @diaries[@diaries.keys.sort[0]]
			diary.last_modified = File::mtime( wl ) if diary
		end
	rescue
	end

	r = "<ul>\n"
	PStore::new( wl ).transaction do |db|
		begin
			wn = db['whatsnew']
			wn.each_with_index do |item,i|
				break if i >= max
				item[1].gsub!( /<.*?>/, '' )
				r << %Q|<li><a href="#{@index}#{anchor item[0]}">#{item[1].shorten( limit )}</a></li>\n|
			end
			db.abort
		rescue
		end
	end
	apply_plugin( r << "</ul>\n" )
end

#
# private methods
#
def whatsnew_list_rdf( items )
	port = ENV['SERVER_PORT'] == '80' ? "" : ":#{ENV['SERVER_PORT']}"
	path = "http://#{ENV['HTTP_HOST']}#{port}#{ENV['REQUEST_URI']}"
	path.sub!( /#{@conf.update}/, @conf.index )
	path.sub!( /\/\.\//, '/' )

	desc = @options['whatsnew_list.rdf.description'] || @conf.html_title

	xml = %Q[<?xml version="1.0" encoding="#{charset}"?>
	<rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xml:lang="#{@conf.lang ? @conf.lang : 'ja'}">
	<channel>
	<title>#{@conf.html_title}</title>
	<link>#{path}</link>
	<description>#{desc}</description>
	]

	xml << %Q[<items><rdf:Seq>\n]
	items.each do |uri, title, modify|
		xml << %Q!<rdf:li rdf:resource="#{path}#{anchor uri}"/>\n!
	end
	xml << %Q[</rdf:Seq></items>\n]
	xml << %Q[</channel>\n]

	items.each do |uri, title, modify|
		xml << %Q[<item rdf:about="#{path}#{anchor uri}">
		<title>#{title}</title>
		<link>#{path}#{anchor uri}</link>
		<dc:date>#{modify.sub( /(\d{4})(\d\d)(\d\d)/, '\1-\2-\3' )}</dc:date>
		</item>
		]
	end

	xml << "</rdf:RDF>\n"
	xml.gsub( /\t/, '' )
end

add_update_proc do
	diary = @diaries[@date.strftime('%Y%m%d')]
	new = [diary.date.strftime('%Y%m%d'), diary.title, Time::now.strftime('%Y%m%d')]
	PStore::new( "#{@cache_path}/whatsnew-list" ).transaction do |db|
		wn = []
		begin
			db['whatsnew'].each_with_index do |item, i|
				wn << item unless item[0] == new[0]
				break if i > 15
			end
		rescue PStore::Error
		end
		wn.unshift new if diary.visible?
		db['whatsnew'] = wn

		if @conf.options['whatsnew_list.rdf'] then
			open( @conf.options['whatsnew_list.rdf'], 'w' ) do |f|
				f.write( whatsnew_list_rdf( wn ) )
			end
		end
	end
end

