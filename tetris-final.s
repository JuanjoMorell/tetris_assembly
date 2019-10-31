# Versión incompleta del tetris 
# Sincronizada con tetris.s:r2916
        
	.data	

pantalla:
	.word	0
	.word	0
	.space	1024

campo:
	.word	0
	.word	0
	.space	1024

alto:
	.word 	0

puntos:
	.word	0
	
buffer:
	.space	256

buffer2:
	.space 256

pieza_actual:
	.word	0
	.word	0
	.space	1024

pieza_actual_x:
	.word 0

pieza_actual_y:
	.word 0

pieza_sig:
	.word	0
	.word	0
	.space	1024

pieza_sig_x:
	.word 0

pieza_sig_y:
	.word 0

imagen_auxiliar:
	.word	0
	.word	0
	.space	1024

pieza_jota:
	.word	2
	.word	3
	.ascii		"\0#\0###\0\0"

pieza_ele:
	.word	2
	.word	3
	.ascii		"#\0#\0##\0\0"

pieza_barra:
	.word	1
	.word	4
	.ascii		"####\0\0\0\0"

pieza_zeta:
	.word	3
	.word	2
	.ascii		"##\0\0##\0\0"

pieza_ese:
	.word	3
	.word	2
	.ascii		"\0####\0\0\0"

pieza_cuadro:
	.word	2
	.word	2
	.ascii		"####\0\0\0\0"

pieza_te:
	.word	3
	.word	2
	.ascii		"\0#\0###\0\0"

piezas:
	.word	pieza_jota
	.word	pieza_ele
	.word	pieza_zeta
	.word	pieza_ese
	.word	pieza_barra
	.word	pieza_cuadro
	.word	pieza_te

final_partida:
	.byte 	0

acabar_partida:
	.byte	0

	.align	2
procesar_entrada.opciones:
	.byte	'x'
	.space	3
	.word	tecla_salir
	.byte	'j'
	.space	3
	.word	tecla_izquierda
	.byte	'l'
	.space	3
	.word	tecla_derecha
	.byte	'k'
	.space	3
	.word	tecla_abajo
	.byte	'i'
	.space	3
	.word	tecla_rotar

str000:
	.asciiz		"Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n"
str001:
	.asciiz		"\n¡Adiós!\n"
str002:
	.asciiz		"\nOpción incorrecta. Pulse cualquier tecla para seguir.\n"
str003:
	.asciiz		"Puntuacion: "
str004:
	.asciiz		"\n\n\n\n+--------------+\n|FIN DE PARTIDA|\n|Presiona tecla|\n+--------------+"
str005:
	.asciiz		"+--------+                    |  NEXT  |                    +--------+                    |        |                    |        |                    |        |                    |        |                    +--------+"
espacio:
	.asciiz		"\n "	

	
	.text	

imagen_pixel_addr:			# ($a0, $a1, $a2) = (imagen, x, y)
					# pixel_addr = &data + y*ancho + x
    	lw	$t1, 0($a0)		# $a0 = dirección de la imagen 
					# $t1 ← ancho
    	mul	$t1, $t1, $a2		# $a2 * ancho
    	addu	$t1, $t1, $a1		# $a2 * ancho + $a1
    	addiu	$a0, $a0, 8		# $a0 ← dirección del array data
    	addu	$v0, $a0, $t1		# $v0 = $a0 + $a2 * ancho + $a1
    	jr	$ra

imagen_get_pixel:			# ($a0, $a1, $a2) = (img, x, y)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)		# guardamos $ra porque haremos un jal
	jal	imagen_pixel_addr	# (img, x, y) ya en ($a0, $a1, $a2)
	lbu	$v0, 0($v0)		# lee el pixel a devolver
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

