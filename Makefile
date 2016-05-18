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

	
#comp: src/Sistemas\ de\ Cómputo.slides
#	./macro "src/Sistemas de Cómputo.slides" > "Sistemas de Cómputo.html"
#	./asides.pl "src/Sistemas de Cómputo.slides" > "Sistemas de Cómputo.md"
#	pandoc "Sistemas de Cómputo.md" -o "Sistemas de Cómputo.pdf"
#	atril "Sistemas de Cómputo.pdf"

#pres: src/Presentación.slides
#	./macro "src/Presentación.slides" > "Presentación.html" 

#siste: src/Sistemas\ de\ Numeración.slides
#	./macro "src/Sistemas de Numeración.slides" > "Sistemas de Numeración.html" 

#uni: src/Unidades\ de\ Información.slides
#	./macro "src/Unidades de Información.slides" > "Unidades de Información.html" 

#repre: src/Representación\ Digital\ de\ Datos.slides
#	./macro "src/Representación Digital de Datos.slides" > "Representación Digital de Datos.html" 

#texto: src/Texto\ y\ Multimedia.slides 
#	./macro "src/Texto y Multimedia.slides" > "Texto y Multimedia.html"
#
#arqui: src/Arquitectura.slides 
#	./macro "src/Arquitectura.slides" > "Arquitectura.html"
#
#animate:
#	./macro src/animate.slides > animate.html
#
#otro:
#	./macro src/OtroTexto.slides > OtroTexto.html
#
#chartexample:
#	./macro src/chartexample.slides > chartexample.html
#


