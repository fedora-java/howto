[![Build Status](https://travis-ci.org/fedora-java/howto.svg?branch=master)](https://travis-ci.org/fedora-java/howto)


Documentation contained in this repository can be converted into HTML by simply running `make`.
It will build a single-HTML page with Asciidoctor and save it as `index.html`.

The same repository is also used to build the [Java Packaging HOWTO](https://docs.fedoraproject.org/en-US/java-packaging-howto/) section of [Fedora Docs](https://docs.fedoraproject.org/) using Antora.
This repo is referenced from https://gitlab.com/fedora/docs/docs-website/pages

To build Antora version, run `make antora`.
It will build a multi-HTML documentation under `public/` directory.
You can preview it by running an HTTP server in a container with `make antora-preview`.

The repository contains generated HTML manpages and diagrams.
To regenerate them from sources, run `make clean-all` and then `make generate-sources`.
You need to have all the relevant manpages installed, as well as `man`, `dia` and `ansi2html` from `colorized-logs` package.

Conventions
-----------

- JAR - always capital unless mentioning file name
- POM - always capital unless mentioning file name

Please put exactly one sentence on each line.
