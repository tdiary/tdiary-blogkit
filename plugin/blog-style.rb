# blog-style.rb: customize to blog like labels. $Revision: 1.11 $
#
# Copyright (c) 2011 TADA Tadashi <t@tdtds.jp>
# Distributed under the GPL
#
# THIS PLUGIN IS ALMOST MADE BY LANGUAGE RESOURCE. SEE ja OR en DIRECTORY.
#

def blogkit?
	true
end
add_js_setting( '$tDiary.blogkit', "true" )

#
# title
#
alias title_tag_ title_tag
def title_tag
	case @mode
	when 'day'
		diary = @diaries[@date.strftime('%Y%m%d')]
		if diary
			title = %Q|#{Style::BaseDiary.method_defined?(:stripped_title) ? diary.stripped_title : diary.title}|
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
	r
end

#
# disable section specify in sending TrackBack
#
@conf['tb.no_section'] = true

#
# hide date fields on form
#
def blog_style_date_field
	if /^(form|edit|preview|showcomment)$/ =~ @mode then
		<<-HTML
		<style type="text/css"><!--
		form.update span.year,
		form.update span.month,
		form.update span.day,
		form.update span.edit {
			display: none;
		}
		--></style>
		HTML
	else
		''
	end
end

add_header_proc do
	blog_style_date_field
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
