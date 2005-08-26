#
# blogwiki_style.rb: WikiWiki style for tDiary Blogkit. $Revision: 1.5 $
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
require 'tdiary/wiki_parser'
require 'tdiary/wiki_style'

module TDiary
	class BlogwikiSection < WikiSection
		attr_reader :subtitle, :author
		attr_reader :categories, :stripped_subtitle
	
		def html4( date, idx, opt )
			do_html4( @parser, date, idx, opt )
		end

		def do_html4( parser, date, idx, opt, in_stripped_subtitle = nil )
			r = ""
			stat = nil
			parser.each do |s|
				stat = s if s.class == Symbol
				case s

				# subtitle heading
				when :HS1; r << "<h3>"
				when :HE1; r << "</h3>\n"

				# other headings
				when :HS2, :HS3, :HS4, :HS5; r << "<h#{s.to_s[2,1].to_i + 2}>"
				when :HE2, :HE3, :HE4, :HE5; r << "</h#{s.to_s[2,1].to_i + 2}>\n"

				# pargraph
				when :PS; r << '<p>'
				when :PE; r << "</p>\n"

				# horizontal line
				when :RS; r << "<hr>\n"
				when :RE

				# blockquote
				when :QS; r << "<blockquote>\n"
				when :QE; r << "</blockquote>\n"

				# list
				when :US; r << "<ul>\n"
				when :UE; r << "</ul>\n"

				# ordered list
				when :OS; r << "<ol>\n"
				when :OE; r << "</ol>\n"

				# list item
				when :LS; r << "<li>"
				when :LE; r << "</li>\n"

				# definition list
				when :DS; r << "<dl>"
				when :DE; r << "</dl>\n"
				when :DTS; r << "<dt>"
				when :DTE; r << "</dt>\n"
				when :DDS; r << "<dd>"
				when :DDE; r << "</dd>\n"

				# formatted text
				when :FS; r << '<pre>'
				when :FE; r << "</pre>\n"

				# table
				when :TS; r << "<table border=\"1\">\n"
				when :TE; r << "</table>\n"
				when :TRS; r << "<tr>\n"
				when :TRE; r << "</tr>\n"
				when :TDS; r << "<td>"
				when :TDE; r << "</td>"

				# emphasis
				when :ES; r << "<em>"
				when :EE; r << "</em>"

				# strong
				when :SS; r << "<strong>"
				when :SE; r << "</strong>"

				# delete
				when :ZS; r << "<del>"
				when :ZE; r << "</del>"

				# Keyword
				when :KS; r << '<'
				when :KE; r << '>'

				# Plugin
				when :GS; r << '<%='
				when :GE; r << '%>'

				# URL
				when :XS; #r << '<a href="'
				when :XE; #r << '</a>'

				else
					s = CGI::escapeHTML( s ) unless stat == :GS
					case stat
					when :KS
						if /\|/ =~ s
							k, u = s.split( '|', 2 )
							if /^(\d{4}|\d{6}|\d{8}|\d{8}-\d+)[^\d]*?#?([pct]\d+)?$/ =~ u then
								r << "%=my '" << $1
								r << $2 if $2
								r << "', '" << k << "'%"
							else
								r << %Q[a href="#{u}">#{k}</a]
							end
						else
							r << "%=kw '" << s << "'%"
						end
					when :XS
						case s
						when /^mailto:/
							r << %Q[<a href="#{s}">#{s.sub( /^mailto:/, '' )}</a>]
						when /\.(jpg|jpeg|png|gif)$/
							r << %Q[<img src="#{s}" alt="#{File::basename( s )}">]
						else
							r << %Q[<a href="#{s}">#{s}</a>]
						end
					else
						r << s if s.class == String
					end
				end
			end
			r
		end
	
		def chtml( date, idx, opt )
			r = ''
			stat = nil
			@parser.each do |s|
				stat = s if s.class == Symbol
				case s

				# subtitle heading
				when :HS1; r << %Q[<H3>]
				when :HE1; r << "</H3>\n"

				# other headings
				when :HS2, :HS3, :HS4, :HS5; r << "<H#{s.to_s[2,1].to_i + 2}>"
				when :HE2, :HE3, :HE4, :HE5; r << "</H#{s.to_s[2,1].to_i + 2}>\n"

				# paragraph
				when :PS; r << '<P>'
				when :PE; r << "</P>\n"

				# horizontal line
				when :RS; r << "<HR>\n"
				when :RE

				# blockquote
				when :QS; r << "<BLOCKQUOTE>\n"
				when :QE; r << "</BLOCKQUOTE>\n"

				# list
				when :US; r << "<UL>\n"
				when :UE; r << "</UL>\n"

				# ordered list
				when :OS; r << "<OL>\n"
				when :OE; r << "</OL>\n"

				# list item
				when :LS; r << "<LI>"
				when :LE; r << "</LI>\n"

				# definition list
				when :DS; r << "<DL>"
				when :DE; r << "</DL>\n"
				when :DTS; r << "<DT>"
				when :DTE; r << "</DT>\n"
				when :DDS; r << "<DD>"
				when :DDE; r << "</DD>\n"

				# formatted text
				when :FS; r << '<PRE>'
				when :FE; r << "</PRE>\n"

				# table
				when :TS; r << "<TABLE BORDER=\"1\">\n"
				when :TE; r << "</TABLE>\n"
				when :TRS; r << "<TR>\n"
				when :TRE; r << "</TR>\n"
				when :TDS; r << "<TD>"
				when :TDE; r << "</TD>"

				# emphasis
				when :ES; r << "<EM>"
				when :EE; r << "</EM>"

				# strong
				when :SS; r << "<STRONG>"
				when :SE; r << "</STRONG>"

				# delete
				when :ZS; r << "<DEL>"
				when :ZE; r << "</DEL>"

				# Keyword
				when :KS; r << '<'
				when :KE; r << '>'

				# Plugin
				when :GS; r << '<%='
				when :GE; r << '%>'

				# URL
				when :XS; r << '<A HREF="'
				when :XE; r << '</A>'

				else
					s = CGI::escapeHTML( s ) unless stat == :GS
					case stat
					when :KS
						if /\|/ =~ s
							k, u = s.split( '|', 2 )
							if /^(\d{4}|\d{6}|\d{8}|\d{8}-\d+)[^\d]*?#?([pct]\d+)?$/ =~ u then
								r << "%=my '" << $1
								r << $2 if $2
								r << "', '" << k << "'%"
							else
								r << %Q[A HREF="#{u}">#{k}</A]
							end
						else
							r << "%=kw '" << s << "'%"
						end
					when :XS
						r << s << '">' << s.sub( /^mailto:/, '' )
					else
						r << s if s.class == String
					end
				end
			end
			r
		end

		def to_s
			to_src
		end
	end

	class BlogwikiDiary < WikiDiary
		def style
			'BlogWiki'
		end
	
		def append( body, author = nil )
			section = nil
			body.each do |l|
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
			r = %Q[<div class="section">\n]
			idx = 1
			each_section do |section|
				if idx > 1 and not opt['anchor'] then
					r << %Q|<p class="readmore"><a href="#{opt['index']}<%=anchor "#{date.strftime( '%Y%m%d' )}"%>">Read more...</a></p>\n|
					break
				end
				r << section.html4( date, idx, opt )
				idx += 1
			end
			r << "</div>\n"
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

