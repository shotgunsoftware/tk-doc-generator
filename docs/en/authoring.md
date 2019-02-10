---
layout: default
title: Introduction
permalink: /authoring/
---

# Authoring Developer Documentation

Once you have [integrated](./integrating) the doc-generator with your project,
writing docs is easy. Simply use standard markdown to create your content. You 
can use github's built-in markdown tools to preview the content and in addition,
you have an automatic preview running for each commit inside pull requests.

For each markdown file you want to appear in the documentation, add the following
header:

```
---
layout: default
title: Example title
permalink: /example/
---

# Page title
Normal markdown content follows...
```

That's it - now this page will appear under the url `/example/` on your site and will 
be formatted as well as including in the search.

## Multiple languages

The documentation generator supports multiple languages (i18n) support via 
[polyglot](https://polyglot.untra.io). 




