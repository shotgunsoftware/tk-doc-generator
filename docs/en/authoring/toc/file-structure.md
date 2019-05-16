---
layout: default
title: Content Structure
pagename: toc-file-structure
permalink: /authoring/toc/file-structure/
lang: en
---

# How to organize markdown files on disk

Markdown files should be organized by language and then by their permalink.

The top folder structure should always be the language:

```
/docs
  |- en
  |- jp
  |- ko
  |- images
  |- all_langs
  \- _data
```

- All english documentation should be in the `en` folder.
- All japanese documentation should be in the `jp` folder.
- All korean documentation should be in the `ko` folder.
- Images are shared across languanges and are stored in an `images` folder.
- If you have content that is shared across languages (such as pdfs or zips for example), create an `all_langs` folder and organize it there.
- Special TOC and landing page data is stored inside the `_data` folder.

{% include info title="Symmetry" content="The language folders and the image folder should all have the exact same folder structure. This makes translation easy." %}

Inside the `en` folder, items should be organized by permalink. 

```
/root-folder
  |- index.md               # permalink: /
  |- shotgun.md             # permalink: /shotgun/
  |- shotgun
  |    \- event-daemon.md   # permalink: /shotgun/event-daemon/
  \- toolkit.md             # permalink: /toolkit/
```


