IDEAL
MODEL small
STACK 100h
DATASEG

SCCORE_TEXT db 'score: 00$'
SHAPE dw 4 dup (?)
HIDDEN_SHAPE dw 4 dup (?)
ARR db 20 dup (00h)
FULL_ROW db 20 dup (0)
COLOR dw ?
BORDER_START dw 0ah
BORDER_END dw 12h
SCORE dw 0h
DIVISOR_TABLE db 10,1,0



CODESEG

;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		PLACE_SQUARE 										; get: x,y,color
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	
	mov dx,10
	mov ax,[bp+4]
	mul dx
	mov bx,ax
	mov dx,10
	mov ax,[bp+6]
	mul dx
	
	mov dx,10
	add dx,bx
lp2:
	mov cx,10
	add cx,ax
lp1:	
	push ax
	push bx 
	push cx
	push dx
	
	mov ah, 0ch
	mov al, [bp+2]
	mov bx, 0
	int 10h
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	dec cx
	cmp cx,ax
	jne lp1
	
	dec dx
	cmp dx,bx
	jne lp2
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret 6
endp		PLACE_SQUARE
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		SPAWN_SHAPE
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	
	mov bx, offset SHAPE
	mov cx,4
lps:	
	mov ax,[bx]
	mov dl,ah
	xor dh,dh
	xor ah,ah
	
	push ax
	push dx
	push [COLOR]
	call PLACE_SQUARE
	add bx,2
	dec cx
	cmp cx,0
	jne lps
	
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret
endp		SPAWN_SHAPE
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		CHECK_COLLISION										;check collision with HIDDEN_SHAPE
	mov bp, sp													;ret - in ax true:1 false:0
	push bp
	
	push bx
	push cx
	push dx
	push si
	
	mov ax,4
	mov si,offset HIDDEN_SHAPE
	xor cx,cx
	
	
lcf:
	xor bx,bx
	mov bl,[si+1]
	cmp bl,20
	je out_border
	
	mov bl,[si]
	cmp bx,[BORDER_START]
	jl out_border
	
	mov bl,[si]
	cmp bx,[BORDER_END]
	jge out_border
	
	jmp nec
out_border:
	mov ax,1
	jmp ec
nec:
	mov bl,[si+1]
	mov cl,[si]
	
	add bx,offset ARR
	
	sub cx,[BORDER_START]
	mov dx,[bx]
	shr dx,cl
	and dx,1
	cmp dx,1
	jne nec2
	mov ax,1
	jmp ec
nec2:
	
	add si,2
	dec ax
	cmp ax,0
	jne lcf
	
ec:
	pop si
	pop dx
	pop cx
	pop bx
	
	pop bp
	ret
endp		CHECK_COLLISION
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		SAVE_SHAPE
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	push si
	
	
	mov si,offset SHAPE
	mov ax,4
lpss:
	mov bl,[si+1]
	;add bl,bl
	add bx,offset ARR
	mov cl,[si]
	sub cx,[BORDER_START]
	mov dx,1
	shl dx,cl
	or [bx],dx
	
	
	add si,2
	dec ax
	cmp ax,0
	jne lpss
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret

endp		SAVE_SHAPE
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		CHECK_ARR
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	push si
	
	mov si,offset ARR
	xor ax,ax
	xor bx,bx
	mov cx,20
	
lc:
	mov al,[si]
	xor ah,ah
	mov dl,1h
lc2:
	mov bl,al
	and bl,dl
	cmp bl,0
	je bn0
	
	mov bl,ah
	add bx, 0ah
	push bx		;x
	
	mov bx,cx
	neg bx
	add bx,20
	push bx		;y
	push 10		;color
	call PLACE_SQUARE
	
	jmp out_check_l
bn0:
	mov bl,ah
	add bx, 0ah
	push bx		;x
	
	mov bx,cx
	neg bx
	add bx,20
	push bx		;y
	push 0		;color
	call PLACE_SQUARE
out_check_l:
	add ah,1
	shl dl,1
	cmp ah,8
	jne lc2
	
	
	inc si
	dec cx
	cmp cx,0
	jne lc
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret

endp		CHECK_ARR
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		WAIT_													;get: time (ms)
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	push si
	
	mov al,[bp+2]
	mov ah,2ch
	int 21h
	xor bx,bx
	mov bl,dl