imagen_set_pixel:			# ($a0, $a1, $a2, $a3) = (img, x, y, color)
	addiu	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s5, 20($sp)		# $s5 -> fondo
	sw	$s4, 16($sp)		# $s4 -> alto
	sw	$s3, 12($sp)		# $s3 -> ancho
	sw	$s2, 8($sp)		# $s2 -> x
	sw 	$s1, 4($sp) 		# $s1 -> y
	sw	$s0, 0($sp)		# $s0 -> a0
	
	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2
	move 	$s3, $a3
	
	move	$a0, $s0
	move	$a1, $s1
	move 	$a2, $s2
	jal 	imagen_pixel_addr	# $v0 -> respuesta de la funcion
	
	sb      $s3, 0($v0)		
	
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$ra, 24($sp)
	addiu 	$sp, $sp, 28
	jr 	$ra


imagen_clean: 				# ($a0, $a1) = (*img, fondo)
	addiu	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s5, 20($sp)		# $s5 
	sw	$s4, 16($sp)		# $s4 
	sw	$s3, 12($sp)		# $s3 -> a3, fondo
	sw	$s2, 8($sp)		# $s2 -> a2, alto
	sw 	$s1, 4($sp) 		# $s1 -> a1, ancho
	sw	$s0, 0($sp)		# $s0 -> a0, *img

	move    $s0, $a0
	li 	$s1, 0			# y = 0
	lw 	$s3, 0($a0)		# $t2 = ancho
	lw 	$s4, 4($a0)		# $t3 = alto
	move	$s5, $a1		# $s5 = fondo
			
IC_y:   li	$s2, 0 			# x = 0
	bge	$s1, $s4, IC_fin
	
IC_x:   bge	$s2, $s3, IC_s
	move	$a0, $s0
	move 	$a1, $s2
	move 	$a2, $s1
	move 	$a3, $s5
	jal 	imagen_set_pixel
	
	addiu 	$s2, $s2, 1
	j 	IC_x
		
IC_s:   addiu 	$s1, $s1, 1
	j	IC_y

IC_fin: lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$ra, 24($sp)
	addiu 	$sp, $sp, 28
	jr	$ra			
	

imagen_init:				# ($a0, $a1, $a2, $a3) = (*img, ancho, alto, fondo)
	addi 	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	
	move 	$s0, $a0
	move 	$s1, $a1
	move 	$s2, $a2
	move 	$s3, $a3
	
	#Guardar ancho y alto
	sw	$s1, 0($s0)
	sw	$s2, 4($s0)
	
	#Llamar a la funcion imagen_clean
	move	$a0, $s0
	move	$a1, $s3
	jal 	imagen_clean
	
	lw 	$s0, 0($sp)
	lw 	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$ra, 16($sp)
	addi	$sp, $sp, 20
	jr	$ra

imagen_copy:
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a0	# $s0 -> dst
	move	$s1, $a1	# $s1 -> src
	
	lw	$s2, 0($s1)	# $s2 -> src->ancho
	lw	$s3, 4($s1)	# $s3 -> src->alto
	sw	$s2, 0($s0)
	sw	$s3, 4($s0)
	li	$s4, 0		# $s4 -> y

ICO_1:	li	$s5, 0 			# $s5 -> x
	bge	$s4, $s3, ICO_4

ICO_2:	bge	$s5, $s2, ICO_3
	#Procedimiento
	move 	$a0, $s1
	move 	$a1, $s5
	move 	$a2, $s4
	jal	imagen_get_pixel
	move 	$s6, $v0		# $s6 -> p
	
	move	$a0, $s0
	move	$a1, $s5
	move 	$a2, $s4
	move 	$a3, $s6
	jal 	imagen_set_pixel
	
	addi 	$s5, $s5, 1
	j 	ICO_2

ICO_3:	addi 	$s4, $s4, 1
	j 	ICO_1
	
ICO_4:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra

imagen_print:				# $a0 = img
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a0
	lw	$s3, 4($s0)		# img->alto
	lw	$s4, 0($s0)		# img->ancho
        #  for (int y = 0; y < img->alto; ++y)
	li	$s1, 0			# y = 0
B6_2:	bgeu	$s1, $s3, B6_5		# acaba si y ≥ img->alto
	#    for (int x = 0; x < img->ancho; ++x)
	li	$s2, 0			# x = 0
