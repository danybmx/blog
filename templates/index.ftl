<#include "header.ftl">
	
	<#include "menu.ftl">

	<div class="container">
		
		<h2 class="title">ls -1tr | head -5</h2>

		<#list posts as post>
			<#if (post.status == "published")>
				<div class="content">
					<a href="${post.uri}"><h3 class="title"><#escape x as x?xml>${post.title}</#escape></h3></a>
					<div class="post-date">${post.date?string("dd MMMM yyyy")}</div>
					<div class="has-text-justified">${post.body}</div>
				</div>
			</#if>
		</#list>
		
		<hr />
		
		<p>Older posts are available in the <a href="${content.rootpath}${config.archive_file}">archive</a>.</p>

	</div>

<#include "footer.ftl">