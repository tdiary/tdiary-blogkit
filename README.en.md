# tDiary BlogKit: How to run tDiary like blog. --

## What's BlogKit?

tDiary BlogKit modifies tDiary. This modification enables tDiary to manage articles by topics, not daily. tDiary with BlogKit is different from original one:

 * Date has no meaning. It looks like 'serial number'.
 * Each topic have last-modified.
 * Top page has the 1st section of each topic(like summary).
 * tDiary with BlogKit makes new topic number automatically when update.
 * BlogKit adds new features: 'Recent Entries' and 'What's New'.

You can setup BlogKit without changing tDiary. It is only plugged-in.

## how to install

First, you need tDiary that is installed. You must use tDiary version 2.1.3 or later. Here, it is assumed that you install tDiary under $INSTALL anew. 

### Creating tdiary.conf

Copy tdiary.conf.sample in BlogKit to $INSTALL/tdiary.conf. And, rewrite @data\_path in the tdiary.conf to your data saving directory. Read README of tDiary about @data_path. 

### Copy blog_style.rb

#### To use tDiary style

Copy tdiary/blog_style.rb of BlogKit under $INSTALL/tdiary. You have to confirm there is "@style= 'Blog'" in your tdiary.conf.

#### To use Wiki style

If you want to write by Wiki style, install Wiki style of tDiary original and copy tdiary/blogwiki_style.rb into $INSTALL/tdiary. And specify "@style = 'BlogWiki'" in your tdiary.conf.

#### To use RD style

Also if you want to write by RD style, install RD style of tDiary original and copy tdiary/blogrd_style.rb into $INSTALL/tdiary. And specify "@style = 'BlogRD'" in your tdiary.conf.

### Copy theme

A sample theme for BlogKit available in tdiary-theme package named by "blog'. This is one kind of tDiary themes, but it has some settings to enable sidebar etc.

### Copy Plugins

After tDiary 2.0.1, you can select plugin in preference page. Add the path of BlogKit plugins into tdiary.conf:

    @options['sp.path'] = ['misc/plugin', 'blogkit/plugin']

This option can have some pathes of plugins, 1st path is tDiary plugin collection. 2nd path is BlogKit's. Modify path name with your environment.

### and run tDiary as CGI

When you want to add a new topic, click 'Update' link at the bottom of the page. If you want to edit existing page, open the topic and click 'Edit' link at the bottom of the page.

## About Plugins

See each plugin file if you want more information.

### archive.rb

#### archive plugin

Shows all the topics in group sorted by topic number. By default, this plugin shows the topics in the sidebar.

#### archive\_dropdown plugin

Like archive plugin, this plugin shows all the topics in group. The topics are shown in dropdown list.

### blog-style.rb

Changes 'Diary like' labels to 'Blog like' and adjust title style. You should enable this plugin for using BlogKit.

### lm.rb

Shows last-modified in each topic. You can choose position of the last-modified, under topic title or bottom of article. You can use this plugin only by copying this plugin to plugin directory.

### recent-entry.rb

Shows the list of the recent topics. You have to choose this plugin or recent-entry2.

### title-navi.rb

Shows a topic title as navigation label. You can use this plugin only by copying this plugin to plugin directory.

### whatsnew-list.rb

Shows a list of updated topics like "What's new". This plugin cannot be used on secure mode. And it can generate RDF file when option setting in tdiary.conf.

### blog-category.rb

Add category feature.  A word surrounded by '[' and ']' is treated as a name of category.  By clicking this category name, you can move to the page which displays articles of the category. You should initialize the index of category in the config page of tDiary.

#### blog\_category\_entry plugin

Show the list of titles which can't be shown in the category specific page.

#### blog\_category\_form plugin

Shows all categories in dropdown list.  You can select a category to be shown.

### title-link.rb

Make whole title to link to Permalink.

## License

Copyright (C) by TADA Tadashi <sho@spc.gr.jp>.

You can distribute or modify this under GPL.
