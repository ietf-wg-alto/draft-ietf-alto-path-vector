PANDOC_VERSION:=$(shell pandoc --version | head -c 8 | tail -c 1)
ifeq ($(PANDOC_VERSION), 1)
PANDOC_OPT=-st docbook+header_attributes+multiline_tables
else
PANDOC_OPT=-st docbook4+header_attributes+multiline_tables
endif

stylefile=style/transform.xsl

refxmlfiles=$(wildcard references/reference.*.xml)
genxmlfiles=$(patsubst %.md, %.xml.gen, $(wildcard *.md))
rawxmlfiles=$(shell find . -type f -name  '*.xml')

target=$(wildcard draft-*.xml)
output=$(patsubst %.xml, %.txt, $(target))

all: $(output)

$(output): $(target) $(genxmlfiles) $(rawxmlfiles) $(refxmlfiles)
	xml2rfc $(target) -o $(output) --text -D $(shell date -u +%Y-%m-%d)

%.xml.gen: %.md
	pandoc $(PANDOC_OPT) $< | xsltproc --nonet $(stylefile) - > $@

view: all
	vim $(output)

clean:
	@rm -rf $(output)
	@rm -rf $(genxmlfiles)
