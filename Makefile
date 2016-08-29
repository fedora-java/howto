VERSION?=Unknown
all: index.html

index.html: *.txt images/xmvn.svg
	asciidoc -b html5 -a icons -a toc2 -a toclevels=3 -a theme=flask \
	    -a version=$(VERSION) index.txt

%.svg: %.dia
	dia -e $@ $<

gh-pages: index.html
	./upload-gh-pages.sh

clean:
	rm -Rf *.html images/*.svg
