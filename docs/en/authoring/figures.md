---
layout: default
title: Figures and Diagrams
permalink: /authoring/figures/
lang: en
---

# Handling figures, screenshots and diagrams

When including images, figures, screenshots and diagrams, follow these guidelines:

## Screenshots
- Screenshots should be 144dpi and stored in png format
- Post processing should be kept to a minimum
- We are not translating any graphics, so text should be kept to a minimum.
- If possible, screenshot an entire window rather than cropping the image
    - Use CMD+SHIFT+4 on the mac for easy screenshots of windows
 
## Diagrams and figures
- Use [draw.io](https://www.draw.io/) to author diagrams.
- The source file should be saved next to the image in github.
- [Open sans](https://fonts.google.com/specimen/Open+Sans) or similar should be used for text.
- We are not translating any images, so text should be kept to a minimum.
- Exported images should be 144dpi and stored in png format.
- Graphics should be functional in style, typically using grayscales only.

## Captioning Figures
Use the `figure` include when extended formatting or captioning of an image is necessary:

{% include figure src="../../images/landing-page/dev_icon.png" caption="An example figure." width="100px" %}

{% raw  %}
```
{% include figure src="../../images/landing-page/dev_icon.png" caption="An example figure." width="100px" %}
```
{% endraw  %}

Supported variables include:
  - `src`: The path to the image
  - `caption`: An optional image caption.
  - `width`: An optional width that will be appended to the `<img>` element's `style`.
  - `height`: An optional height that will be appended to the `<img>` element's `style`.
  - `style`: An optional value for the `<img>` element's `style`.
  - `dropshadow`: An optional boolean that disable's the `<img>` element's `box-shadow`.  Default behavior is `true`.
