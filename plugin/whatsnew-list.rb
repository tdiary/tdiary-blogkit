#
# what's new list plugin
#
require 'pstore'

add_update_proc do
	diary = @diaries[@date.strftime('%Y%m%d')]
	new = [diary.date.strftime('%Y%m%d'), diary.title, Time::now.strftime('%Y%m%d')]
	PStore::new( "#{@cache_path}/whatsnew-list" ).transaction do |db|
		wn = []
		begin
			db['whatsnew'].each_with_index do |item, i|
				wn << item unless item[0] == new[0]
				break if i > 10
			end
		rescue PStore::Error
		end
		wn.unshift new
		db['whatsnew'] = wn
	end
end

def whatsnew_list( max = 5 )
	r = "<ul>\n"
	PStore::new( "#{@cache_path}/whatsnew-list" ).transaction do |db|
		begin
			wn = db['whatsnew']
			wn.each_with_index do |item,i|
				break if i >= max
				r << %Q|<li><a href="#{@index}#{anchor item[0]}">#{item[1]}</a></li>\n|
			end
			db.abort
		rescue
		end
	end
	r << "</ul>\n"
end

