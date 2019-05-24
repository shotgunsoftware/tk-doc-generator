---
layout: default
title: Custom Landing Page
pagename: authoring-landing-page
lang: en
---

# Creating a custom landing page

The documenation system supports the notion of a custom landing page. The page consists of several different files:

- A markdown file (typically `index.md`) with its `pagename` setting set to `index`.
  This file should be using the `landing_page` layout. For an example, see
  [the tk-doc-generator landing page](https://github.com/shotgunsoftware/tk-doc-generator/blob/master/docs/index.md).

- A file `_data/landing_page.yml` to describe the content. For an example, 
  see [the tk-doc-generator landing page](https://github.com/shotgunsoftware/tk-doc-generator/blob/master/docs/_data/landing_page.yml).

- A file `_data/en/landing_page_text.yml` containing the english content. For an example, see 
  the landing page for [this documentation](https://github.com/shotgunsoftware/tk-doc-generator/blob/master/docs/_data/en/landing_page_text.yml).

- Additional languages are added by adding additional yaml files following the file `_data/XXX/landing_page_text.yml`, where `XXX` represents the language.

- Images should be square and 144dpi resolution or more.