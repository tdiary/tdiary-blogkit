#
# blog_style.rb: tDiary blog kit's style $Revision: 1.1 $
#
# if you want to use this style, add @style into tdiary.conf below:
#
#    @style = 'Blog'
#
# Copyright (C) 2003, TADA Tadashi <sho@spc.gr.jp>
# You can distribute this under GPL.
#
require 'tdiary/tdiary_style.rb'

module TDiary
	class BlogDiary < DefaultDiary
		TDiary::DefaultIO::add_style( 'Blog', self )

		#
		# If you already use blogkit before 1.5.2, remove '#' below.
		#
		#TDiary::DefaultIO::add_style( 'tDiary', self )

		def style
			'Blog'
		end
	
		def to_html4( opt )
			section_id = 0
			r = %Q[<div class="section">\n]
			each_section do |section|
				if section_id > 0 and not opt['anchor'] then
					r << %Q|<p class="readmore"><a href="#{opt['index']}<%=anchor "#{date.strftime( '%Y%m%d' )}"%>">Read more...</a></p>\n|
					break
				end
				if section.subtitle then
					r << %Q[<h3>#{section.subtitle}</h3>\n]
				end
				if /^</ =~ section.body then
					r << %Q[#{section.body}\n]
				else
					r << %Q[<p>#{section.body.collect{|l|l.chomp.sub( /^[ ¡¡]/e, '' )}.join( "</p>\n<p>" )}</p>\n]
				end
				section_id += 1
			end
			r << %Q[</div>]
		end
	
		def to_chtml( opt )
			r = ''
			each_section do |section|
				if section.subtitle then
					r << %Q[<H3>#{section.subtitle}</H3>]
				end
				if /^</ =~ section.body then
					r << section.body
				else
					r << %Q[<P>#{section.body.collect{|l|l.chomp.sub( /^[ ¡¡]/e, '' )}.join( "</P>\n<P>" )}</P>]
				end
			end
			r
		end
	end

	class TDiaryForm
		alias eval_rhtml_blogkit eval_rhtml
		def eval_rhtml( prefix = '' )
			calendar
			year = @years.keys.sort[-1]
			if year then
				month = @years[year].sort[-1]
				if month then
					@io.transaction( Time::local( year.to_i, month.to_i ) ) do |diaries|
						recent = diaries.keys.sort[-1]
						if @date.strftime( '%Y%m%d' ) <= recent then
							@date = Time::local( *recent.scan( /(\d{4})(\d\d)(\d\d)/ )[0] ) + 24*60*60
							@diary = @io.diary_factory( @date, '', '' )
						end
						DIRTY_NONE
					end
				end
			end
			eval_rhtml_blogkit( prefix )
		end
	end
end

