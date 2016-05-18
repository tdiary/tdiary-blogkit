module TDiary
	module Extensions
		class Blogkit
			def self.sp_path
				File.join(TDiary::Blogkit.root, 'plugin')
			end

			def self.assets_path
				File.join(TDiary::Blogkit.root, 'js')
			end
		end
	end
end
