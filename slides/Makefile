VERSION=08
target=ietf-alto-path-vector-$(VERSION).pdf

mdfiles=$(wildcard src/*.md)
gentexfiles=$(patsubst src/%.md, src/%.gen.tex, $(mdfiles))
diafiles=$(wildcard src/figures/*.dia)
genepsfiles=$(patsubst src/figures/%.dia, src/figures/%-gen.eps, $(diafiles))

all: $(target)

$(target): src/*.tex $(gentexfiles) $(genepsfiles)
	latexmk -xelatex src/rsa-slides.tex && mv rsa-slides.pdf $@

src/%.gen.tex: src/%.md
	pandoc $< -t beamer+header_attributes --slide-level 2 -o $@

src/figures/%-gen.eps: src/figures/%.dia
	dia -t eps -e $@ $<

view: $(target)
	evince $(target)

clean:
	rm -f *.pdf *.aux *.toc *.snm *.log *.nav *.out
	rm -f $(gentexfiles) $(genepsfiles)
