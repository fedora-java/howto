VERSION?=Unknown

manpages=\
mvn_alias \
mvn_artifact \
mvn_build \
mvn_compat_version \
mvn_config \
mvn_file \
mvn_install \
mvn_package \
pom_add_dep \
pom_add_parent \
pom_add_plugin \
pom_change_dep \
pom_disable_module \
pom_remove_dep \
pom_remove_parent \
pom_remove_plugin \
pom_set_parent \
pom_xpath_disable \
pom_xpath_inject \
pom_xpath_remove \
pom_xpath_replace \
pom_xpath_set

manpages_html = $(patsubst %,manpages/%.7.html,$(manpages))

all: index.html

index.html: *.txt images/xmvn.svg $(manpages_html)
	asciidoc -b html5 -a icons -a toc2 -a toclevels=3 -a theme=flask \
	    -a version=$(VERSION) $(ASCIIDOC_ARGS) index.txt

%.svg: %.dia
	dia -e $@ $<

%.7.html:
	COLUMNS=80 man -Tutf8 7 $(*F) | ansi2html >$@

gh-pages: index.html
	./build-gh-pages.sh

clean:
	rm -Rf *.html images/*.svg $(manpages_html)
