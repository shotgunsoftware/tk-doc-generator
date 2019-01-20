---
layout: default
title: Authoring Documentation
nav_order: 3
permalink: /authoring
---

# Authoring Developer Documentation

Once you have [integrated](./integrating) this repo into your project,
writing docs is easy. Use standard markdown to create your content and 
for each file add a special header on the following form:

```
---
layout: default
title: Authoring Documentation
nav_order: 3
permalink: /authoring
---
```

## This repository

This repository serves as an example of how you can author your documentation.

## Reference documentation

For an extensive reference how to author docs, go over to the theme
page documentation: https://pmarsceill.github.io/just-the-docs/

# Landing page

If you want to add a landing page to your documentation, create the 
following two files:

- A file `_data/landing_page.yml` to describe the content. For an example, 
  see [the tk-doc-generator landing page](https://github.com/shotgunsoftware/tk-doc-generator/blob/master/docs/_data/landing_page.yaml).
- A markdown file (typically `index.md`) with its `permalink` setting set to `/`.
  This file should be using the `landing_page` layout. For an example, see
  [the tk-doc-generator landing page](https://github.com/shotgunsoftware/tk-doc-generator/blob/master/docs/index.md).


# Multiple languages

The documentation generator supports multiple languages (i18n) support via 
[polyglot](https://polyglot.untra.io). 

TODO: Add more documentation here.



