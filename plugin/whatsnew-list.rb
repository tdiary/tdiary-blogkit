# whatsnew-list.rb: what's new list plugin $Revision: 1.17 $
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
#         RDF file path. (nil). If this options is existent (usually
#         'index.rdf'), this plugin will generate RDF file.
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

unless @resource_loaded then
	@whatsnew_list_encode = 'UTF-8'
	@whatsnew_list_encoder = Proc::new {|s| s }
end

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
				title = @conf.shorten(apply_plugin( item[1] ).gsub( /<.*?>/, '' ), limit )
				r << %Q|<li><a href="#{@index}#{anchor item[0]}">#{title}</a></li>\n|
			end
			db.abort
		rescue
		end
	end
	r << "</ul>\n"
end

#
# private methods
#
def whatsnew_list_rdf( items )
	path = @conf.base_url + @conf.index
	path.sub!( /\/\.\//, '/' )

	desc = @options['whatsnew_list.rdf.description'] || @conf.html_title

	xml = %Q[<?xml version="1.0" encoding="#{@whatsnew_list_encode}"?>
	<rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xml:lang="#{@conf.html_lang}">
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
	@whatsnew_list_encoder.call( apply_plugin( xml ).gsub( /\t/, '' ) )
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

add_header_proc {
	if @conf['whatsnew_list.rdf'] then
		%Q|\t<link rel="alternate" type="application/rss+xml" title="RSS" href="#{@conf['whatsnew_list.rdf']}">\n|
	else
		''
	end
}
