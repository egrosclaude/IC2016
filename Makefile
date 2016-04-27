all: pres siste uni repre texto arqui

pres: src/Presentación.slides
	./macro "src/Presentación.slides" > "Presentación.html" 

siste: src/Sistemas\ de\ Numeración.slides
	./macro "src/Sistemas de Numeración.slides" > "Sistemas de Numeración.html" 

uni: src/Unidades\ de\ Información.slides
	./macro "src/Unidades de Información.slides" > "Unidades de Información.html" 

repre: src/Representación\ Digital\ de\ Datos.slides
	./macro "src/Representación Digital de Datos.slides" > "Representación Digital de Datos.html" 

texto: src/Texto\ y\ Multimedia.slides 
	./macro "src/Texto y Multimedia.slides" > "Texto y Multimedia.html"

arqui: src/Arquitectura.slides 
	./macro "src/Arquitectura.slides" > "Arquitectura.html"

animate:
	./macro src/animate.slides > animate.html

otro:
	./macro src/OtroTexto.slides > OtroTexto.html




