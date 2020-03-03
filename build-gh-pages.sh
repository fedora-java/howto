#!/bin/bash
set -e

VERSIONS="27 28 29"
REMOTE="https://github.com/fedora-java/howto.git"

build_doc_version() {
    local ref="$1"
    local ver="${2:-$ref}"
    local remote;
    [ -n "$TRAVIS_BRANCH" ] && remote="$REMOTE" || remote=..
    git clone -b "$ref" "$remote" "$ver" --depth 1 --single-branch
    if [ "$ver" != snapshot ]; then cp snapshot/versions.txt "$ver/"; fi
    pushd "$ver"
    VERSION="$ver" make
    rm -rf "../gh-pages/$ver"
    mkdir -p "../gh-pages/$ver"
    cp index.html "../gh-pages/$ver/index.html"
    cp -r images "../gh-pages/$ver/images"
    popd
}

rm -rf doc_build
mkdir doc_build
cd doc_build
echo "$VERSIONS" | tr ' ' '\n' | tac | sed '
1     i - link:../snapshot/index.html[Snapshot version]
1  s#.*#- link:../latest/index.html[& - Fedora Rawhide]#
2,$s#.*#- link:../&/index.html[& - Fedora &]#
' > version-links.txt
git clone -b gh-pages "$REMOTE" gh-pages --single-branch
build_doc_version master snapshot
for version in $VERSIONS; do
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
        git config user.email "<fedora-java@users.noreply.github.com>"
        git config user.name "Travis CI"
        git commit -m 'Rebuild documentation'
        openssl aes-256-cbc -K $encrypted_1f9369ab557d_key -iv $encrypted_1f9369ab557d_iv -in ../../travis-key.enc -out travis-key -d
        chmod 600 travis-key
        ssh-agent sh -c "ssh-add travis-key && git push git@github.com:fedora-java/howto.git gh-pages:gh-pages"
    fi
fi
