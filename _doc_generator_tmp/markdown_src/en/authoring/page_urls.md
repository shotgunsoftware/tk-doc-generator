---
layout: default
title: Page URLs
pagename: authoring-page-urls
lang: en
---

# Page URLs

Page URLs are generated automatically at build time based on each page's `pagename`.  This allows URLs to remain static and independent of content, even if the title or purpose of a particular page changes.

## Page Titles in URLs

To make URLs more human-readable, we append the page titles to the URL like so: `https://mydocumentation.mysite.com/78b64024/?title=Page+URLs`.

The value included there does not change which page is requested -- it is only used to make the URL more readable.  This means that changing a page's title will not break existing links, even if they include the old page title.  The page titles are appended in this manner to internal links and links in the table of contents automatically.

When sending a URL to someone else or bookmarking a link you can change the URL after the `?` in any way you like, or remove that portion of the URL altogether; this will not change which page the URL points to.
