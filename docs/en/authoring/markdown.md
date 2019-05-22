---
layout: default
title: Markdown syntax
pagename: authoring-markdown
lang: en
---

# Markdown Formatting Cookbook

For documentation, use standard [github markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet).
While authoring documentation, you can use the github markdown preview functionality that exists in the github web ui.

## Page headers

Every page that should be processed by the system needs to have a header on the following form:

```
---
layout: default
title: My Wonderful Page
pagename: my-wonderful-page
lang: en
---
```

### Pagenames

The slug key `pagename` is used to provide a unique name for each page. This pagename is used when processing the table of contents to find the page each entry corresponds to. Additionally, the pagename is used when generating each page's URL UID.

A page's `pagename` is only ever used internally, and does not necessarily need to make sense to an end-user.  Instead it should be descriptive to the documentation maintainer(s).

{% include warning title="Pagenames should be unique and static" content="Because the pagename is used as an identifier for the page in the table of contents, pagenames must be unique.  Additionally, since the pagename is used to generate the page's UID, changing the pagename will change the UID and in turn the URL, meaning previously distributed or bookmarked links will no longer work.  For this reason, it is not advisable to change a pagename after the page has gone live." %}

### Language Support

The `lang: en` defines what language the page has been written in and should follow [i18n language codes](https://developer.chrome.com/webstore/i18n).

## Special Syntax

Several special additions exists that can be used to help build great documentation.

### Info Box

To higlight especially important things, use an info box:

{% include info title="Super Important" content="Some things are really worth pointing out." %}

{% raw  %}
```
{% include info title="Super Important" content="Some things are really worth pointing out." %}
```
{% endraw  %}

### Warning Box

To warn the reader about things, use a warning box:

{% include warning title="Scary stuff ahead" content="Beware of the quick brown fox jumping over the lazy dog." %}

{% raw  %}
```
{% include warning title="Scary stuff ahead" content="Beware of the quick brown fox jumping over the lazy dog." %}
```
{% endraw  %}

### Enternal links

Please note that all external links will be automatically decorated:

- [google](https://www.google.com/)


