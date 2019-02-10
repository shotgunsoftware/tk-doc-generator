---
layout: default
title: Markdown syntax
permalink: /authoring/markdown/
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
permalink: /my-wonderful-page/
---
```

{% include info title="Permalink syntax" content="Make sure to add the final slash to the permalink." %}


## Special Syntax

Several special additions exists that can be used to help build great documentation.

### Info Box

To higlight especially important things, use an info box:

{% include info title="Super Important" content="Some things are really worth pointing out." %}

```
{% include info title="Super Important" content="Some things are really worth pointing out." %}
```

### Warning Box

To warn the reader about things, use a warning box:

{% include warning title="Scary stuff ahead" content="Beware of the quick brown fox jumping over the lazy dog." %}

```
{% include warning title="Scary stuff ahead" content="Beware of the quick brown fox jumping over the lazy dog." %}
```

### Enternal links

Please note that all external links will be automatically decorated:

- [google](https://www.google.com/)