lw:
w:
	call CHECK_KEYS
	cmp cx,1
	je exw
	mov ah,2ch
	int 21h
	cmp bl,dl
	je w
	
	mov bl,dl
	dec al
	cmp al,0
	jne lw
	
exw:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret 2

endp		WAIT_
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		CHECK_KEYS											;out - on cx, if s clicked
	mov bp, sp
	push bp
	
	push ax
	push bx
	push dx
	push si
	
	mov ah,01h
	int 16h
	jz nb
	mov ah,00h
	int 16h
	
	cmp al,'a'
	je a
	cmp al,'d'
	je d
	cmp al,'s'
	je s
	cmp al,1bh  ;escape
	je ex
	jmp nb
a:
	call COPY_SHAPE
	push 3
	call DROP_FAKE
	call CHECK_COLLISION
	cmp ax,1
	je nb
	call UPDATE_SHAPE
	mov cx,0
	jmp nb
d:
	call COPY_SHAPE
	push 2
	call DROP_FAKE
	call CHECK_COLLISION
	cmp ax,1
	je nb
	call UPDATE_SHAPE
	mov cx,0
	jmp nb
s:
	mov cx,1
	jmp nb
ex:
	mov ax, 4c00h
	int 21h
	jmp nb
nb:
	pop si
	pop dx
	pop bx
	pop ax
	
	pop bp
	ret

endp		CHECK_KEYS
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		RANDOM_SHAPE													
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	push si
	mov bx,offset SHAPE
re:
	mov ah,2ch		;get time for random number
	int 21h
	mov ax,dx
	mov [COLOR],ax
	add [COLOR],100
	and ax,1111b
	;mov ax,1
	
stright_1:
	cmp ax,0
	jne stright_2
	mov [word bx], 000ch
	mov [word bx+2], 000dh
	mov [word bx+4], 000eh
	mov [word bx+6], 000fh
	jmp er
stright_2:
	cmp ax,1
	jne square
	mov [word bx], 000eh
	mov [word bx+2], 010eh
	mov [word bx+4], 020eh
	mov [word bx+6], 030eh
	jmp er
square:
	cmp ax,2
	jne tsahpe_1
	mov [word bx], 000dh
	mov [word bx+2], 000eh
	mov [word bx+4], 010dh
	mov [word bx+6], 010eh
	jmp er
tsahpe_1:
	cmp ax,3
	jne tsahpe_2
	mov [word bx], 000dh
	mov [word bx+2], 000eh
	mov [word bx+4], 000fh
	mov [word bx+6], 010eh
	jmp er
tsahpe_2:
	cmp ax,4
	jne tsahpe_3
	mov [word bx], 010dh
	mov [word bx+2], 010eh
	mov [word bx+4], 010fh
	mov [word bx+6], 000eh
	jmp er
tsahpe_3:
	cmp ax,5
	jne tsahpe_4
	mov [word bx], 000eh
	mov [word bx+2], 010eh
	mov [word bx+4], 010dh
	mov [word bx+6], 020eh
	jmp er
tsahpe_4:
	cmp ax,6
	jne lshape_right_1
	mov [word bx], 000eh
	mov [word bx+2], 010eh
	mov [word bx+4], 010fh
	mov [word bx+6], 020eh
	jmp er
lshape_right_1:
	cmp ax,7
	jne lshape_right_2
	mov [word bx], 000dh
	mov [word bx+2], 000eh
	mov [word bx+4], 000fh
	mov [word bx+6], 010fh
	jmp er
lshape_right_2:
	cmp ax,8
	jne lshape_right_3
	mov [word bx], 000dh
	mov [word bx+2], 010dh
	mov [word bx+4], 010eh
	mov [word bx+6], 010fh
	jmp er
lshape_right_3:
	cmp ax,9
	jne lshape_right_4
	mov [word bx], 000eh
	mov [word bx+2], 000fh
	mov [word bx+4], 010eh
	mov [word bx+6], 020eh
	jmp er
lshape_right_4:
	cmp ax,10
	jne lshape_left_1
	mov [word bx], 000eh
	mov [word bx+2], 010eh
	mov [word bx+4], 020eh
	mov [word bx+6], 020dh
	jmp er
