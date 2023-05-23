MAKEFLAGS += -r

manpages :=\
	mvn_alias\
	mvn_artifact\
	mvn_build\
	mvn_compat_version\
	mvn_config\
	mvn_file\
	mvn_install\
	mvn_package\
	pom_add_dep\
	pom_add_parent\
	pom_add_plugin\
	pom_change_dep\
	pom_disable_module\
	pom_remove_dep\
	pom_remove_parent\
	pom_remove_plugin\
	pom_set_parent\
	pom_xpath_disable\
	pom_xpath_inject\
	pom_xpath_remove\
	pom_xpath_replace\
	pom_xpath_set\

source_dir := modules/ROOT
pages = $(shell find $(source_dir)/pages -type f)
examples = $(shell find $(source_dir)/examples -type f)

manpage_html = $(patsubst %,$(source_dir)/examples/manpages/%.7.html,$(1))
generated_sources = $(source_dir)/examples/images/xmvn.svg $(source_dir)/examples/manpages.adoc $(call manpage_html,$(manpages))

.PHONY: all clean gh-pages antora antora-preview

all: index.html

clean:
	@rm -rfv build cache public $(generated_sources)

index.html: $(pages) $(examples) $(generated_sources)
	asciidoctor -a EXAMPLE='../examples/' -b html5 -a icons -a toc2 -a toclevels=3 -a theme=flask -o $@ $(source_dir)/pages/index.adoc --failure-level=ERROR

$(call manpage_html,%):
	COLUMNS=80 man -Tutf8 7 $(*F) | ansi2html >$@

$(source_dir)/examples/images/xmvn.svg: $(source_dir)/examples/images/xmvn.dia
	dia -e $@ $<

$(source_dir)/examples/manpages.adoc: $(source_dir)/pages/manpages.adoc
	@echo 'Generating $@'
	@cp $< $@
	@echo >> $@
	@for manpage in $(manpages); do \
		echo "=== $${manpage}" >> $@;\
		echo '++++++++++++++++++++++++++' >> $@;\
		echo "include::{EXAMPLE}manpages/$${manpage}.7.html[]" >> $@;\
		echo '++++++++++++++++++++++++++' >> $@;\
		echo >> $@;\
	done

gh-pages: index.html
	./build-gh-pages.sh

################################################################################

cache public &: modules $(shell find $(source_dir)) $(generated_sources) antora.yml site.yml
	podman run --rm --mount type=bind,source=.,target='/antora',shared\
		-it docker.io/antora/antora:latest --html-url-extension-style=indexify site.yml
	@touch cache public

antora: cache public

antora-preview: antora
	@echo ------------
	@echo Preveiew should be available at http://localhost:8080
	@echo ------------
	@podman run --rm \
		--mount type=bind,source=.,target='/antora',readonly \
		--mount type=bind,source=nginx.conf,target='/etc/nginx/conf.d/default.conf',readonly \
		-p 8080:80 docker.io/library/nginx:latest \
