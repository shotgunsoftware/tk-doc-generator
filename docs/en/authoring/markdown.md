---
layout: default
title: Markdown syntax
pagename: authoring-markdown
permalink: /authoring/markdown/
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

The slug key `pagename` is used to provide a unique name for each page. This is used
when processing the table of contents to find the page each toc entry corresponds to. For this to work properly, pagenames must be unique.

The `lang: en` defines what language the page has been written in and should follow [i18n language codes](https://developer.chrome.com/webstore/i18n).

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