lshape_left_1:
	cmp ax,11
	jne lshape_left_2
	mov [word bx], 000dh
	mov [word bx+2], 000eh
	mov [word bx+4], 000fh
	mov [word bx+6], 010dh
	jmp er
lshape_left_2:
	cmp ax,12
	jne lshape_left_3
	mov [word bx], 000fh
	mov [word bx+2], 010dh
	mov [word bx+4], 010eh
	mov [word bx+6], 010fh
	jmp er
lshape_left_3:
	cmp ax,13
	jne lshape_left_4
	mov [word bx], 000eh
	mov [word bx+2], 010eh
	mov [word bx+4], 020eh
	mov [word bx+6], 020fh
	jmp er
lshape_left_4:
	cmp ax,14
	jne weird_left_1
	mov [word bx], 000dh
	mov [word bx+2], 000eh
	mov [word bx+4], 010eh
	mov [word bx+6], 010fh
	jmp er
weird_right_1:
	cmp ax,15
	jne weird_right_2
	mov [word bx], 000dh
	mov [word bx+2], 000eh
	mov [word bx+4], 000fh
	mov [word bx+6], 010dh
	jmp er
weird_right_2:
	cmp ax,16
	jne weird_left_1
	mov [word bx], 000eh
	mov [word bx+2], 010dh
	mov [word bx+4], 010eh
	mov [word bx+6], 020dh
	jmp er
weird_left_1:
	cmp ax,17
	jne weird_left_2
	mov [word bx], 000eh
	mov [word bx+2], 000fh
	mov [word bx+4], 010dh
	mov [word bx+6], 010eh
	jmp er
weird_left_2:
	cmp ax,18
	jne re1
	mov [word bx], 000eh
	mov [word bx+2], 010eh
	mov [word bx+4], 010fh
	mov [word bx+6], 020fh
	jmp er
re1:
	jmp re
er:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret

endp		RANDOM_SHAPE
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		COPY_SHAPE
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	push si
	
	mov si, offset SHAPE
	mov bx, offset HIDDEN_SHAPE
	mov cx,4
l_coppy_shape:
	mov ax,[si]
	mov [bx],ax

	add si,2
	add bx,2
	dec cx
	cmp cx,0
	jne l_coppy_shape
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret
endp		COPY_SHAPE
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		DROP_FAKE				;get - 1:down,2:right,3:left
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	push si
	
	mov cx,4
	mov si,offset HIDDEN_SHAPE
l_drop_fake:
	cmp [word bp+2],1
	je downf
	cmp [word bp+2],2
	je rightf
	cmp [word bp+2],3
	je leftf
	jmp exf
downf:
	add [word si],0100h	;add 1 to y
	jmp exf
rightf:
	add [word si],0001h	;add 1 to x
	jmp exf
leftf:
	sub [word si],0001h	;sub 1 to x
	jmp exf
exf:
	add si,2
	dec cx
	cmp cx,0
	jne l_drop_fake
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret 2
endp		DROP_FAKE
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		UPDATE_SHAPE
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	push si
	
	mov si, offset HIDDEN_SHAPE
	mov bx, offset SHAPE
	add si,6
	add bx,6
	mov cx,4
	xor dx,dx
	
l_update_shape_clear:
	mov ax,[bx]
	mov dl,ah
	xor ah,ah
	
	push ax
	push dx
	push 0
	call PLACE_SQUARE
	sub si,2
	sub bx,2
	dec cx
	cmp cx,0
	jne l_update_shape_clear
	
	mov si, offset HIDDEN_SHAPE
	mov bx, offset SHAPE
	add si,6
	add bx,6
	mov cx,4
l_update_shape:
	mov ax,[si]
	mov [bx],ax
	
	xor dx,dx
	
	mov dl,ah
	xor ah,ah

	push ax
	push dx
	push [COLOR]
	call PLACE_SQUARE
	
	sub si,2
	sub bx,2
	dec cx
	cmp cx,0
	jne l_update_shape
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret
endp		UPDATE_SHAPE
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		CHECK_CEILING										
	mov bp, sp													;ret - in ax true:1 false:0
	push bp
	
	push bx
	push cx
	push dx
	push si
	
	mov ax,[SHAPE]
	cmp ah,0
	je ceiling_colision
	mov ax,0
	jmp check_ceiling_ex
ceiling_colision:
	mov ax,1
