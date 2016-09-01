#!/bin/bash
set -e
build_doc_version() {
    local ref="$1"
    local ver="${2:-$ref}"
    git clone -b "$ref" .. "$ver"
    if [ "$ver" != snapshot ]; then cp snapshot/versions.txt "$ver/"; fi
    pushd "$ver"
    VERSION="$ver" ASCIIDOC_ARGS="-a multiversion" make
    rm -rf "../gh-pages/$ver"
    mkdir -p "../gh-pages/$ver"
    cp index.html "../gh-pages/$ver/index.html"
    cp -r images "../gh-pages/$ver/images"
    popd
}

rm -rf doc_build
mkdir doc_build
cd doc_build
git clone -b gh-pages .. gh-pages
build_doc_version master snapshot
versions="$(git for-each-ref 'refs/heads/[1-9]*' --format '%(refname:strip=2)' | sort)"
for version in $versions; do
    build_doc_version "$version"
    latest=$version
done
cd gh-pages
ln -sf "$latest" latest
git add -A
git commit -m 'Rebuild documentation'
git push ../.. gh-pages:gh-pages
cd ../..
echo "Upload the documentation with 'git push origin gh-pages:gh-pages'"
