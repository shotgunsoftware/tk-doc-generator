---
layout: default
title: Custom Landing Page
permalink: /authoring/landing-page/
---

# Creating a custom landing page

### The landing page

The landing page is controlled by `yml` files in the `_data` folder. For more details, see the comments 
in the files.


### Landing page

If you want to add a landing page to your documentation, create the 
following three files:

- A markdown file (typically `index.md`) with its `permalink` setting set to `/`.
  This file should be using the `landing_page` layout. For an example, see
  [the tk-doc-generator landing page](https://github.com/shotgunsoftware/tk-doc-generator/blob/master/docs/index.md).

- A file `_data/landing_page.yml` to describe the content. For an example, 
  see [the tk-doc-generator landing page](https://github.com/shotgunsoftware/tk-doc-generator/blob/master/docs/_data/landing_page.yaml).

- A file `_data/landing_page_text.yml` containing the content. For an example, see 
  the landing page for [this documentation](https://github.com/shotgunsoftware/tk-doc-generator/blob/master/docs/_data/landing_page_text.yml).
