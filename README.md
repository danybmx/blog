[![Build Status](https://travis-ci.org/danybmx/blog.svg?branch=master)](https://travis-ci.org/danybmx/blog)

# My own blog

This is the code of my blog where I'll post some random things about programming.

## Build

The blog is write using JBake so for build it, just need to run:

```
./gradlew bake
```

## Deploy

This blog use github pages for show the generated code, and generated code will be pushed to gh-pages branch from
travis-ci after a success build using the `bakeAndPublish` gradle task.
