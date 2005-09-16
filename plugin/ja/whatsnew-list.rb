# whatsnew-list.rb Japanese resources
begin
	require 'uconv'
	@whatsnew_list_encode = 'UTF-8'
	@whatsnew_list_encoder = Proc::new {|s| Uconv.euctou8( s ) }
rescue LoadError
	@whatsnew_list_encode = @conf.encoding
	@whatsnew_list_encoder = Proc::new {|s| s }
end

if /conf/ =~ @mode then
	@whatsnew_list_label_rdf_out = 'RDF(RSS)ファイルの生成'
	@whatsnew_list_label_rdf_out_notice = '更新があるたびに、日記のトップページにindex.rdfというファイルを生成します。index.rdfにはWebサーバが書き込める権限が必要です。'
	@whatsnew_list_label_rdf_out_yes = '生成する'
	@whatsnew_list_label_rdf_out_no = '生成しない'
	@whatsnew_list_msg_access = 'に書き込めません。パーミッションを確認してください。'
end
