# -*- coding: utf-8; -*-
# Copyright (c) 2003 URABE, Shyouhei <root@mput.dip.jp>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this code, to deal in the code without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the code, and
# to permit persons to whom the code is furnished to do so, subject to
# the following conditions:
#
#     The above copyright notice and this permission notice shall be
#     included in all copies or substantial portions of the code.
#
# THE CODE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE CODE
# OR THE USE OR OTHER DEALINGS IN THE CODE.

require 'tdiary/rd_style'

module RD
	class RD2BlogVisitor < RD2tDiaryVisitor
		def apply_to_Headline( element, title )
			r = "<h%1$1d>%2$s</h%1$1d>" % [ element.level + RD::TDIARY_BASE_LEVEL, title ]
			if element.level == 3 && @td_opt['multi_user'] && @td_author then
				r << "[" << @td_author << "]"
			end
			r
		end
	end
end

module TDiary
	class BlogrdDiary < RdDiary
		include RD
		def style
			'BlogRD'
		end
		def to_html( opt, mode=:HTML )
			v = RD2BlogVisitor.new( date, 0, opt, @author )
			r = ''
			@sections.each_with_index do | section, i |
				if i == 0 or opt['anchor'] then
					t = RDTree.new( ("=begin\n%s\n=end" % section.to_src).to_a, nil, nil )
					t.parse
					r << %Q[<div class="section">%s</div>] % v.visit( t )
				else
					r << %Q[<p class="readmore"><a href="%s<%%=anchor "%s"%%>">Read more ...</a></p>\n] % [opt['index'], date.strftime('%Y%m%d')]
					break;
				end
			end
			r
		end
	end
end


# Local Variables:
# mode: ruby
# code: euc-jp-unix
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vi: ts=3 sw=3
