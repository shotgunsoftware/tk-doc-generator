---
layout: default
title: Confguring Languages
permalink: /installation/languages/
---

# Configuring multiple languages

The doc generator makes it easy to enable multi-language workflows. In order to set things up, follow these steps:

## Add languages to the configuration

Add a `jekyll_config.yml` file to your repository. Add the following section to the file:

```yaml
# i18n configuration for all languages shotgun supports
languages: ["en", "ko", "ja", "zh_CN"]
lang_vars: ["English", "한국어", "日本語", "简体中文"]
default_lang: "en"
```

- Add the relevant [i18n language codes](https://developer.chrome.com/webstore/i18n) to the `languages` list.
- For each language, add a human readable name in the `lang_vars` name.
- specify a `default_lang` (normally `en`)

## Documentation structure

For documentation structure, see the [file structure](../authoring/toc/file-structure/) documentation.

## Language process

You can now author all your content in the `default_lang` (normally english). Then, as a post process, 
author the additional languages. If you english markdown page looks like this:

```
---
layout: default
title: Example title
permalink: /example/
---

# Page title

Normal markdown content follows...
```

then your swedish translation should look like this:

```
---
layout: default
title: Exempel-titel
permalink: /example/
lang: sv
---

# Sidöverskrift

Normalt markdown-innehåll följer...
```

{% include warning title="Common Fields" content="Note how the permalink needs to be the same for both pages and how we have added `lang: sv` in order to specify that this is the swedish version." %}




