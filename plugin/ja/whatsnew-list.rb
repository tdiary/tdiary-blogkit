# whatsnew-list.rb Japanese resources

begin
	require 'uconv'
	@whatsnew_list_encode = 'UTF-8'
	@whatsnew_list_encoder = Proc::new {|s| Uconv.euctou8( s ) }
rescue LoadError
	@whatsnew_list_encode = @conf.encoding
	@whatsnew_list_encoder = Proc::new {|s| s }
end
