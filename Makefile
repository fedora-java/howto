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

modules = $(shell ls *.txt)


all: index.html

index.html: $(modules:.txt=.adoc) images/xmvn.svg $(manpages_html)
	asciidoc -b html5 -a icons -a toc2 -a toclevels=3 -a theme=flask \
	    -a version=$(VERSION) $(ASCIIDOC_ARGS) index.adoc

%.adoc: macros.m4 %.txt
	m4 -P $^ >$@

%.svg: %.dia
	dia -e $@ $<

%.7.html:
	@mkdir -p $(@D)
	COLUMNS=80 man -Tutf8 7 $(*F) | ansi2html >$@

gh-pages: index.html
	./build-gh-pages.sh

clean:
	rm -Rf *.html *.adoc images/*.svg manpages modules


antora_root = modules/ROOT
antora_pages = $(patsubst %.txt,$(antora_root)/pages/%.adoc,$(modules))
antora_manpages = $(patsubst %,$(antora_root)/pages/manpage_%.adoc,$(manpages))
antora_manpages_html = $(patsubst %,$(antora_root)/examples/manpages/%.7.html,$(manpages))
antora_examples = \
    $(antora_root)/examples/rpm_project/helloworld.spec \
    $(antora_root)/examples/java_project/src/org/fedoraproject/helloworld/HelloWorld.java \
    $(antora_root)/examples/maven_project/simplemaven.spec \

$(antora_root)/pages/%.adoc: macros.m4 %.txt
	@mkdir -p $(@D)
	m4 -g -P -DFORMAT=antora $^ >$@

$(antora_root)/pages/manpage_%.adoc: macros.m4 manpage.m4
	@mkdir -p $(@D)
	m4 -g -P -DFORMAT=antora -DMANPAGE=$(*F) $^ >$@

$(antora_root)/examples/%: %
	@mkdir -p $(@D)
	cp -p $< $@

antora: $(antora_pages) $(antora_manpages) $(antora_manpages_html) $(antora_examples)
	cp $(antora_root)/pages/sections.adoc $(antora_root)/nav.adoc

antora-preview: antora
	podman run --rm -it -v $(CURDIR):/antora:z antora/antora --html-url-extension-style=indexify site.yml
	@echo ------------
	@echo Preveiew should be available at http://localhost:5000
	@echo ------------
	podman run --rm -it -v $(CURDIR)/public:/usr/share/nginx/html:ro -p 5000:80 nginx
