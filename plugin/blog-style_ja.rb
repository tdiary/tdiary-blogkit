# blog-style_ja.rb: customize to blog like labels (Japanese). $Revision: 1.1 $
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
def no_diary
	"記事番号##{@date.strftime( '%Y%m%d' )}は存在しません。"
end

def comment_today
	'コメント'
end

def comment_total( total )
	"(#{total})"
end

def comment_new
	'コメントを投稿する'
end

def comment_description
	'コメントを投稿してください。E-mailアドレスは公開されません。'
end

def comment_description_short
	'コメントを投稿する'
end

def comment_name_label
	'名前'
end

def comment_name_label_short
	'名前'
end

def comment_mail_label
	'E-mail'
end

def comment_mail_label_short
	'E-mail'
end

def comment_body_label
	'コメント'
end

def comment_body_label_short
	'コメント'
end

def comment_submit_label
	'投稿'
end

def comment_submit_label_short
	'投稿'
end

def comment_date( time )
	format = @options['blog.date_format'] || '(%Y-%m-%d %H:%M)'
	time.strftime( format )
end

def referer_today
	"本日のリンク元"
end

def navi_index
	'トップ'
end

def navi_latest
	'メイン'
end

def navi_update
	"更新"
end

def navi_edit
	"編集"
end

def navi_preference
	"設定"
end

def label_hidden_diary
	'この記事は現在、隠されています。'
end

def mobile_label_hidden_diary
	'この記事は現在、隠されています。'
end

