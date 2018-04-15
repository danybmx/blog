<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8"/>
    <title><#if (content.title)??><#escape x as x?xml>${content.title}</#escape><#else>Daniel Rodríguez's Blog</#if></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="<#if (content.description)??><#escape x as x?xml>${content.description}</#escape><#else>Just a blog for practice english and share things about tech and programming.</#if>">
    <meta name="author" content="Daniel Rodríguez Gil (@danybmx)">
    <meta name="keywords" content="<#if (content.description)??><#escape x as x?xml>${content.description}</#escape><#else>blog, programming, website, development, java, nodejs, docker</#if>">
    <meta name="generator" content="JBake">

    <!-- Stylesheets -->
    <link href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>css/bulma.css" rel="stylesheet">
    <link href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>css/asciidoctor.css" rel="stylesheet">
    <link href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>css/base.css" rel="stylesheet">
    <link href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>css/prettify.css" rel="stylesheet">

    <!-- Font awesome -->
    <script defer src="https://use.fontawesome.com/releases/v5.0.10/js/all.js" integrity="sha384-slN8GvtUJGnv6ca26v8EzVaR9DC58QEwsIk9q1QXdCU8Yu8ck/tL/5szYlBbqmS+" crossorigin="anonymous"></script>

    <!-- Fav and touch icons -->
    <link rel="shortcut icon" href="<#if (content.rootpath)??>${content.rootpath}<#else></#if>favicon.ico">

    <!-- Analytics -->
    <script async src="https://www.googletagmanager.com/gtag/js?id=UA-117593861-1"></script>
    <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', 'UA-117593861-1');
    </script>

  </head>
  <body onload="prettyPrint()">
    <div id="wrap">