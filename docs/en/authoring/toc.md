---
layout: default
title: Table of contents
permalink: /authoring/toc/
---

# Managing a table of contents

To crate a the table of contents, you need to add two files:

- A `docs/_data/toc.yml` table of contents structure file.
- A `docs/_data/en/toc_text.yml` file containing localized strings.

## The toc file

The `docs/_data/toc.yml` defines the structure of the table of contents.

For example, it may look like this:

```yaml
- caption: authoring
  children:
  - page: /authoring/
  - page: /authoring/markdown/
    children:
    - text: markdown-cheatsheet
      url: https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet
  - page: /authoring/figures/
  - page: /authoring/toc/
    children:
    - page: /authoring/toc/file-structure/
  - page: /authoring/landing-page/
  - page: /authoring/preview/

- caption: setting-up
  children:
  - page: /installation/integrating/
  - page: /installation/languages/

- caption: developing
  children:
  - page: /developing/tech-details/
```

- The `caption` nodes will be displayed as blue, nonclickable headings in the TOC.
- Each `caption` node has a list of children in a `children` key.
- Items in this `children` list can either be other documentation pages or extenrnal links.
- Documentation pages are referenced by their permalink, e.g. `page: /authoring/markdown/`
- External links have a `text` and a `url` key to define where they point.

## Translation

Both `caption` and `text` elements are strings that potentially need to be translated into multiple languages
and are therefore stored in a special file. This file should be located in `docs/_data/en/toc_text.yml`, where `en`
is a language code. This file should contain an entry for each `caption` and `text` entry in the TOC. For example,
for the TOC shown above, the following `docs/_data/en/toc_text.yml` would be needed:

```
authoring: Authoring docs
markdown-cheatsheet: Markdown Format
setting-up: Installation
developing: Developing tk-doc-generator
```