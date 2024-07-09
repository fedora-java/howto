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

pages = $(shell find pages -type f)
examples = $(shell find examples -type f)

manpage_html = $(patsubst %,examples/manpages/%.7.html,$(1))
generated_sources = images/xmvn.svg examples/manpages.adoc $(call manpage_html,$(manpages))

.PHONY: all clean clean-all generate-sources antora antora-preview

all: index.html

clean:
	@rm -rfv cache public index.html

clean-all: clean
	@rm -rfv $(generated_sources)

generate-sources: $(generated_sources)

index.html: $(pages) $(examples) $(generated_sources)
	asciidoctor -v -a EXAMPLE='../examples/' -o $@ pages/index.adoc --failure-level=ERROR

$(call manpage_html,%):
	COLUMNS=80 man -Tutf8 7 $(*F) | ansi2html --no-header --white --contrast >$@

images/xmvn.svg: images/xmvn.dia
	dia -e $@ $<

examples/manpages.adoc: pages/manpages.adoc
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
		--mount type=bind,source=public,target='/srv',readonly \
		-p 8080:8080 docker.io/philippgille/serve \