B6_3:	bgeu	$s2, $s4, B6_4		# acaba si x ≥ img->ancho
	move	$a0, $s0		# Pixel p = imagen_get_pixel(img, x, y)
	move	$a1, $s2
	move	$a2, $s1
	jal	imagen_get_pixel
	move	$a0, $v0		# print_character(p)
	jal	print_character
	addiu	$s2, $s2, 1		# ++x
	j	B6_3
	#    } // for x
B6_4:	li	$a0, 10			# print_character('\n')
	jal	print_character
	addiu	$s1, $s1, 1		# ++y
	j	B6_2
	#  } // for y
B6_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra

imagen_dibuja_imagen:
	#Pila
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)		
	sw	$s4, 16($sp)		 
	sw	$s3, 12($sp)		
	sw	$s2, 8($sp)	
	sw 	$s1, 4($sp) 		
	sw	$s0, 0($sp)
	
	#Inicializar $s
	move 	$s0, $a0	# $s0 -> *dst
	move 	$s4, $a1	# $s4 -> *src
	move	$s5, $a2	# $s5 -> dst_x
	move 	$s3, $a3	# $s3 -> dst_y
	li 	$s1, 0 		# $s1 -> y
	
IDI_1: 	li 	$s2, 0		# $s2 -> x
	lw	$t0, 4($s4)
	bge	$s1, $t0, IDI_5
	
IDI_2:	lw	$t1, 0($s4)
	bge 	$s2, $t1, IDI_4
	#Procedimiento
	move	$a0, $s4
	move 	$a1, $s2
	move 	$a2, $s1
	jal 	imagen_get_pixel
	move	$s6, $v0
	beqz	$s6, IDI_3
	move	$a0, $s0
	add 	$a1, $s2, $s5
	add	$a2, $s1, $s3
	move 	$a3, $s6
	jal 	imagen_set_pixel
	
IDI_3:	addi 	$s2, $s2, 1
	j	IDI_2	

IDI_4:	addi	$s1, $s1, 1
	j 	IDI_1
	
IDI_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra
	

imagen_dibuja_imagen_rotada:
 	#Pila
    	addiu  $sp, $sp, -32
    	sw     $ra, 28($sp)
    	sw     $s6, 24($sp)
    	sw     $s5, 20($sp)
    	sw     $s4, 16($sp)
    	sw     $s3, 12($sp)
    	sw     $s2, 8($sp)
    	sw     $s1, 4($sp)
    	sw     $s0, 0($sp)

    	#Inicializar $s
    	move    $s0, $a0    # $s0 -> *dst
    	move    $s4, $a1    # $s4 -> *src
    	move    $s5, $a2    # $s5 -> dst_x
    	move    $s3, $a3    # $s3 -> dst_y
    	li      $s1, 0         # $s1 -> y

IDR_1:  li      $s2, 0        # $s2 -> x
    	lw    	$t0, 4($s4)
    	bge     $s1, $t0, IDR_5

IDR_2:  lw      $t0, 0($s4)
    	bge     $s2, $t0, IDR_4
    	#Procedimiento
    	move    $a0, $s4
    	move    $a1, $s2
    	move    $a2, $s1
    	jal     imagen_get_pixel
    	move    $s6, $v0     #p
    	beqz    $s6, IDR_3
    	move    $a0, $s0
    	lw      $t1,4($s4)
    	addi    $t1,$t1,-1
    	add     $t1,$t1,$s5
    	sub     $a1,$t1,$s1
                         #a2
    	add     $a2,$s3,$s2
    	move    $a3,$s6
    	jal     imagen_set_pixel

IDR_3:  addi     $s2, $s2, 1
    	j    IDR_2

IDR_4:  addi    $s1, $s1, 1
    	j     IDR_1

