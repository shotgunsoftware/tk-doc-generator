---
layout: default
title: Configuring Languages
pagename: installation-languages
permalink: /installation/languages/
lang: en
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

## Document disk layout 

For documentation structure, see the [file structure](../../authoring/toc/file-structure/) documentation.

