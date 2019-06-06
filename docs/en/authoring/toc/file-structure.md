---
layout: default
title: Content Structure
pagename: toc-file-structure
lang: en
---

# How to organize markdown files on disk

Markdown files should be organized by language and then by their position in the table of contents.

The top folder structure should always be the language:

```
/docs
  |- en
  |- jp
  |- ko
  |- all_langs
  \- _data
```

- All english documentation should be in the `en` folder.
- All japanese documentation should be in the `jp` folder.
- All korean documentation should be in the `ko` folder.
- If you have content that is shared across languages (such as pdfs or zips for example), create an `all_langs` folder and organize it there.
- Special TOC and landing page data is stored inside the `_data` folder.

{% include info title="Symmetry" content="The language folders and the image folder should all have the exact same folder structure. This makes translation easy." %}

Inside the language folder (e.g.  `en`), items should be organized as they are in the table of contents. Images should be stored in an `images` folder at the same level as the page they are used by.  If mulitple pages at that level use images, you may organize the images folder with subdirectories for each page.

```
/root-folder
  |- index.md
  |- shotgun.md
  |- shotgun
  |    \- event-daemon.md
  |- images
  |    |- toolkit
  |    \- shotgun
  \- toolkit.md
```


