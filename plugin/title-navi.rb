# title-navi.rb: navigation label with title of the article. $Revision: 1.8 $
#
# This plugin run only copy to plugin directory.
# You can customize in tdiary.conf:
#   @options['title_navi.max']: max length of navigation buttons (default: 30 )
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#

if @mode == 'day'
	eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
	module TDiary
		class TDiaryMonth
			attr_reader :diaries
		end
	end
	MODIFY_CLASS

	month = @date.strftime( '%Y%m' )
	years = @years.collect{|y,ms| ms.collect{|m| "#{y}#{m}"}}.flatten.sort
	cgi = CGI::new
	def cgi.referer; nil; end

	# search pre
	pre = 0
	(@date.day - 1).downto( 1 ) do |day|
		diary = @diaries[month + ('%02d' % day)]
		pre = day if diary and diary.visible?
	end
	if pre == 0 and (years.index( month ) || 1) - 1 >= 0 then
		cgi.params['date'] = [years[(years.index( month ) || 0) - 1]]
		m = TDiaryMonth::new( cgi, '', @conf )
		@diaries.update( m.diaries )
	end

	# search nex
	nex = 0
	(@date.day + 1).upto( 31 ) do |day|
		diary = @diaries[month + ('%02d' % day)]
		nex = day if diary and diary.visible?
	end
	if nex == 0 and (years.index( month ) || years.size-1) + 1 < years.size then
		cgi.params['date'] = [years[(years.index( month ) || years.size) + 1]]
		m = TDiaryMonth::new( cgi, '', @conf )
		@diaries.update( m.diaries )
	end
end

def navi_prev_diary( date )
	diary = @diaries[date.strftime( '%Y%m%d' )]
	if diary and diary.title.length > 0 then
		len = @options['title_navi.max'] || 30
		@conf.shorten( apply_plugin( DiaryBase.method_defined?(:stripped_title) ? diary.stripped_title : diary.title, true ), len.to_i )
	else
		"Prev"
	end
end

def navi_next_diary( date )
	diary = @diaries[date.strftime( '%Y%m%d' )]
	if diary and diary.title.length > 0 then
		len = @options['title_navi.max'] || 30
		@conf.shorten( apply_plugin( DiaryBase.method_defined?(:stripped_title) ? diary.stripped_title : diary.title, true ), len.to_i )
	else
		"Next"
	end
end