IDR_5:  lw    $s0, 0($sp)
    	lw    $s1, 4($sp)
    	lw    $s2, 8($sp)
    	lw    $s3, 12($sp)
    	lw    $s4, 16($sp)
    	lw    $s5, 20($sp)
    	lw    $s6, 24($sp)
    	lw    $ra, 28($sp)
   	addiu $sp, $sp, 32
        jr    $ra

pieza_aleatoria:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$a0, 0
	li	$a1, 7
	jal	random_int_range	# $v0 ← random_int_range(0, 7)
	sll	$t1, $v0, 2
	la	$v0, piezas
	addu	$t1, $v0, $t1		# $t1 = piezas + $v0*4
	lw	$v0, 0($t1)		# $v0 ← piezas[$v0]
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

integer_to_string:			# ($a0, $a1) = (int, dir)
	move    $t0, $a1
	lw	$t1, 0($a0)
        abs	$t1, $t1		
        bnez	$t1, B4_3		
        addiu	$t2, $zero, '0'
        sb	$t2, 0($t0)
        addiu	$t0, $t0, 1
        j	B4_7
    
B4_3:   blez	$t1, B4_6
	li 	$t5, 10		
	div	$t1, $t5		
	mflo	$t1			
	mfhi	$t2			
	bge	$t2, 10, B4_4		
	addiu	$t2, $t2, '0'		
	j	B4_5		
B4_4:	subiu	$t2, $t2, 10		
	addiu	$t2, $t0, 'A'		
B4_5:	sb	$t2, 0($t0)		
	addiu	$t0, $t0, 1		
	j	B4_3			
B4_6:	bgez	$a0, B4_7
	addiu	$t3, $zero, '-'
	sb	$t3, 0($t0)
	addiu	$t0, $t0, 1   
        
B4_7:	sb	$zero, 0($t0)		
	move 	$t2, $a1
	subi 	$t0, $t0, 1
	
B4_9:	ble	$t0, $t2, B4_10
	lb	$t3, 0($t0)
	lb   	$t4, 0($t2)
	sb	$t3, 0($t2)
	sb	$t4, 0($t0)
	addi	$t0, $t0, -1
	addi	$t2, $t2, 1
	j	B4_9

B4_10:	jr	$ra


imagen_dibuja_cadena:
	addi 	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2
	move	$s3, $a3
	
IMC_1:	lb	$t0, 0($s3)
	beqz	$t0, IMC_2
	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s2
	move	$a3, $t0
	jal 	imagen_set_pixel
	addi	$s1, $s1, 1
	addi	$s3, $s3, 1
	j	IMC_1	
	
IMC_2:	lw 	$s0, 0($sp)
	lw 	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$ra, 16($sp)
	addi	$sp, $sp, 20
	jr	$ra

comprobar_lineas:
	addi 	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	la	$s0, campo
	li	$s2, 0		#y
	lw	$s4, 0($s0)	# $s4 -> ancho	
	lw	$s5, 4($s0)	# $s5 -> alto

CL_1:   bge	$s2, $s5, CL_3	# si y < campo-alto 
	li	$s3, 0		# x
	li	$s1, 0		# contador
	
CL_2:	bge	$s3, $s4, CL_4	# si x < campo-ancho
	
	move	$a0, $s0
	move	$a1, $s3
	move	$a2, $s2
	jal	imagen_get_pixel
	move	$t2, $v0
	beqz	$t2, CL_5	# Se comprueba si el pixel esta ocupado por #
	addi	$s1, $s1, 1 	# Aumenta contador
	
CL_5:	addi	$s3, $s3, 1	# Actualizar x
	j	CL_2		
		
CL_4:	bne	$s1, $s4, CL_6
	lb	$t1, puntos
	addi	$t1, $t1, 10
	sb	$t1, puntos
	
CL_6:	addi	$s2, $s2, 1
	j	CL_1	

CL_3:	lw 	$s0, 0($sp)
	lw 	$s1, 4($sp)
        lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$ra, 24($sp)
	addi	$sp, $sp, 28
	jr	$ra


