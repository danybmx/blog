title=Hello jbake and travis
date=2018-04-15
type=post
tags=jbake,travis,ci
status=published
~~~~~~

Yesterday I published this blog on GitHub, it was so easy, just download jbake, run it, change some templates and I be able to start writing my first post...

I found out jbake when trying to apport something to the [VigoJUG](http://www.vigojug.org/). They use jbake for their website and the first time I see it, it was strange... When I need to create a simple static website I just download any PHP framework, install it, and create every page. if I need to do something dynamic, just use MySQL or SQLite. That's great but you need a hosting with PHP and also MySQL or SQLite, with jbake you can have a pseudo-dynamic website powered with markdown files in just a few steps, and the better is that you finally get a static HTML site that can be published everywhere, also in GitHub pages.

The problem here was that you need to run `./gradlew clean bake` on your computer and then do a `git commit -m "xxx"` and a `git push`. That's a little bit tedious since you need to have Java (is not a problem at all If you do it on your computer but is a good excuse haha), so I went to the [vigojug/vigojug.github.io](https://github.com/vigojug/vigojug.github.io) repository to see how they do this process and I realise that they use travis-ci to bake the site and then push to another branch.

It was interesting so I tried to do it and after some mistakes (: it was working!

#### Here are the steps that I followed:

##### 1. Create travis-ci project.

Go to [travis-ci](https://travis-ci.com) website and sign in with GitHub, then click on the plus sign that appears in the left sidebar and activates the repository that we want.

##### 2. Create a deployment key for allowing travis-ci to push on the repository.

For this just run `ssh-keygen` and follow instructions, store this files securely but not in the repository.

Whats the problem now? Well, ship this key to GitHub is risky but with travis, you can encrypt the key and configure travis for decrypting it before starting the build process.

```
# Install travis-cli
gem install travis
# Login in travis-cli
travis login
# Encrypt the rsa-key
travis encrypt-file {your-key-file} -r {github_user}/{github_repo_name}
```

This will show you something like this:
```
$ travis encrypt-file blog-travis -r danybmx/blog
encrypting blog-travis for danybmx/blog
storing result as blog-travis.enc
storing secure env variables for decryption

Please add the following to your build script (before_install stage in your .travis.yml, for instance):

    openssl aes-256-cbc -K $encrypted_xxxxxxxxxxxx_key -iv $encrypted_xxxxxxxxxxxx_iv -in blog-travis.enc -out blog-travis -d

Pro Tip: You can add it automatically by running with --add.

Make sure to add blog-travis.enc to the git repository.
Make sure not to add blog-travis to the git repository.
Commit all changes to your .travis.yml.
```

Just follow the instructions shown and that's done!

##### 3. Add the deployment key to GitHub repo.

- Go to [github](https://www.github.com) and navigate to the `Settings` of your project, then click `Deploy keys` on the sidebar.
- Click `Add deploy key` on the right and fill it with the content of the `.pub` file that was generated in the previous step.

##### 4. Setup gradle for do all the things!

I need to build the site with jbake and then push the generated code to a different branch (`gh-pages` in my case). Fortunately, gradle has plugins for everything and I can use the following plugins to get this done.

- [jbake-gradle-plugin](https://github.com/jbake-org/jbake-gradle-plugin): Add the `bake` task to generate the source from gradle.
- [grgit](https://github.com/ajoberstar/grgit): This is a library that allows gradle to use git directly.
- [gradle-git-publish](https://github.com/ajoberstar/gradle-git-publish): Provide the task `gitPublishPush` task along with others that will help us to commit and push the content of a directory to a remote branch.

    You can check how to configure all those plugins in the [github.com/danybmx/blog/blob/master/build.gradle](https://github.com/danybmx/blog/blob/master/build.gradle).

    Finally, I've created a custom task that runs the clean task, followed by the bake task and finally the gitPublishPush that will push the generated content to the gh-pages branch.

##### 5. Create the `.travis.yml` file.

In this case, the travis file is quite simple and short so I'll paste it here, but you can found it at [github.com/danybmx/blog/blob/master/.travis.yml](https://github.com/danybmx/blog/blob/master/.travis.yml)

```
language: java
jdk:
- oraclejdk8
before_install:
- openssl aes-256-cbc -K $encrypted_1ecfa12135cc_key -iv $encrypted_1ecfa12135cc_iv -in blog-travis.enc -out blog-travis -d
- export COMMIT_MESSAGE=$(git log -1 --pretty=%B)
script:
- ./gradlew bakeAndPush -Dorg.ajoberstar.grgit.auth.ssh.private=./blog-travis
```

- **language**: We need to set a language, Java, in this case, is enough.
- **jdk**: We define the JDK version (jbake shows an error with jdk9... so I keep jdk8 here).
- **before_install**:
    - We need to decode the blog-travis.enc file that is the rsa-key for push into GitHub using the command that `travis-cli` shows in step 2.
    - I also create an environment variable with the message of the last commit for use it as commitMessage on the `gitPublish` gradle plugin.
- **script**: Here we should define the commands that travis will launch for test/deploy.
    - In this case, the `./gradlew bakeAndPush` is enough and the `-Dorg.ajoberstar.grgit.auth.ssh.private=./blog-travis` is just for indicate where the rsa-key that we use as deployment-key is. [ajoberstar.org/grgit/grgit-authentication.html](http://ajoberstar.org/grgit/grgit-authentication.html)

##### 6. PUSH!

We've finished! the only thing that we need to do now is push the changes over master!

#### More things that we can improve.

Push directly over master is not a good practice... maybe use another branch like `dev` or `source` that just merge with master if travis ends successfully is a good idea, by now, I will maintain it in that way just because this is not an "important" project.

I hope this can be useful for someone, bye!!