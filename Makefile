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

manpage_sections = $(patsubst %,manpage_%.txt,$(manpages))

modules = $(shell ls *.txt)


all: index.html

index.html: *.txt images/xmvn.svg $(manpages_html) $(manpage_sections)
	asciidoc -b html5 -a icons -a toc2 -a toclevels=3 -a theme=flask \
	    -a version=$(VERSION) $(ASCIIDOC_ARGS) index.txt

manpage_%.txt: manpages/%.7.html
	@rm -f $@
	@echo '=== $(*F)' >> $@
	@echo '{_} +' >> $@
	@echo '++++++++++++++++++++++++++' >> $@
	@echo 'include::manpages/mvn_alias.7.html[]' >> $@
	@echo '++++++++++++++++++++++++++' >> $@

%.svg: %.dia
	dia -e $@ $<

%.7.html:
	@mkdir -p $(@D)
	COLUMNS=80 man -Tutf8 7 $(*F) | ansi2html >$@

gh-pages: index.html
	./build-gh-pages.sh

clean:
	rm -Rf *.html images/*.svg manpages modules $(manpage_sections)


antora_root = modules/ROOT
antora_pages = $(patsubst %.txt,$(antora_root)/pages/%.txt,$(modules))
antora_manpages = $(patsubst %,$(antora_root)/pages/manpage_%.txt,$(manpages))
antora_manpages_html = $(patsubst %,$(antora_root)/examples/manpages/%.7.html,$(manpages))
antora_examples = \
    $(antora_root)/examples/rpm_project/helloworld.spec \
    $(antora_root)/examples/java_project/src/org/fedoraproject/helloworld/HelloWorld.java \
    $(antora_root)/examples/maven_project/simplemaven.spec \

$(antora_root)/pages/%.txt: %.txt
	@mkdir -p $(@D)
	cp $^ $@

$(antora_root)/examples/%: %
	@mkdir -p $(@D)
	cp -p $< $@

$(antora_root)/nav.adoc: $(antora_root)/pages/sections.txt
	cp -p $^ $@

antora: $(antora_pages) $(antora_manpages) $(antora_manpages_html) $(antora_examples) $(antora_root)/nav.adoc

antora-preview: antora
	podman run --rm -it -v $(CURDIR):/antora:z antora/antora --html-url-extension-style=indexify site.yml
	@echo ------------
	@echo Preveiew should be available at http://localhost:5000
	@echo ------------
	podman run --rm -it -v $(CURDIR)/public:/usr/share/nginx/html:ro -p 5000:80 nginx