actualizar_pantalla:
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s2, 4($sp)
	sw	$s1, 0($sp)
	la	$s2, campo
	
	la	$a0, pantalla
	li	$a1, ' '
	jal	imagen_clean		# imagen_clean(pantalla, ' ')
		
	#Imprimir Puntuacion
	la	$a0, pantalla
	li	$a1, 2
	li	$a2, 1
	la	$a3, str003
	jal 	imagen_dibuja_cadena
	
	#Imprimir Valor de puntuacion
	la	$a0, puntos
	la	$a1, buffer
	jal 	integer_to_string
	
	la	$a0, pantalla
	li 	$a1, 13
	li	$a2, 1
	la	$a3, buffer
	jal	imagen_dibuja_cadena
	
	#Imprimir next
	la	$a0, pantalla
	li	$a1, 17
	li	$a2, 2
	la	$a3, str005
	jal	imagen_dibuja_cadena
	
	#Imprimir siguiente pieza
	la	$a0, pantalla
	la	$a1, pieza_sig
	li	$a2, 21
	li	$a3, 5
	jal 	imagen_dibuja_imagen
	
        # for (int y = 0; y < campo->alto; ++y) {
	li	$s1, 0			# y = 0
B10_2:	lw	$t1, 4($s2)		# campo->alto
	bge	$s1, $t1, B10_3		# sigue si y < campo->alto
	la	$a0, pantalla
	li	$a1, 0                  # pos_campo_x - 1
	addi	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, 0, y, '|')
	la	$a0, pantalla
	lw	$t1, 0($s2)		# campo->ancho
	addiu	$a1, $t1, 1		# campo->ancho + 1
	addiu	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, campo->ancho + 1, y, '|')
        addiu	$s1, $s1, 1		# ++y
        j       B10_2
        # } // for y
	# for (int x = 0; x < campo->ancho + 2; ++x) { 
B10_3:	li	$s1, 0			# x = 0
B10_5:  lw	$t1, 0($s2)		# campo->ancho
        addiu   $t1, $t1, 2             # campo->ancho + 2
        bge	$s1, $t1, B10_6		# sigue si x < campo->ancho + 2
	la	$a0, pantalla
	move	$a1, $s1                # pos_campo_x - 1 + x
        lw	$t1, 4($s2)		# campo->alto
	addiu	$a2, $t1, 2		# campo->alto + pos_campo_y
	li	$a3, '-'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, x, campo->alto + 1, '-')
	addiu	$s1, $s1, 1		# ++x
	j       B10_5
        # } // for x
B10_6:	la	$a0, pantalla
	move	$a1, $s2
	li	$a2, 1                  # pos_campo_x
	li	$a3, 2                  # pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, campo, 1, 2)
	la	$a0, pantalla
	la	$a1, pieza_actual
	lw	$t1, pieza_actual_x
	addiu	$a2, $t1, 1		# pieza_actual_x + pos_campo_x
	lw	$t1, pieza_actual_y
	addiu	$a3, $t1, 2		# pieza_actual_y + pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, pieza_actual, pieza_actual_x + pos_campo_x, pieza_actual_y + pos_campo_y)
	jal	clear_screen		# clear_screen()
	la	$a0, pantalla
	jal	imagen_print		# imagen_print(pantalla)
	lw	$s1, 0($sp)
	lw	$s2, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

nueva_pieza_actual1:
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	#Crea la primera pieza del juego
	la	$s0, pieza_actual
	jal 	pieza_aleatoria
	move	$s1, $v0
	
	move 	$a0, $s0
	move	$a1, $s1
	jal 	imagen_copy
	
	addi	$t0, $0, 8
	sw	$t0, pieza_actual_x
	sw	$0, pieza_actual_y
	
	#Crea la pieza_sig
	la	$s0, pieza_sig
	jal 	pieza_aleatoria
	move	$s1, $v0
	
	move 	$a0, $s0
	move	$a1, $s1
	jal 	imagen_copy
	
	addi	$t0, $0, 8
	sw	$t0, pieza_sig_x
	sw	$0, pieza_sig_y
	
	#Actualizar puntuacion
	lw	$t1, puntos
	addi	$t1, $t1, 1
	sw	$t1, puntos

	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

