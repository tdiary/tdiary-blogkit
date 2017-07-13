# whatsnew-list.rb: what's new list plugin $Revision: 1.53 $
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
#      @options['whatsnew_list.url']
#         RDF's URL. (nil). If this options is existent (usually
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
	transaction( 'whatsnew-list' ) do |db|
		begin
			wn = JSON.load( db.get( 'whatsnew' ) ) || []
			wn.each_with_index do |item,i|
				break if i >= max
				title = @conf.shorten( apply_plugin( item[1] ).gsub( /^(\[.*?\])+\s*/, '' ).gsub( /<.*?>/, '' ), limit )
				r << %Q|<li><a href="#{h @index}#{anchor item[0]}">#{title}</a></li>\n|
			end
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
			<option value="true"#{" selected" if @conf['whatsnew_list.rdf.out']}>#{@whatsnew_list_label_rdf_out_yes}</option>
			<option value="false"#{" selected" unless @conf['whatsnew_list.rdf.out']}>#{@whatsnew_list_label_rdf_out_no}</option>
		</select></p>
	HTML
	result
end

#
# private methods
#
def whatsnew_list_rdf_file
	return @conf['whatsnew_list.rdf'] if @conf['whatsnew_list.rdf']
	if @cgi.is_a?(RackCGI)
		File.join(TDiary.server_root, 'public/index.rdf')
	else
		File.join(TDiary.server_root, 'index.rdf')
	end
end

