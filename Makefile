DEPS = src/reveal.header src/reveal.trailer
DTAPE=/home/oso/IC2016/decktape

all: re so comp pres siste uni repre texto arqui soft demo

demo: demo.html
re: Redes.html
soft: Software.html
so: SistemasOperativos.html
comp: SistemasDeCómputo.html
pres: Presentación.html
siste: SistemasDeNumeración.html
uni: UnidadesDeInformación.html
repre: RepresentaciónDigitalDeDatos.html
texto: TextoYMultimedia.html
arqui: Arquitectura.html

%.html: src/%.slides $(DEPS) 
	./macro $< > $*.html
	./asides.pl $< > $*.md
	pandoc $*.md -o $*-notes.pdf
	$(DTAPE)/bin/phantomjs $(DTAPE)/decktape.js reveal http://localhost:8000/$*.html $*.pdf
#	pandoc $*-ok.md -o $*.pdf

