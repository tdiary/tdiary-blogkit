# vi: set noexpandtab tabstop=3
require 'tdiary/style/gfm'

module TDiary
	module Style
		class BloggfmSection < GfmSection
		end

		class BloggfmDiary < GfmDiary
			def style
				'BlogGfm'
			end

			def append( body, author = nil )
				in_code_block = false
				section = nil
				body.each_line do |l|
					case l
					when /^\#[^\#]/
						if in_code_block
							section << l
						else
							@sections << BloggfmSection.new(section, author) if section
							section = l
						end
					when /^```/
						in_code_block = !in_code_block
						section << l
					else
						section = '' unless section
						section << l
					end
				end
				if section
					section << "\n" unless section =~ /\n\n\z/
					@sections << BloggfmSection.new(section, author)
				end
				@last_modified = Time.now
				self
			end

			def to_html4( opt )
				r = ''
				idx = 1
				each_section do |section|
					if idx > 1 and not opt['anchor'] then
						r << %Q|<p class="readmore"><a href="#{opt['index']}<%=anchor "#{date.strftime( '%Y%m%d' )}"%>">Read more..</a></p>\n|
						break
					end
					r << section.html4( date, idx, opt )
					idx += 1
				end
				r
			end
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
