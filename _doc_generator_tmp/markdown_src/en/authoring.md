---
layout: default
title: Introduction
pagename: authoring
lang: en
---

# Authoring Developer Documentation

Once you have [integrated](./installation/integrating.md) the doc-generator with your project,
writing docs is easy. Simply use standard markdown to create your content. You 
can use github's built-in markdown tools to preview the content and in addition,
you have an automatic preview running for each commit inside pull requests.

For each markdown file you want to appear in the documentation, add the following
header:

```
---
layout: default
title: Example title
pagename: example
lang: en
---

# Page title
Normal markdown content follows...
```

That's it - now this page can be added to your site's table of contents, and will 
be formatted as well as including in the search.

## Multiple languages

The documentation generator supports multiple languages (i18n) support via 
[polyglot](https://polyglot.untra.io). 

### Language process

You can now author all your content in the default language, specified by the `default_lang` setting in the configuration (normally english). Then, as a post process, author the additional languages. If your english markdown page looks like this:

```
---
layout: default
title: Example title
pagename: example
lang: en
---

# Page title

Normal markdown content follows...
```

then your Swedish translation should look like this:

```
---
layout: default
title: Exempel-titel
pagename: example
lang: sv
---

# Sidöverskrift

Normalt markdown-innehåll följer...
```

{% include info title="Common Fields" content="Note how the pagename needs to be the same for both pages and how we have added lang: sv in order to specify that this is the swedish version." %}

If a language is missing a page, it will use the `default_lang` version of that page.

All content is separated out into separate language areas, to make it easy to handle translation.





