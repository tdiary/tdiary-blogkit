#
# title-link.rb: make permalink include all of title. $Revision: 1.2 $
#
# Copyright (C) 2005 TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
def title_of_day( date, title )
	if respond_to?( :blog_category ) then
		cats, stripped = title.scan( /^((?:\[[^\]]+\])+)\s*(.*)/ )[0]
		unless cats then
			cats = ''
			stripped = title
		else
			cats << ' '
		end
	else
		cats = ''
		stripped = title
	end
	r = <<-HTML
	<span class="title">
	#{cats}
	HTML
	if @mode == 'day' then
		r << stripped
	else
		r << %Q[<a href="#{@index}#{anchor( date.strftime( '%Y%m%d' ) )}">#{stripped}</a>]
	end
	r << "</span>"
	return r.gsub( /^\t+/, '' ).chomp
end

