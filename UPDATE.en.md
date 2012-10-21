# How to update from Blogkit 1.5.2 or before.

New blogkit support 'style'. If you have sites using old Blogkit, you have to change below:

1. Remove blogio.rb in $INSTALL/tdiary. And copy new file blog_style.rb to same directory.
2. Open tdiary.conf by textaeditor, and remove "require 'tdiary/blogio'" and add "@style = 'Blog'".

And convert data files:

3. Find *.td2 files in your @data_path.
4. Open these files by text editor, and replace all of "Format: tDiary" to "Format: Blog".
5. Save all changes, and remove @data_path/cache/*.parser and @data_path/cache/*.rb.

If you cannot do above, one more method in compatible.

3. Open blog_style.rb in text file, and find a line below.

      # TDiary::DefaultIO::add_style( 'tDiary', self )

4. Change this line to below (remove '#').

      TDiary::DefaultIO::add_style( 'tDiary', self )

5. Save the file, and remove *.parser and *.rb in @data_path/cache.
