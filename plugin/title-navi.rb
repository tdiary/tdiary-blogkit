#
# title-navi.rb: navigation label with title of article.
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

