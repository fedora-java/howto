VERSION?=Unknown
all: index.html

index.html: *.txt images/xmvn.svg
	asciidoc -b html5 -a icons -a toc2 -a toclevels=3 -a theme=flask \
	    -a version=$(VERSION) $(ASCIIDOC_ARGS) index.txt

%.svg: %.dia
	dia -e $@ $<

gh-pages: index.html
	./build-gh-pages.sh

clean:
	rm -Rf *.html images/*.svg
