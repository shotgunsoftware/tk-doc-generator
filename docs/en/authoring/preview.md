---
layout: default
title: Local Preview
permalink: /authoring/pereview/
---

# Previewing your changes locally

Whenever you create a pull request, a CI preview is generated automatically for every commit.

If you want to run this preview and build process automatically, you can use Docker to execute
that same process. Simply execute the [preview_docs](https://github.com/shotgunsoftware/tk-doc-generator/blob/master/preview_docs.sh) script on your local command. This will use docker to create a container, downkload all relevant dependencies and build the documentation.

