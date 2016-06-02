
## Sistemas Operativos

## Sistemas de cómputo

## Sistemas de cómputo

## Software de los sistemas de cómputo

## Evolución del software de base

## Componentes del SO

## Software involucrado

## Kernel o núcleo

## Modo de ejecución dual

Los modernos procesadores funcionan en lo que llamamos **modo dual** de ejecución, donde el ISA se divide en dos grupos de instrucciones. Ciertas instrucciones que controlan el modo de operación de la CPU, el acceso a memoria, o a las unidades de Entrada/Salida, pertenecen al grupo de instrucciones del **modo privilegiado**. Un proceso de usuario funciona en modo **no privilegiado**, donde tiene acceso a la mayoría de las instrucciones del ISA, pero no a las instrucciones del modo privilegiado. 

El proceso, durante su vida, ejecutará instrucciones en modo no privilegiado hasta que necesite un servicio del sistema operativo, como el acceso a un recurso físico o lógico.


## Modo de ejecución dual

Para requerir este servicio, el proceso ejecuta una instrucción de **llamada al sistema** o **system call**, que es la única instrucción del conjunto no privilegiado que permite a la CPU conmutar al modo privilegiado.


## Modo de ejecución dual

La llamada al sistema conmuta el modo de la CPU a modo privilegiado **y además** fuerza el salto a una cierta dirección fija de memoria donde existe código del kernel. En esa dirección de memoria existe una rutina de atención de llamadas al sistema, que determina, por el contenido de los registros de la CPU, qué es lo que está solicitando el proceso. 

Con estos datos, esa rutina de atención de llamadas al sistema dirigirá el pedido al subsistema del kernel correspondiente, ejecutando siempre en modo privilegiado, y por lo tanto, con completo acceso a los recursos.
</section>
<section data-transition="fade-in slide-out">

## Modo de ejecución dual
<h2>Modo de ejecución dual</h2>
<img src="img/modos-3.png" class="stretch plain">

El subsistema que corresponda hará las verificaciones necesarias para cumplir el servicio: 

* El usuario dueño del proceso, ¿tiene los permisos necesarios?
* El recurso, ¿está disponible o está siendo usado por otro proceso?, etc.

Cuando se cumplan todos los requisitos, se ejecutará el servicio pedido y luego se volverá a modo usuario, a continuar con la ejecución del proceso.  


## Aplicaciones

## Bibliotecas

## Kernel

## Llamadas al sistema

## Cronología

## Cronología

## Cronología

## Cronología

## Servicios del SO

## Ejecución de programas



## Ejecución de programas

## Estados de los procesos



## Estados de los procesos



## Estados de los procesos



## Estados de los procesos



## Procesos concurrentes



## Procesos concurrentes



## Procesos concurrentes



## Procesos concurrentes



## Procesos concurrentes



## Procesos concurrentes



## Procesos concurrentes



## Procesos concurrentes



## Procesos paralelos



## Procesos

## Procesos

## Comandos de procesos



## Gestión de archivos



## Gestión de archivos

## Árbol de directorios



## Sistema de archivos



## Sistema de archivos



## Sistema de archivos



## Sistema de archivos



## Sistema de archivos



## Sistema de archivos



## Sistema de archivos



## Inodos



## Punteros directos a bloques



## Punteros indirectos



## Punteros doble-indirectos



## Directorio



## Comandos de archivos



## Comandos de directorios



## Continuará

## Operaciones de Entrada/Salida

## Gestión de memoria

## Protección

Este emulador de PC construido en Javascript nos permite practicar los comandos del shell dentro de una *máquina virtual* Linux y desde el navegador, sin necesidad de una instalación completa en nuestro equipo.

* Para retroceder en el terminal
  - Teclas Ctrl-Up, Ctrl-Down, Ctrl-PageUp y Ctrl-PageDown.
* Para copiar datos a la máquina virtual
  - Copiar el texto a la caja o **clipboard** a la derecha.
  - En el shell de la máquina virtual escribir:
        cat < /dev/clipboard > /tmp/archivo
  - Ahora tenemos ese mismo texto en el archivo /tmp/archivo.
* Para extraer datos de la máquina virtual
  - Invertir el procedimiento anterior: 
        cat mi_archivo > /dev/clipboard
  - Seleccionar el texto en la caja **clipboard** y copiarlo a alguna otra aplicación en nuestro equipo, tal como un editor.


## Referencias


