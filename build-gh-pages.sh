#!/bin/bash
set -e
if [ -n "$TRAVIS_BRANCH" ]; then
    REMOTE="git@github.com:fedora-java/howto.git"
else
    REMOTE=..
fi
build_doc_version() {
    local ref="$1"
    local ver="${2:-$ref}"
    git clone -b "$ref" "$REMOTE" "$ver" --depth 1 --single-branch
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
git clone -b gh-pages "$REMOTE" gh-pages --single-branch
build_doc_version master snapshot
versions="$(git for-each-ref 'refs/heads/[1-9]*' --format '%(refname:strip=2)' | sort)"
for version in $versions; do
    build_doc_version "$version"
    latest=$version
done
cd gh-pages
rm -f latest
ln -s "$latest" latest
git add -A
if [ -n "$TRAVIS_BRANCH" ]; then
    if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
        # deploy from travis
        git commit -m 'Rebuild documentation' --author 'Travis CI <fedora-java@users.noreply.github.com>'
        openssl aes-256-cbc -K $encrypted_1f9369ab557d_key -iv $encrypted_1f9369ab557d_iv -in travis-key.enc -out travis-key -d
        chmod 600 travis-key
        ssh-agent sh -c "ssh-add travis-key && git push $REMOTE gh-pages:gh-pages"
    fi
else
    # probaly executed by human
    git commit -m 'Rebuild documentation'
    git push ../.. gh-pages:gh-pages
    cd ../..
    echo "Upload the documentation with 'git push origin gh-pages:gh-pages'"
fi
