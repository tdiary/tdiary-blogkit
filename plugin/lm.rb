# lm.rb: show last-modified before/after article body. $Revision: 1.3 $
#
# This plugin run only copy to plugin directory.
# You can customize in tdiary.conf:
#   @options['lm.bottom']: show below the article (default: false )
#   @options['lm.style']:  date format (default: 'Last Update: %Y-%m-%d %H:%M:%S')
#
# notice:
#    After a comment posting, this value will change without your
#    modify of the article. This is a specification of tDiary.
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
def lm( date, leave = false )
	bottom = @options['lm.bottom'] || false
	style = @options['lm.style'] || 'Last Update: %Y-%m-%d %H:%M:%S'
	diary = @diaries[date.strftime( '%Y%m%d' )]
	if diary and !(leave ^ bottom) then
			%Q|<div class="lm"><span class="lm">#{diary.last_modified.strftime( style )}</span></div>|
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

