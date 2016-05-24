require 'tdiary/extensions/blogkit'

module TDiary
	class Blogkit
		def self.root
			File.expand_path('../../..', __FILE__)
		end
	end
end
