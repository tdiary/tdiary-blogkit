# blog-style.rb: English recource of BlogKit. $Revision: 1.2 $
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
def no_diary
	"Article ##{@date.strftime( '%Y%m%d' )} does not exist."
end

def comment_today
	'Comments'
end

def comment_total( total )
	"(#{total})"
end

def comment_new
	'Post a comment'
end

def comment_description_default
	'Post a comment please. Your Email address will not show in this page.'
end

def comment_description_short
	'Post a comment'
end

def comment_name_label
	'Name'
end

def comment_name_label_short
	'Name'
end

def comment_mail_label
	'Email Address'
end

def comment_mail_label_short
	'Email'
end

def comment_body_label
	'Comments'
end

def comment_body_label_short
	'Comments'
end

def comment_submit_label
	'Post'
end

def comment_submit_label_short
	'Post'
end

def comment_date( time )
	format = @options['blog.date_format'] || 'on %B %d, %Y %H:%M'
	time.strftime( format )
end

def referer_today
	"Today's Link"
end

def navi_index
	'Index'
end

def navi_latest
	'Main'
end

def navi_update
	"Update"
end

def navi_edit
	"Edit"
end

def navi_preference
	"Preference"
end

def navi_prev_ndays
	"Prev #{@conf.latest_limit} entries"
end

def navi_next_ndays
	"Next #{@conf.latest_limit} entries"
end

def label_hidden_diary
	'This article is now HIDDEN.'
end

def mobile_label_hidden_diary
	'This article is now HIDDEN.'
end

