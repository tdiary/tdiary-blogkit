# edit.rb $Revision: 1.2 $
#
# navi_admin: replace 'Update' to 'Edit' on day mode.
#   notice:
#      You can modify 'Edit' label by to define navi_edit plugin.
#
def navi_admin
	if @mode == 'day' then
		result = %Q[<span class="adminmenu"><a href="#{@update}?edit=true;year=#{@date.year};month=#{@date.month};day=#{@date.day}">#{navi_edit}</a></span>\n]
	else
		result = %Q[<span class="adminmenu"><a href="#{@update}">#{navi_update}</a></span>\n]
	end
	result << %Q[<span class="adminmenu"><a href="#{@update}?conf=OK">#{navi_preference}</a></span>\n] if /^(latest|month|day|comment)$/ !~ @mode
	result
end
