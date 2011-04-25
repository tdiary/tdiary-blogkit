# -*- coding: utf-8; -*-
#
# blogwiki_style.rb: WikiWiki style for tDiary Blogkit. $Revision: 1.7 $
#
# if you want to use this style,
#
#   1. copy wiki_style.rb and wiki_parser.rb in tDiary's misc/style/wiki
#      to tDiary's tdiary directory.
#
#   2. copy this blogwiki_style.rb to tDiaty's tdiary directory.
#
#   3. specify @style in tdiary.conf below:
#
#    @style = 'BlogWiki'
#
# Copyright (C) 2003, TADA Tadashi <sho@spc.gr.jp>
# You can distribute this under GPL.
#
require 'tdiary/wiki_style'

module TDiary
	class BlogwikiSection < WikiSection
	end

	class BlogwikiDiary < WikiDiary
		def style
			'BlogWiki'
		end

		def append( body, author = nil )
			section = nil
			body.each_line do |l|
				case l
				when /^\![^!]/
					@sections << BlogwikiSection::new( section, author ) if section
					section = l
				else
					section = '' unless section
					section << l
				end
			end
			@sections << BlogwikiSection::new( section, author ) if section
			@last_modified = Time::now
			self
		end

		def to_html4( opt )
			r = ''
			idx = 1
			each_section do |section|
				if idx > 1 and not opt['anchor'] then
					r << %Q|<p class="readmore"><a href="#{opt['index']}<%=anchor "#{date.strftime( '%Y%m%d' )}"%>">Read more...</a></p>\n|
					break
				end
				r << section.html4( date, idx, opt )
				idx += 1
			end
			r
		end

		def to_chtml( opt )
			r = ''
			idx = 1
			each_section do |section|
				r << section.chtml( date, idx, opt )
				idx += 1
			end
			r
		end
	end
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
