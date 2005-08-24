# blog-category.rb $Revision: 1.2 $
#
#  resource file for blog-category.rb
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

@blog_category_conf_label = 'Categorize BlogKit'
@blog_category_desc_label = <<HTML
	<h3 class="subtitle">How to use</h3>
	<p>In tDiary with BlogKit, you can specify the category of the article in the title, in the form of:</p>
	<pre>[category] the title of the article</pre>
	<p>In the generated HTML, '[category]' is a link to the view of the category.  You can specify as many categories as you want.</p>
	<p>If you want to show the information of categories in the sidebar, add the followings to <a href="#{@update}?conf=header">Header/Footer</a></p>
	<pre>&lt;div class="sidemenu"&gt;Category: &lt;/div&gt;
&lt;%=blog_category_form%&gt;
&lt;%=blog_category_entry%&gt;</pre>
	<dl>
		<dt>blog_category_form</dt>
		<dd>shows a dropdown list to select a category to be shown.</dd>
		<dt>blog_category_entry</dt>
		<dd>shows the list of titles which can't be shown in the category view.</dd>
	</dl>
	<p>You can get all of categories and titles with 'blog_category_cache_restore' method, and use this information in your own plugins.</p>
	<h3 class="subtitle">Initialization of category index</h3>
	<p>The category feature of the BlogKit won't work until you initialize category index.  Push the button bellow and tDiary initialize category index for you.  It takes time if you have so many articles.</p>
	<p>When you add or update an article, category index is automatically updated, so initialization is needed once.</p>
	<p>If you remove @cache_path/blog_category accidentally or there's something wrong with category feature, try to re-initialize category index.</p>
	<input type="hidden" name="blog_category_initialize" value="true">
HTML
@blog_category_desc_label_for_mobile = <<HTML
	<H3>Initialization of category index</H3>
	<P>Push the button bellow to initialize category index.</P>
HTML

# vim: ts=3