check_ceiling_ex:
	pop si
	pop dx
	pop cx
	pop bx
	
	pop bp
	ret
endp		CHECK_CEILING
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		CHECK_FULL_ROWS										
	mov bp, sp													;ret -in FULL_ROWS: 1 for full rows, 0 for not full rows
	push bp	
	
	push ax
	push bx
	push cx
	push dx
	push si
	
	mov bx,offset ARR
	mov si,offset FULL_ROW
	mov cx,20
check_full_rows_l:
	cmp [byte bx],-1
	jne not_full
	inc [SCORE]
	mov [byte si],1
not_full:
	inc si
	inc bx
	dec cx
	cmp cx,0
	jne check_full_rows_l
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret
endp		CHECK_FULL_ROWS
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		CLEAR_FULL_ROWS										
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	push si
	
	mov bx,offset ARR
	add bx, 20
	mov si,offset FULL_ROW
	add si,20
	
	mov cx,20
	mov di,0		;counter in negative
clear_full_rows_l:
	
	cmp [byte bx+1],-1
	jne clear_not_full
	mov [byte si], 0
	inc di
clear_not_full:
	mov ax,[bx]
	mov [bx+di],ax
	;cmp di,0
	;je not_prev_full
	;mov [byte bx],0
not_prev_full:
	
	dec si
	dec bx
	dec cx
	cmp cx,0
	jne clear_full_rows_l
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret
endp		CLEAR_FULL_ROWS
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		UPDATE_SCORE										
	mov bp, sp													
	push bp
	
	push ax
	push bx
	push cx
	push dx
	push si
	
	mov cx,2
update_l:
	mov dx,8h			;print backspace
	mov ah,2
	int 21h
	
	mov dx,20h			;print space
	mov ah,2
	int 21h
	
	mov dx,8h			;print backspace
	mov ah,2
	int 21h
	
	dec cx
	cmp cx,0
	jne update_l
	
	;mov dx,[SCORE]		;print score
	;add dx,'0'
	;mov ah,2
	;int 21h
	mov ax,[SCORE]
	call PRINT_NUMBER
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret
endp		UPDATE_SCORE
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc PRINT_NUMBER
	push ax
	push bx
	push dx
	mov bx,offset DIVISOR_TABLE
nextDigit:
	xor ah,ah
	div [byte ptr bx] ;al = quotient, ah = remainder
	add al,'0'
	call PRINT_CHARACTER ;Display the quotient
	mov al,ah ;al = ah = remainder
	add bx,1 ;bx = address of next divisor
	cmp [byte ptr bx],0 ;Have all divisors been done?
	jne nextDigit
	pop dx
	pop bx	
	pop ax
	ret
endp PRINT_NUMBER
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc PRINT_CHARACTER
	push ax
	push dx
	mov ah,2
	mov dl, al
	int 21h
	pop dx
	pop ax
	ret
endp PRINT_CHARACTER
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
start:
	mov ax, @data
	mov ds, ax
	
	
	
	mov ah,0			;chage to graphic mode
	mov al, 13h
	int 10h
	
	mov dx, offset SCCORE_TEXT
	mov ah, 9h
	int 21h
	
	mov cx,19
main_l1:
	mov ax, [BORDER_START]
	dec ax
	push ax
	push cx
	push 1
	call PLACE_SQUARE
	dec cx
	cmp cx,-1
	jne main_l1
	
	mov cx,19
main_l2:
	mov ax, [BORDER_START]
	add ax,9
	dec ax
	push ax
	push cx
	push 1
	call PLACE_SQUARE
	dec cx
	cmp cx,-1
	jne main_l2
	
	call RANDOM_SHAPE
l2:
	call RANDOM_SHAPE
	call SPAWN_SHAPE
l:	
	push 4
	call WAIT_
	
	call COPY_SHAPE
	push 1
	call DROP_FAKE
	call CHECK_COLLISION
	cmp ax, 1
	je col
	call UPDATE_SHAPE
col:
	cmp ax,1
	jne l
	
	call SAVE_SHAPE
	call CHECK_CEILING
	cmp ax,1
	je exit
	call CHECK_FULL_ROWS
	call CLEAR_FULL_ROWS
	call CHECK_ARR
	call UPDATE_SCORE
	
	jmp l2
exit:
	mov ax, 4c00h
	int 21h
END start