; Autor: Cesar Darinel Ortiz
; Tarea: screensaver laboratorio
; Fecha Entrega: 08/11/2018
.model small
.stack 556
.data
.386
;========================Variables declaradas aqui===========================
caracter db 1 dup ('G')
pos_x db 1 dup(1) 
pos_y db 1 dup(1)
mov_x db 1 dup(1) 
mov_y db 1 dup(1)
cambiocolor db 1 dup(1)
ultimoleido db 1 dup(' ')
; macro stop
;stop macro 				; espera en dl el caracter a mostrar.
;endm
;============================================================================
.code
main:	
	mov ax,@data
	mov ds,ax
	mov es, ax              ;set segment register
    and sp, not 3           ;align stack to avoid AC fault

	mov pos_x,0
	mov pos_y,1
	mov mov_x,1
	mov mov_y,1
	mov cambiocolor,0
	mov ultimoleido,' '
	
	mov ax,0b800h
	mov es,ax					;segmento dir. de mem de video.
	
	xor ax,ax
	xor bx,bx					;puntero para video
	xor di,di					;puntero letrero
	mov al,es:[bx]
	mov ultimoleido,al
;====================================ciclo_principal mantener codigo ==================================
ciclo_principal: 
	call pinta
	call correr
	call pausa
	call finalizo
	jmp ciclo_principal  

finalizo:
	push ax bx cx dx
	mov ah,0Bh                   ;verifico si incertaron algo por teclado
	int 21h                      ;llamada al SO
	cmp al,0ffh                  ;comparo al con alguna tecla pulsada
	je fin                     ;salimos del programa si digitan algo
	pop dx cx bx ax	
	ret
;====================================imprimo en pantalla==================================
pinta:
	call limpia
	call optener_posi
	call guardaValor
	call cambiar_color
	mov al,caracter		
	mov es:[bx],ax	
	ret
	
limpia:
	push ax cx dx
	mov ah,7
	mov al,ultimoleido
	mov es:[bx],ax
	pop dx cx ax	
	ret

guardaValor:
	push ax cx dx		
	mov al,es:[bx]
	mov ultimoleido,al	
	pop dx cx ax	
	ret

cambiar_color:
	push bx cx dx
	cmp cambiocolor,0
	je cambiar_color_fin
	inc ah
	cmp ah,250
	mov cambiocolor,0
	jmp cambiar_color_fin
	mov ah,0
	cambiar_color_fin:
	pop dx cx bx	
	ret

correr:
	push ax cx bx dx
	mov al, pos_x
	; si es mayor a 160 marco con -1
	cmp al,160
	je finll
	jmp next1
	finll:
	mov cambiocolor,1
	mov mov_x,-1
	; si es menor a 0 marco con 1
	next1:
	cmp al,0
	je finll1
	jmp fincorrer
	finll1:
	mov cambiocolor,1
	mov mov_x,1
	fincorrer: 
	call inc_x
	call inc_y
	mov pos_x, al
	;mov pos_y, ah
	pop dx bx cx ax
	ret

inc_x:
add al,mov_x
add al,mov_x
ret
inc_y:
add ah,mov_y
add ah,mov_y
ret

optener_posi:
	push ax cx dx
	xor ax, ax 
	xor cx, cx 
	mov al, pos_y
	mov cl, pos_x
	mul cx 	
	mov bx,ax
	cmp pos_y,1
	jge fin_posi
	add bx,160
	fin_posi:
	pop dx cx ax
	ret

pausa:
	push ax bx cx dx	
	mov al, 0
	mov ah, 86h
	mov cx, 1
	mov dx, 2
	int 15h
	pop dx cx bx ax	
	ret
fin:
;============================================================================
.exit
;================================Funciones aqui==============================
;============================================================================
end main

; hex    bin        color
; 0      0000      black
; 1      0001      blue
; 2      0010      green
; 3      0011      cyan
; 4      0100      red
; 5      0101      magenta
; 6      0110      brown
; 7      0111      light gray
; 8      1000      dark gray
; 9      1001      light blue
; a      1010      light green
; b      1011      light cyan
; c      1100      light red
; d      1101      light magenta
; e      1110      yellow
; f      1111      white
