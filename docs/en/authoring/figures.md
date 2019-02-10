---
layout: default
title: Figures and Diagrams
permalink: /authoring/figures/
---

# Handling figures, screenshots and diagrams





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
