# title-navi.rb: navigation label with title of the article. $Revision: 1.2 $
#
# This plugin run only copy to plugin directory.
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
def navi_prev_diary( date )
	diary = @diaries[date.strftime( '%Y%m%d' )]
	if diary and diary.title.length > 0 then
		diary.title
	else
		"Prev"
	end
end

def navi_next_diary( date )
	diary = @diaries[date.strftime( '%Y%m%d' )]
	if diary and diary.title.length > 0 then
		diary.title
	else
		"Next"
	end
end

