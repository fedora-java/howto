m4_divert(-1)

m4_ifelse(FORMAT, `antora', `

m4_define(`section', `* xref:$1.adoc[$1]')
m4_define(`subsection', `** xref:$1.adoc[$1]')
m4_define(`include_sections', `')
m4_define(`include_asciidoc', `include::$1.adoc[]')
m4_define(`include_example', `include::example$$1[]')

', `

m4_define(`section', `include::$1.adoc[]')
m4_define(`subsection', `include::$1.adoc[]')
m4_define(`include_sections', `include::$1.adoc[]')
m4_define(`include_asciidoc', `include::$1.adoc[]')
m4_define(`include_example', `include::$1[]')

')

m4_changequote(`[[', `]]')
m4_divert(0)m4_dnl
