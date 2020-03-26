#!/bin/bash

set -e

# variable ${COMMIT_MESSAGE} provided from the outside

# --setopt=tsflags=
# Reason: Reset dnf flags in order ot install documentation files including manpages
dnf -y --setopt=tsflags= install asciidoc dia git javapackages-local javapackages-tools m4 make man python3-ansi2html

git config --global user.name 'Jenkins CI'
git config --global user.email 'java-maint@redhat.com'

export GIT_SSH_COMMAND='/usr/bin/ssh -i /mnt/build/jenkins.private -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

git clone 'https://github.com/fedora-java/howto.git'
git clone 'ssh://git@pagure.io/java-packaging-howto.git'

pushd howto
make antora
popd

pushd java-packaging-howto
git rm -rf modules
mv ../howto/modules .
git add modules
git commit -m "${COMMIT_MESSAGE}"
git push origin
popd
