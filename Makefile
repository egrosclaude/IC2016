DEPS = reveal.header reveal.trailer

all: so comp pres siste uni repre texto arqui

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
	pandoc $*.md -o $*.pdf

