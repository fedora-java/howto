m4_divert(-1)

m4_define(`section', `include::$1.adoc[]')
m4_define(`subsection', `include::$1.adoc[]')
m4_define(`subsubsection', `include::$1.adoc[]')
m4_define(`include_asciidoc', `include::$1.adoc[]')
m4_define(`include_example', `include::$1[]')

m4_changequote(`[[', `]]')
m4_divert(0)m4_dnl