def whatsnew_list_rdf( items )
	path = @conf.index.dup
	path[0, 0] = @conf.base_url if %r|^https?://|i !~ @conf.index
	path.gsub!( %r|/\./|, '/' )

	desc = @conf.description || @conf.html_title

	xml = %Q[<?xml version="1.0" encoding="UTF-8"?>
	<rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:xhtml="http://www.w3.org/1999/xhtml" xml:lang="#{h @conf.html_lang}">
	<channel rdf:about="#{h @conf.base_url}#{h File::basename( whatsnew_list_rdf_file )}">
	<title>#{h @conf.html_title}</title>
	<link>#{h path}</link>
	<xhtml:link xhtml:rel="alternate" xhtml:media="handheld" xhtml:type="text/html" xhtml:href="#{h path}" />
	<description>#{h desc}</description>
	<dc:creator>#{h @conf.author_name}</dc:creator>
	]

	if /^http/ =~ @conf.banner
		rdf_image = @conf.banner
	elsif @conf.banner and !@conf.banner.empty?
		rdf_image = @conf.base_url + @conf.banner
	else
		rdf_image = nil
	end
	xml << %Q[<image rdf:resource="#{h rdf_image}" />\n] if rdf_image

	xml << %Q[<items><rdf:Seq>\n]
	items.each do |uri, title, modify, description|
		xml << %Q!<rdf:li rdf:resource="#{h path}#{anchor uri}"/>\n!
	end
	xml << %Q[</rdf:Seq></items>\n]
	xml << %Q[</channel>\n]

	if rdf_image then
		xml << %Q[<image rdf:about="#{h rdf_image}">\n]
		xml << %Q[<title>#{h @conf.html_title}</title>\n]
		xml << %Q[<url>#{h rdf_image}</url>\n]
		xml << %Q[<link>#{h path}</link>\n]
		xml << %Q[</image>\n]
	end

	items.each do |uri, title, modify, description|
		if /^\d{8}$/ =~ modify then
			mod = modify.sub( /(\d{4})(\d\d)(\d\d)/, '\1-\2-\3T00:00:00+00:00' )
		else
			mod = modify
		end
		cats, stripped = title.scan( /^((?:\[[^\]]+\])+)\s*(.*)/ )[0]
		if cats then
			cats = cats.scan( /\[([^\]]+)\]+/ ).flatten.collect {|tag|
				"<dc:subject>#{h tag}</dc:subject>"
			}.join( "\n" )
		else
			stripped = h( title.gsub( /<.*?>/, '' ) )
		end
		stripped
		xml << %Q[<item rdf:about="#{h path}#{anchor uri}">
		<title>#{stripped}</title>
		<link>#{h path}#{anchor uri}</link>
		<xhtml:link xhtml:rel="alternate" xhtml:media="handheld" xhtml:type="text/html" xhtml:href="#{h path}#{anchor uri}" />
		<dc:creator>#{h @conf.author_name}</dc:creator>
		<dc:date>#{mod}</dc:date>
		#{cats}
		<content:encoded><![CDATA[#{apply_plugin( description ).gsub( /\]\]>/, ']]]]><![CDATA[>' )}]]></content:encoded>
		</item>
		]
	end

	xml << "</rdf:RDF>\n"
	to_utf8( xml.gsub( /\t/, '' ) )
end

def feed?
	@whatsnew_list_in_feed
end

def whatsnew_list_update_feed(new_items = [])
	transaction( 'whatsnew-list' ) do |db|
		wn = []
		(JSON.load(db.get('whatsnew')) || []).each_with_index do |item, i|
			wn << item unless item[0] == new_items[0]
			break if i > 15
		end

		unless (new_items.empty?)
			wn.unshift new_items
			db.set('whatsnew', wn.to_json)
		end

		rdf = whatsnew_list_rdf_file
		if @conf['whatsnew_list.rdf.out'] then
			open(rdf, 'w') do |f|
				f.write(whatsnew_list_rdf(wn))
			end
		end
	end
end

def whatsnew_list_update
	return if @mode == 'comment' and !@comment.visible?

	now = Time::now
	g = now.dup.gmtime
	l = Time::local( g.year, g.month, g.day, g.hour, g.min, g.sec )
	tz = (g.to_i - l.to_i)
	zone = sprintf( "%+03d:%02d", tz / 3600, tz % 3600 / 60 )
	diary = @diaries[@date.strftime('%Y%m%d')]

	@whatsnew_list_in_feed = true

	title = diary.title
	desc = diary.to_html( { 'anchor' => true } )
	trackback = 0
	if Comment::instance_methods.include?( 'visible_true?' ) then
		diary.each_visible_trackback {|t,i| trackback += 1}
	end
	comment = diary.count_comments - trackback
	desc << "<p>"
	desc << "Comments(#{comment})" if comment > 0
	desc << "&nbps;TrackBacks(#{trackback})" if trackback > 0
	desc << "</p>\n"
	old_apply_plugin = @conf['apply_plugin']
	@conf['apply_plugin'] = true
	title = apply_plugin( title )
	desc = body_enter_proc( @date ) + apply_plugin( desc ) + body_leave_proc( @date )
	@conf['apply_plugin'] = old_apply_plugin

	@whatsnew_list_in_feed = false

	new_items = [diary.date.strftime('%Y%m%d'), title, Time::now.strftime("%Y-%m-%dT%H:%M:%S#{zone}"), desc]
	whatsnew_list_update_feed(diary.visible? ? new_items : [])
end

add_update_proc do
	whatsnew_list_update unless @cgi.params['whatsnew_list_update'][0] == 'false'
end

add_header_proc do
	if @conf['whatsnew_list.rdf.out'] then
		url = @conf['whatsnew_list.url'] || "#{h @conf.base_url}#{h File::basename( whatsnew_list_rdf_file )}"
		%Q|\t<link rel="alternate" type="application/rss+xml" title="RSS" href="#{h url}">\n|
	else
		''
	end
end

add_edit_proc do
	checked = @cgi.params['whatsnew_list_update'][0] == 'false' ? ' checked' : ''
	r = <<-HTML
	<div class="whatsnew-list"><label for="whatsnew_list_update">
	<input type="checkbox" id="whatsnew_list_update" name="whatsnew_list_update" value="false"#{checked} tabindex="520" />
	#{@whatsnew_list_edit_label}
	</label></div>
	HTML
end

add_startup_proc do
	whatsnew_list_update_feed
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
