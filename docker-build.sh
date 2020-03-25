#!/bin/bash

set -e

echo "${COMMIT_MESSAGE}"

# --setopt=tsflags=
# Reason: Reset dnf flags in order ot install documentation files including manpages
dnf -y --setopt=tsflags= install asciidoc dia git javapackages-local javapackages-tools m4 make man python3-ansi2html

git config --global user.email mkoncek@redhat.com
git config --global user.name mkoncek-jenkins

export GIT_SSH_COMMAND='/usr/bin/ssh -i /mnt/build/jenkins.private -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

git clone 'https://github.com/fedora-java/howto.git' &
git clone 'ssh://git@pagure.io/java-packaging-howto.git'

pushd howto
make antora
popd

rm -rf java-packaging-howto/modules
mv howto/modules java-packaging-howto

pushd java-packaging-howto
git add modules
git commit -m "${COMMIT_MESSAGE}" &&
git push origin
popd
