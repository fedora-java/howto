m4_divert(-1)

# This is needed in case there are more references which expand to '#' on one line
m4_changecom(`M4_COMMENT')

m4_changequote(`{{', `}}')
m4_divert(0)m4_dnl
