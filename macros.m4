m4_divert(-1)

# This is needed in case there are more references which expand to '#' on one line
m4_changecom(`M4_COMMENT')

m4_ifelse(FORMAT, `antora', `

m4_define(`SECTION', `* xref:$1.adoc[$2]')
m4_define(`SUBSECTION', `** xref:$1.adoc[$2]')
m4_define(`REFERENCE', `xref:$1.adoc#$2[$3]')

', `

m4_define(`SECTION', `
include::$1.adoc[]')
m4_define(`SUBSECTION', `
include::$1.adoc[]')
m4_define(`REFERENCE', `<<$2, $3>>')

')

m4_changequote(`{{', `}}')
m4_divert(0)m4_dnl
