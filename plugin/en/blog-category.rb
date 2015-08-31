# blog-category.rb $Revision: 1.4 $
#
#  resource file for blog-category.rb
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

@blog_category_conf_label = 'Categorize BlogKit'
@blog_category_desc_label = <<HTML
	<h3 class="subtitle">Initialization of category index</h3>
	<p>The category feature of the BlogKit won't work until you initialize category index.  Push the button bellow and tDiary initialize category index for you.  It takes time if you have so many articles.</p>
	<p>When you add or update an article, category index is automatically updated, so initialization is needed once.</p>
	<p>If you remove @cache_path/blog_category accidentally or there's something wrong with category feature, try to re-initialize category index.</p>
	<input type="hidden" name="blog_category_initialize" value="true">
HTML

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
