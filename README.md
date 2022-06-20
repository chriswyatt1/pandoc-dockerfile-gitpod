# Convert ASCII to markdown

Took instructions from https://gist.github.com/cheungnj/38becf045654119f96c87db829f1be8e

# Code to convert

asciidoc -b docbook rnaseq.adoc

pandoc -f docbook -t gfm rnaseq.xml -o rnaseq.md






# Other test commands

not working:  Unicode symbols were mangled in foo.md. Quick workaround:

iconv -t utf-8 rnaseq.xml | pandoc -f docbook -t gfm | iconv -f utf-8 > rnaseq.md

Not working: Pandoc inserted hard line breaks at 72 characters. Removed like so:

$ pandoc -f docbook -t gfm --wrap=none # don't wrap lines at all

$ pandoc -f docbook -t gfm --columns=120 # extend line breaks to 120