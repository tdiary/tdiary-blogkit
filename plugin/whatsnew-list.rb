# whatsnew-list.rb: what's new list plugin $Revision: 1.26 $
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
#      @options['whatsnew_list.rdf.image']
#         image URL of your site (not specified).
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
# preferences
#
add_conf_proc( 'whatsnew_list', "What's New List" ) do
	if @mode == 'saveconf' then
		@conf['whatsnew_list.rdf.out'] = (@cgi.params['whatsnew_list.rdf.out'][0] == 'true')
		@conf['whatsnew_list.rdf.description'] = @cgi.params['whatsnew_list.rdf.description'][0]
		@conf['whatsnew_list.rdf.description'] = nil if @conf['whatsnew_list.rdf.description'].length == 0
		@conf['whatsnew_list.rdf.image'] = @cgi.params['whatsnew_list.rdf.image'][0]
		@conf['whatsnew_list.rdf.image'] = nil if @conf['whatsnew_list.rdf.image'].length == 0
	end

	if @conf['whatsnew_list.rdf.out'] == nil then
		@conf['whatsnew_list.rdf.out'] = @conf['whatsnew_list.rdf'] ? true : false
	end

	result = ''
	result << <<-HTML
		<h3>#{@whatsnew_list_label_rdf_out}</h3>
		<p>#{@whatsnew_list_label_rdf_out_notice}</p>
		<p><select name="whatsnew_list.rdf.out">
			<option value="true"#{if @conf['whatsnew_list.rdf.out'] then " selected" end}>#{@whatsnew_list_label_rdf_out_yes}</option>
			<option value="false"#{if not @conf['whatsnew_list.rdf.out'] then " selected" end}>#{@whatsnew_list_label_rdf_out_no}</option>
		</select></p>
		<h3>#{@whatsnew_list_label_rdf_description}</h3>
		<p>#{@whatsnew_list_label_rdf_description_notice}</p>
		<p><input name='whatsnew_list.rdf.description' size="40" value="#{@conf['whatsnew_list.rdf.description']}"></p>
		<h3>#{@whatsnew_list_label_rdf_image}</h3>
		<p>#{@whatsnew_list_label_rdf_image_notice}</p>
		<p><input name='whatsnew_list.rdf.image' size="40" value="#{@conf['whatsnew_list.rdf.image']}"></p>
	HTML
	result
end

#
# private methods
#
def whatsnew_list_rdf_file
	rdf_file = @conf['whatsnew_list.rdf']
	if @conf['whatsnew_list.rdf.out'] == nil then
		@conf['whatsnew_list.rdf.out'] = rdf_file ? true : false
	end
	if @conf['whatsnew_list.rdf.out'] then
		rdf_file = 'index.rdf' unless rdf_file
	end
	rdf_file
end

def whatsnew_list_rdf( items )
	path = @conf.base_url + @conf.index
	path.sub!( /\/\.\//, '/' )

	desc = @options['whatsnew_list.rdf.description'] || @conf.html_title

	xml = %Q[<?xml version="1.0" encoding="#{@whatsnew_list_encode}"?>
	<rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xml:lang="#{@conf.html_lang}">
	<channel rdf:about="#{@conf.base_url}#{File::basename( whatsnew_list_rdf_file )}">
	<title>#{@conf.html_title}</title>
	<link>#{path}</link>
	<description>#{desc}</description>
	<dc:creator>#{CGI::escapeHTML( @conf.author_name )}</dc:creator>
	]

	rdf_image = @options['whatsnew_list.rdf.image']
	xml << %Q[<image rdf:resource="#{rdf_image}" />\n] if rdf_image

	xml << %Q[<items><rdf:Seq>\n]
	items.each do |uri, title, modify, description|
		xml << %Q!<rdf:li rdf:resource="#{path}#{anchor uri}"/>\n!
	end
	xml << %Q[</rdf:Seq></items>\n]
	xml << %Q[</channel>\n]

	if rdf_image then
		xml << %Q[<image rdf:abount="#{rdf_image}">\n]
		xml << %Q[<title>#{@conf.html_title}</title>\n]
		xml << %Q[<url>#{rdf_image}</url>\n]
		xml << %Q[<link>#{path}</link>\n]
		xml << %Q[</image>\n]
	end

	items.each do |uri, title, modify, description|
		if /^\d{8}$/ =~ modify then
			mod = modify.sub( /(\d{4})(\d\d)(\d\d)/, '\1-\2-\3T00:00:00+00:00' )
		else
			mod = modify
		end
		xml << %Q[<item rdf:about="#{path}#{anchor uri}">
		<title>#{title}</title>
		<link>#{path}#{anchor uri}</link>
		<dc:creator>#{CGI::escapeHTML( @conf.author_name )}</dc:creator>
		<dc:date>#{mod}</dc:date>
		<content:encoded><![CDATA[#{description}]]></content:encoded>
		</item>
		]
	end

	xml << "</rdf:RDF>\n"
	@whatsnew_list_encoder.call( apply_plugin( xml ).gsub( /\t/, '' ) )
end

add_update_proc do
	now = Time::now
	g = now.dup.gmtime
	l = Time::local( g.year, g.month, g.day, g.hour, g.min, g.sec )
	tz = (g.to_i - l.to_i)
	zone = sprintf( "%+03d:%02d", tz / 3600, tz % 3600 / 60 )
	diary = @diaries[@date.strftime('%Y%m%d')]
	title = defined?( diary.stripped_title ) ? diary.stripped_title : diary.title
	desc = diary.to_html( { 'anchor' => true } )
	new_item = [diary.date.strftime('%Y%m%d'), title, Time::now.strftime("%Y-%m-%dT%H:%M:%S#{zone}"), desc]
	PStore::new( "#{@cache_path}/whatsnew-list" ).transaction do |db|
		wn = []
		begin
			(db['whatsnew'] || []).each_with_index do |item, i|
				wn << item unless item[0] == new_item[0]
				break if i > 15
			end
		rescue PStore::Error
		end
		wn.unshift new_item if diary.visible?
		db['whatsnew'] = wn

		rdf = whatsnew_list_rdf_file
		if @conf['whatsnew_list.rdf.out'] then
			open( rdf, 'w' ) do |f|
				f.write( whatsnew_list_rdf( wn ) )
			end
		end
	end
end

add_header_proc {
	rdf = whatsnew_list_rdf_file
	if @conf['whatsnew_list.rdf'] then
		%Q|\t<link rel="alternate" type="application/rss+xml" title="#{@conf.html_title}" href="#{@conf.base_url}#{File::basename( rdf )}">\n|
	else
		''
	end
}
