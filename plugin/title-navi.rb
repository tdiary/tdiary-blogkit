# title-navi.rb: navigation label with title of the article. $Revision: 1.3 $
#
# This plugin run only copy to plugin directory.
# You can customize in tdiary.conf:
#   @options['title_navi.max']: max length of navigation buttons (default: 30 )
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
def navi_prev_diary( date )
	diary = @diaries[date.strftime( '%Y%m%d' )]
	if diary and diary.title.length > 0 then
		len = @options['title_navi.max'] || 30
		diary.title.shorten( len.to_i )
	else
		"Prev"
	end
end

def navi_next_diary( date )
	diary = @diaries[date.strftime( '%Y%m%d' )]
	if diary and diary.title.length > 0 then
		len = @options['title_navi.max'] || 30
		diary.title.shorten( len.to_i )
	else
		"Next"
	end
end

