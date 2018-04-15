<nav class="navbar is-success">
  <div class="container">
    <div class="navbar-brand">
      <a class="navbar-item" href="${config.site_host}">
        My own&nbsp;<strong>/dev/null</strong>
      </a>
      <div class="navbar-burger burger" data-target="mainNavbar">
        <span></span>
        <span></span>
        <span></span>
      </div>
    </div>

    <div id="mainNavbar" class="navbar-menu">
      <div class="navbar-end">
        <div class="navbar-item">
          <div class="field is-grouped">
            <p class="control">
              <a class="button is-invert is-outlined is-dark" target="_blank" href="https://dpstudios.es">
                <span class="icon">
                  <i class="fas fa-heart"></i>
                </span>
                <span>
                  Portfolio
                </span>
              </a>
            </p>
          <div class="field is-grouped">
            <p class="control">
              <a class="button is-invert is-outlined is-dark" target="_blank" href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>${config.feed_file}">
                <span class="icon">
                  <i class="fas fa-rss"></i>
                </span>
                <span>
                  RSS
                </span>
              </a>
            </p>
            <p class="control">
              <a class="button is-invert is-outlined is-dark" target="_blank" href="https://twitter.com/danybmx">
                <span class="icon">
                  <i class="fab fa-twitter"></i>
                </span>
                <span>
                  Twitter
                </span>
              </a>
            </p>
            <p class="control">
              <a class="button is-invert is-outlined is-dark" target="_blank" href="https://github.com/danybmx/blog">
                <span class="icon">
                  <i class="fab fa-github"></i>
                </span>
                <span>
                  Github
                </span>
              </a>
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</nav>