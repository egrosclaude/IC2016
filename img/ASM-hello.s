.globl  _start
.text				# seccion de codigo
_start:
        movl    $len, %edx	# carga parametros longitud
        movl    $msg, %ecx	# y direccion del mensaje
        movl    $1, %ebx        # parametro 1: stdout
        movl    $4, %eax        # servicio 4: write
        int     $0x80		# syscall

        movl    $0, %ebx        # retorna 0
        movl    $1, %eax        # servicio 1: retorno de llamada
        int     $0x80		# syscall
.data				# seccion de datos
msg:
        .ascii  "Hola, mundo!\n"
        len =   . - msg		# longitud del mensaje
