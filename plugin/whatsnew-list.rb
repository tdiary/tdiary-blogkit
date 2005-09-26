# whatsnew-list.rb: what's new list plugin $Revision: 1.39 $
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
	return 'DO NOT USE IN SECURE MODE' if @conf.secure

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
add_conf_proc( 'whatsnew_list', "What's New List", 'update' ) do
	if @mode == 'saveconf' then
		if @cgi.params['whatsnew_list.rdf.out'][0] == 'true' then
			rdf = whatsnew_list_rdf_file
			begin
				open( rdf, 'w+' ) {|f|}
				@conf['whatsnew_list.rdf.out'] = true
			rescue Errno::EACCES
				@conf['whatsnew_list.rdf.out'] = false
				error_message = %Q|<p class="message">#{rdf}#{@whatsnew_list_msg_access}</p>|
	
			end
		else
			@conf['whatsnew_list.rdf.out'] = false
		end
	end

	if @conf['whatsnew_list.rdf.out'] == nil then
		@conf['whatsnew_list.rdf.out'] = @conf['whatsnew_list.rdf'] ? true : false
	end

	result = ''
	result << <<-HTML
		#{error_message}
		<h3>#{@whatsnew_list_label_rdf_out}</h3>
		<p>#{@whatsnew_list_label_rdf_out_notice}</p>
		<p><select name="whatsnew_list.rdf.out">
			<option value="true"#{if @conf['whatsnew_list.rdf.out'] then " selected" end}>#{@whatsnew_list_label_rdf_out_yes}</option>
			<option value="false"#{if not @conf['whatsnew_list.rdf.out'] then " selected" end}>#{@whatsnew_list_label_rdf_out_no}</option>
		</select></p>
	HTML
	result
end

#
# private methods
#
def whatsnew_list_rdf_file
	@conf['whatsnew_list.rdf'] || 'index.rdf'
end

def whatsnew_list_rdf( items )
	path = @conf.index.dup
	path[0, 0] = @conf.base_url if %r|^https?://|i !~ @conf.index
	path.gsub!( %r|/\./|, '/' )

	desc = @conf.description || @conf.html_title

	xml = %Q[<?xml version="1.0" encoding="#{@whatsnew_list_encode}"?>
	<rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xml:lang="#{@conf.html_lang}">
	<channel rdf:about="#{@conf.base_url}#{File::basename( whatsnew_list_rdf_file )}">
	<title>#{@conf.html_title}</title>
	<link>#{path}</link>
	<description>#{desc}</description>
	<dc:creator>#{CGI::escapeHTML( @conf.author_name )}</dc:creator>
	]

	if /^http/ =~ @conf.banner
		rdf_image = @conf.banner
	elsif @conf.banner and !@conf.banner.empty?
		rdf_image = @conf.base_url + @conf.banner
	else
		rdf_image = nil
	end
	xml << %Q[<image rdf:resource="#{rdf_image}" />\n] if rdf_image

	xml << %Q[<items><rdf:Seq>\n]
	items.each do |uri, title, modify, description|
		xml << %Q!<rdf:li rdf:resource="#{path}#{anchor uri}"/>\n!
	end
	xml << %Q[</rdf:Seq></items>\n]
	xml << %Q[</channel>\n]

	if rdf_image then
		xml << %Q[<image rdf:about="#{rdf_image}">\n]
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
	@whatsnew_list_encoder.call( xml.gsub( /\t/, '' ) )
end

def whatsnew_list_update
	now = Time::now
	g = now.dup.gmtime
	l = Time::local( g.year, g.month, g.day, g.hour, g.min, g.sec )
	tz = (g.to_i - l.to_i)
	zone = sprintf( "%+03d:%02d", tz / 3600, tz % 3600 / 60 )
	diary = @diaries[@date.strftime('%Y%m%d')]

	title = defined?( diary.stripped_title ) ? diary.stripped_title : diary.title
	desc = diary.to_html( { 'anchor' => true } )
	desc << "<p>Comments(#{diary.count_comments})"
	if diary.respond_to?( :each_visible_trackback ) then
		tb = 0
		diary.each_visible_trackback( 100 ) {|t,i| tb += 1}
		desc << " TrackBacks(#{tb})"
	end
	desc << "</p>\n"
	old_apply_plugin = @conf['apply_plugin']
	@conf['apply_plugin'] = true
	title = apply_plugin( title )
	body_enter_proc( @date )
	desc = apply_plugin( desc )
	@conf['apply_plugin'] = old_apply_plugin
	body_leave_proc( @date )

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

add_update_proc do
	whatsnew_list_update unless @cgi.params['whatsnew_list_update'][0] == 'false'
end

add_header_proc do
	rdf = whatsnew_list_rdf_file
	if @conf['whatsnew_list.rdf.out'] then
		%Q|\t<link rel="alternate" type="application/rss+xml" title="RSS" href="#{@conf.base_url}#{File::basename( rdf )}">\n|
	else
		''
	end
end

add_edit_proc do
	checked = @cgi.params['whatsnew_list_update'][0] == 'false' ? ' checked' : ''
	r = <<-HTML
	<div class="whatsnew-list">
	<input type="checkbox" name="whatsnew_list_update" value="false"#{checked} tabindex="520" />
	#{@whatsnew_list_edit_label}
	</div>
	HTML
end
