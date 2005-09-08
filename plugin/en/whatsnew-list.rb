# whatsnew-list.rb English resources
@whatsnew_list_encode = 'UTF-8'
@whatsnew_list_encoder = Proc::new {|s| s }

if /conf/ =~ @mode then
	@whatsnew_list_label_rdf_out = 'Generate RDF(RSS) file'
	@whatsnew_list_label_rdf_out_notice = 'Generate RDF into index.rdf when updating your diary. index.rdf have to be writable via web server process.'
	@whatsnew_list_label_rdf_out_yes = 'ON'
	@whatsnew_list_label_rdf_out_no = 'OFF'
end
