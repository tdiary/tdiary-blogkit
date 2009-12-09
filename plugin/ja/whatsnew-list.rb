# whatsnew-list.rb Japanese resources

if /conf/ =~ @mode then
	@whatsnew_list_label_rdf_out = 'フィード(RSS)ファイルの生成'
	@whatsnew_list_label_rdf_out_notice = '更新があるたびに、日記のトップページにindex.rdfというファイルを生成します。index.rdfにはWebサーバが書き込める権限が必要です。'
	@whatsnew_list_label_rdf_out_yes = '生成する'
	@whatsnew_list_label_rdf_out_no = '生成しない'
	@whatsnew_list_msg_access = 'に書き込めません。パーミッションを確認してください。'
end

@whatsnew_list_edit_label = 'ちょっとした修正(フィードを更新しない)'

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
