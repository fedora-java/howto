#!/bin/bash
set -e
build_doc_version() {
    local ref="$1"
    local ver="${2:-$ref}"
    git clone -b "$ref" .. "$ver"
    if [ "$ver" != latest ]; then cp latest/versions.txt "$ver/"; fi
    pushd "$ver"
    VERSION="$ver" make
    mkdir -p "../gh-pages/$ver/images"
    cp index.html "../gh-pages/$ver/index.html"
    cp images/xmvn.svg "../gh-pages/$ver/images/"
    popd
}

rm -rf doc_build
mkdir doc_build
cd doc_build
git clone -b gh-pages .. gh-pages
build_doc_version master latest
for version in $(git for-each-ref 'refs/heads/[0-9]*' --format '%(refname:strip=2)'); do
    build_doc_version "$version"
done
cd gh-pages
git add -A
git commit -m 'Rebuild documentation'
git push ../.. gh-pages:gh-pages
cd ../..
#git push origin gh-pages:gh-pages
