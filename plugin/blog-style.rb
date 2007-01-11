# blog-style.rb: customize to blog like labels. $Revision: 1.11 $
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
# THIS PLUGIN IS ALMOST MADE BY LANGUAGE RESOURCE. SEE ja OR en DIRECTORY.
#

#
# title
#
alias title_tag_ title_tag
def title_tag
	case @mode
	when 'day'
		diary = @diaries[@date.strftime('%Y%m%d')]
		if diary
			title = %Q|#{DiaryBase.method_defined?(:stripped_title) ? diary.stripped_title : diary.title}|
			return "<title>#{h @html_title} - #{h title}</title>"
		else
			return title_tag_
		end
	when 'month'
		list = @years.keys.collect {|y| @years[y].collect {|m| "#{y}#{m}"}}.flatten.push( nil ).unshift( nil )
		index = list.index( @date.strftime("%Y%m") )
		return "<title>#{h @html_title} - #{'%05d' % index}</title>"
	else
		return title_tag_
	end
end

#
# without anchor in subtitle
#
def subtitle_link( date, index, subtitle )
	r = ''

	if @conf.mobile_agent? then
		r << subtitle if subtitle
	else
		if subtitle
			if respond_to?( :category_anchor ) then
				r << subtitle.sub( /^(\[([^\[]+?)\])+/ ) do
					$&.gsub( /\[(.*?)\]/ ) do
						$1.split( /,/ ).collect do |c|
							category_anchor( "#{c}" )
						end.join
					end
				end
			else
				r << subtitle
			end
		end
	end
	r
end

#
# disable section specify in sending TrackBack
#
@conf['tb.no_section'] = true

