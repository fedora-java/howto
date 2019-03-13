FROM fedora

RUN dnf install -y asciidoc dia m4 make man python2-ansi2html
RUN dnf install -y --setopt=tsflags= javapackages-local