comprobar_final:
	addiu	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)	
	
	la 	$s0, campo
	li	$s2, 1
	#Comprobar final de partida
NPA_1:	move	$a0, $s0
	lw	$t0, 4($a0)
	bge	$s2, $t0, NPA_3
	move	$a1, $s2
	li	$a2, 0
	jal 	imagen_get_pixel
	move	$t2, $v0
	beqz	$t2, NPA_2
	lb	$t3, final_partida
	li	$t3, 1
	sb	$t3, final_partida
NPA_2:	addi	$s2, $s2, 1
	j	NPA_1

NPA_3:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$ra, 12($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	

nueva_pieza_actual2:
	addiu	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	#Copia la pieza_sig anterior
	la	$s0, pieza_actual
	la	$s1, pieza_sig

	jal 	comprobar_final
			
	move 	$a0, $s0
	move	$a1, $s1
	jal 	imagen_copy
	
	addi	$t0, $0, 8
	sw	$t0, pieza_actual_x
	sw	$0, pieza_actual_y
	
	#Nueva pieza_sig
	la	$s0, pieza_sig
	jal 	pieza_aleatoria
	move	$s1, $v0
	
	move 	$a0, $s0
	move	$a1, $s1
	jal 	imagen_copy
	
	addi	$t0, $0, 8
	sw	$t0, pieza_sig_x
	sw	$0, pieza_sig_y
	
	#Actualizar puntuacion
	lw	$t1, puntos
	addi	$t1, $t1, 1
	sw	$t1, puntos
	
	jal 	comprobar_lineas
	
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$ra, 12($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	
	
probar_pieza:				# ($a0, $a1, $a2) = (pieza, x, y)
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s7, 24($sp)
	sw	$s6, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a2		# y
	move	$s1, $a1		# x
	move	$s2, $a0		# pieza
	
B12_5:	li	$v0, 0
	bltz	$s1, B12_13		# if (x < 0) return false
	lw	$t1, 0($s2)		# pieza->ancho
	addu	$t1, $s1, $t1		# x + pieza->ancho
	la	$s4, campo
	lw	$v1, 0($s4)		# campo->ancho
	bltu	$v1, $t1, B12_13	# if (x + pieza->ancho > campo->ancho) return false
	bltz	$s0, B12_13		# if (y < 0) return false
	lw	$t1, 4($s2)		# pieza->alto
	addu	$t1, $s0, $t1		# y + pieza->alto
	lw	$v1, 4($s4)		# campo->alto
	bltu	$v1, $t1, B12_13	# if (campo->alto < y + pieza->alto) return false
	# for (int i = 0; i < pieza->ancho; ++i) {
	lw	$t1, 0($s2)		# pieza->ancho
	beqz	$t1, B12_12
	li	$s3, 0			# i = 0
	#   for (int j = 0; j < pieza->alto; ++j) {
	lw	$s7, 4($s2)		# pieza->alto
B12_6:	beqz	$s7, B12_11
	li	$s6, 0			# j = 0
B12_8:	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s6
	jal	imagen_get_pixel	# imagen_get_pixel(pieza, i, j)
	beqz	$v0, B12_10		# if (imagen_get_pixel(pieza, i, j) == PIXEL_VACIO) sigue
	move	$a0, $s4
	addu	$a1, $s1, $s3		# x + i
	addu	$a2, $s0, $s6		# y + j
	jal	imagen_get_pixel
	move	$t1, $v0		# imagen_get_pixel(campo, x + i, y + j)
	li	$v0, 0
	bnez	$t1, B12_13		# if (imagen_get_pixel(campo, x + i, y + j) != PIXEL_VACIO) return false
B12_10:	addiu	$s6, $s6, 1		# ++j
	bltu	$s6, $s7, B12_8		# sigue si j < pieza->alto
        #   } // for j
B12_11:	lw	$t1, 0($s2)		# pieza->ancho
	addiu	$s3, $s3, 1		# ++i
	bltu	$s3, $t1, B12_6 	# sigue si i < pieza->ancho
        # } // for i
B12_12:	li	$v0, 1			# return true
B12_13:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s6, 20($sp)
	lw	$s7, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra

intentar_movimiento:
	addi 	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	la	$s0, pieza_actual	# $s0 -> pieza_actual
	move 	$s1, $a0		# $s1 -> x
	move	$s2, $a1		# $s2 -> y

	move	$a0, $s0
	move	$a1, $s1
	move 	$a2, $s2
	jal 	probar_pieza
	beqz	$v0, IM_f
	sw	$s1, pieza_actual_x
	sw	$s2, pieza_actual_y
	li	$v0, 1
	j 	IM_v
	
IM_f:	li	$v0, 0

IM_v:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$ra, 12($sp)
	addiu	$sp, $sp, 16
	jr	$ra

bajar_pieza_actual:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	lw	$s0, pieza_actual_x
	lw	$s1, pieza_actual_y
	la	$s2, campo
	la	$s3, pieza_actual
	
	move	$a0, $s0
	addi	$a1, $s1, 1
	jal 	intentar_movimiento
	bnez	$v0, BPA_f
	
	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s0
	move	$a3, $s1
	jal 	imagen_dibuja_imagen
	jal 	nueva_pieza_actual2

BPA_f:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

intentar_rotar_pieza_actual:
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	la	$s0, imagen_auxiliar	# $s0 -> imagen_auxiliar
	move 	$s1, $s0		# $s1 -> pieza_rotada
	la	$s2, pieza_actual	# $s2 -> pieza_actual
	lw	$s3, 0($s2)		# $s3 -> pieza_actual->ancho
	lw	$s4, 4($s2)		# $s4 -> pieza_actual->alto
	lw	$s5, pieza_actual_x
	lw	$s6, pieza_actual_y
	
	move	$a0, $s1
	move	$a1, $s4
	move	$a2, $s3
	li	$a3, 0
	jal 	imagen_init
	
	move 	$a0, $s1
	move	$a1, $s2
	li	$a2, 0
	li	$a3, 0
	jal 	imagen_dibuja_imagen_rotada
	
	move	$a0, $s1
	move	$a1, $s5
	move	$a2, $s6
	jal 	probar_pieza
	beqz	$v0, IRPA_f
	
	move	$a0, $s2
	move	$a1, $s1
	jal 	imagen_copy
	

IRPA_f:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra

tecla_salir:
	li	$v0, 1
	sb	$v0, acabar_partida	# acabar_partida = true
	jr	$ra

tecla_izquierda:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, -1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x - 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_derecha:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, 1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x + 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_abajo:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	bajar_pieza_actual	# bajar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_rotar:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	intentar_rotar_pieza_actual	# intentar_rotar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

procesar_entrada:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	jal	keyio_poll_key
	move	$s0, $v0		# int c = keyio_poll_key()
        # for (int i = 0; i < sizeof(opciones) / sizeof(opciones[0]); ++i) { 
	li	$s1, 0			# i = 0, $s1 = i * sizeof(opciones[0]) // = i * 8
	la	$s3, procesar_entrada.opciones	
	li	$s4, 40			# sizeof(opciones) // == 5 * sizeof(opciones[0]) == 5 * 8
B21_1:	addu	$t1, $s3, $s1		# procesar_entrada.opciones + i*8
	lb	$t2, 0($t1)		# opciones[i].tecla
	bne	$t2, $s0, B21_3		# if (opciones[i].tecla != c) siguiente iteración
	lw	$t2, 4($t1)		# opciones[i].accion
	jalr	$t2			# opciones[i].accion()
	jal	actualizar_pantalla	# actualizar_pantalla()
B21_3:	addiu	$s1, $s1, 8		# ++i, $s1 += 8
	bne	$s1, $s4, B21_1		# sigue si i*8 < sizeof(opciones)
        # } // for i
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

jugar_partida:
	addiu	$sp, $sp, -12	
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	la	$a0, pantalla
	li	$a1, 30
	li	$a2, 22
	li	$a3, 32
	jal	imagen_init		# imagen_init(pantalla, 20, 22, ' ')
	la	$a0, campo
	li	$a1, 14
	li	$a2, 18
	li	$a3, 0
	jal	imagen_init		# imagen_init(campo, 14, 18, PIXEL_VACIO)
	sw	$0, puntos		# Inicializar puntos a 0
	sw	$0, final_partida
	jal	nueva_pieza_actual1	# nueva_pieza_actual()
	sb	$zero, acabar_partida	# acabar_partida = false
	jal	get_time		# get_time()
	move	$s0, $v0		# Hora antes = get_time()
	jal	actualizar_pantalla	# actualizar_pantalla()
	j	B22_2
        # while (!acabar_partida) { 
B22_2:	lbu	$t2, final_partida
	bnez	$t2, B22_5
	lbu	$t1, acabar_partida
	bnez	$t1, B22_5		# if (acabar_partida != 0) sale del bucle
	jal	procesar_entrada	# procesar_entrada()
	jal	get_time		# get_time()
	move	$s1, $v0		# Hora ahora = get_time()
	subu	$t1, $s1, $s0		# int transcurrido = ahora - antes
	ble	$t1, 1000, B22_2	# if (transcurrido < pausa) siguiente iteración
B22_1:	
	#Comprobar si hay final de juego
	jal	bajar_pieza_actual	# bajar_pieza_actual()
	jal	actualizar_pantalla	# actualizar_pantalla()
	move	$s0, $s1		# antes = ahora
        j	B22_2			# siguiente iteración
       	# }
B22_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra


	.globl	main

main:					# ($a0, $a1) = (argc, argv) 
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
B23_2:	lb	$t0, final_partida
	bnez	$t0, B23_3
	jal	clear_screen		# clear_screen()
	la	$a0, str000
	jal	print_string		# print_string("Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n")
	jal	read_character		# char opc = read_character()
	beq	$v0, '2', B23_1		# if (opc == '2') salir
	bne	$v0, '1', B23_5		# if (opc != '1') mostrar error
	jal	jugar_partida		# jugar_partida()
	j	B23_2
B23_1:	la	$a0, str001
	jal	print_string		# print_string("\n¡Adiós!\n")
	li	$a0, 0
	jal	mips_exit		# mips_exit(0)
	j	B23_2
B23_5:	la	$a0, str002
	jal	print_string		# print_string("\nOpción incorrecta. Pulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	B23_2
	
B23_3:  li	$t0, 0
	sb	$t0, final_partida
	jal	clear_screen		# clear_screen()
	la	$a0, str004
	jal	print_string
	la	$a0, espacio
	jal	print_string
	la	$a0, str003
	jal	print_string
	la	$a0, puntos
	la	$a1, buffer
	jal 	integer_to_string
	la	$a0, buffer
	jal	print_string
	la	$a0, espacio
	jal 	print_string
	jal 	read_character
	j	B23_2

	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

#
# Funciones de la librería del sistema
#

print_character:
	li	$v0, 11
	syscall	
	jr	$ra

print_string:
	li	$v0, 4
	syscall	
	jr	$ra

get_time:
	li	$v0, 30
	syscall	
	move	$v0, $a0
	move	$v1, $a1
	jr	$ra

read_character:
	li	$v0, 12
	syscall	
	jr	$ra

clear_screen:
	li	$v0, 39
	syscall	
	jr	$ra

mips_exit:
	li	$v0, 17
	syscall	
	jr	$ra

random_int_range:
	li	$v0, 42
	syscall	
	move	$v0, $a0
	jr	$ra

keyio_poll_key:
	li	$v0, 0
	lb	$t0, 0xffff0000
	andi	$t0, $t0, 1
	beqz	$t0, keyio_poll_key_return
	lb	$v0, 0xffff0004
keyio_poll_key_return:
	jr	$ra

