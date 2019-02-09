---
layout: default
title: Introduction
permalink: /authoring/pereview/
---

# Authoring Developer Documentation

Once you have [integrated](./integrating) this repo into your project,
writing docs is easy. Use standard markdown to create your content and 
for each file add a special header on the following form:

```
---
layout: default
title: Authoring Documentation
permalink: /authoring/
---
```

## This repository is a sample

This repository serves as an example of how you can author your documentation.

## Formatting

The theme used to generate documentation can be found [here](https://github.com/shotgunsoftware/just-the-docs).
In addition to standard markdown, it supports several extensions. For a reference, check out the [theme documentation](https://pmarsceill.github.io/just-the-docs/). 

## Special Pages

The following special pages exist:

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

# Multiple languages

The documentation generator supports multiple languages (i18n) support via 
[polyglot](https://polyglot.untra.io). For more information, see its documentation.





### Content Authoring guidelines

#### Diagrams and figures
- Use https://www.draw.io/ to author diagrams.
- The source file should be saved next to the image.
- Open sans (https://fonts.google.com/specimen/Open+Sans) should be used for text.
- We are not translating any images, so text should be kept to a minimum.
- Exported images should be 144dpi and stored in png format.
- Graphics should be functional in style, typically using grayscales only.

#### Screenshots
- Screenshots should be 144dpi and stored in png format
- Post processing should be kept to a minimum
- If possible, screenshot an entire window rather than cropping things
    - Use CMD+SHIFT+4 on the mac for easy screenshots of windows


### Page headers

Every page needs to have a standardized header with the following required fields:

```
---
layout: default
title: My Wonderful Page
permalink: /my-wonderful-page/
---
```

**NOTE:** Make sure to add the final slash to the permalink. 

In addition, the following fields can be useful:

- `nav_order: 1` - controls the TOC order
- `has_children: true` - for all items that have children
- `external_url: https://support.shotgunsoftware.com/hc/requests/new` - for TOC entries pointing to an external url.
- `parent: My Wonderful Page` - for child pages.

For more information, see the [tk-doc-generator docs](https://developer.shotgunsoftware.com/tk-doc-generator).

### Formatting

For markdown formatting and special syntax, see the [tk-doc-generator docs](https://developer.shotgunsoftware.com/tk-doc-generator).


## Advanced topics

### Technical Details

The setup uses jekyll to convert markdown into a html theme. For more details, see the [Toolkit Documentation Generation system](https://developer.shotgunsoftware.com/tk-doc-generator).

### The landing page

The landing page is controlled by `yml` files in the `_data` folder. For more details, see the comments 
in the files.

### Configuration

The file `jekyll_config.yml` controls the documentation build and will override the master config inside
the [Toolkit Documentation Generation system](https://github.com/shotgunsoftware/tk-doc-generator).



