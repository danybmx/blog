<#include "header.ftl">
	
	<#include "menu.ftl">
	
	<div class="container">
		
		<h2 class="title">cat ${content.uri}</h2>

		<div class="content">
			<div class="post-date">${content.date?string("dd MMMM yyyy")}</div>
			<div class="twitter-button-container">
				<a class="twitter-share-button"
				href="https://twitter.com/intent/tweet?url=${config.site_host}${content.uri}&text=Check this &#34;${content.title}&#34; post">
				Tweet</a>
			</div>
			<a href="/${content.uri}"><h3 class="title"><#escape x as x?xml>${content.title}</#escape></h3></a>
			<div class="has-text-justified">${content.body}</div>
		</div>

		<hr />

		<p>Go back to the <a href="${content.rootpath}">index</a>.</p>
		
	</div>
	
<#include "footer.ftl">