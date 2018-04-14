<#include "header.ftl">
	
	<#include "menu.ftl">
	
	<div class="container">
		
		<h2 class="title">cat ${content.uri}</h2>

		<div class="content">
			<a href="${content.uri}"><h3 class="title"><#escape x as x?xml>${content.title}</#escape></h3></a>
			<div class="post-date">${content.date?string("dd MMMM yyyy")}</div>
			<div class="has-text-justified">${content.body}</div>
		</div>

		<hr />

		<p>Go back to the <a href="${content.rootpath}">index</a>.</p>
	</div>
	
<#include "footer.ftl">