#
# show last-modified of the article
#
def lm( date, leave = false )
	bottom = @options['lm.bottom'] || false
	style = @options['lm.style'] || 'Last Update: %Y-%m-%d %H:%M:%S'
	diary = @diaries[date.strftime( '%Y%m%d' )]
	if diary and !(leave ^ bottom) then
			%Q|<div class="lm">#{diary.last_modified.strftime( style )}</div>|
	else
		''
	end
end

add_body_enter_proc do |date|
	lm( date, false )
end

add_body_leave_proc do |date|
	lm( date, true )
end

