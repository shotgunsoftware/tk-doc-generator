---
layout: default
title: Change Log/History
pagename: changelog
lang: en
---

Change Log/History
------------------

See also the [GitHub Releases page][releases]

[releases]: https://github.com/shotgunsoftware/tk-doc-generator/releases

# v1.x.x (changes from v1.0.0+wwfx.0.2.0 to v1.0.0+wwfx.0.3.0)

Functional improvements and fixes from testing
`tk-doc-generator` (locally using `preview_docs.sh` and on `travis.ci`)
with `tk-katana` on the [ci-docs](https://github.com/wwfxuk/tk-katana/pull/6)
branch/PR. See also `tk-katana`'s
[`gh-pages`](https://github.com/wwfxuk/tk-katana/tree/gh-pages)

- `Dockerfile`:
    - Moved `Gem*` from `/app` to `/usr/local/src`.
        - Keeps `/app` clean for `docker run`.
    - Added default `ENTRYPOINT` to run `build_docs.sh`.
    - Added `tk-core` as Sphinx `conf.py` requires it.
    - Optimised `yum install` packages, Ruby curl/untar.
    - Using `nproc`, replacing hard-coded jobs count.

- `preview_docs.sh`:
    - Support `-v` instead of `--mount` for `docker run` when using older
      `docker` version shipped with CentOS 7.
    - Will not re-build Docker image if `tk-doc-generator` image exists.
        - Force rebuild using `preview_docs.sh --rebuild`.

- `build_docs.sh`: Fixed configurations using absolute paths.
- `Gemfile*`: Using WWFX `just-the-docs` with
  [new external links test](https://github.com/shotgunsoftware/just-the-docs/pull/9)

# v1.x.x (v1.0.0+wwfx.0.1.0)

Added this change log as well as minor fixes:

- `.travis.yml`: Changed to WWFX UK `DOC_URL`
- `Dockerfile`: Fixed `yum clean all` from being part of the `yum install` arguments
- `build_docs.sh`: Fixed permissions of generated docs from just `root` only
- `travis-generate-docs.py`: Fallback to `DOC_*` before using dummy URL.

# v1.0.0

Initial release from Shotgun, nothing mentioned by Shotgun.