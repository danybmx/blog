<#include "header.ftl">
	
	<#include "menu.ftl">

	<div class="container">
		
		<h2 class="title">ls -1tr | head -5</h2>

		<#list posts as post>
			<div class="post">
				<#if (post.status == "published")>
					<div class="content">
						<div class="post-date">${post.date?string("dd MMMM yyyy")}</div>
						<div class="twitter-button-container">
							<a class="twitter-share-button"
							href="https://twitter.com/intent/tweet?url=${config.site_host}${content.uri}&text=Check this &#34;${content.title}&#34; post">
							Tweet</a>
						</div>
						<a href="${post.uri}"><h3 class="title"><#escape x as x?xml>${post.title}</#escape></h3></a>
						<div class="has-text-justified">${post.body}</div>
					</div>
				</#if>
			</div>
		</#list>
		
		<hr />
		
		<p>Older posts are available in the <a href="${content.rootpath}${config.archive_file}">archive</a>.</p>

	</div>

<#include "footer.ftl">