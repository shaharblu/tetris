IDEAL
MODEL small
STACK 100h
DATASEG

SHAPE dw 4 dup (?)
ARR db 20 dup (00h)
COLOR dw ?

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
	pop dx
	pop ax
	
	pop bp
	ret
endp		SPAWN_SHAPE
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		DROP
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	
	mov cx,4
	mov bx,offset SHAPE
	add bx,7
lpd:
	xor ax,ax
	xor dx,dx
	
	mov dl,[bx]
	inc [byte bx]
	dec bx
	
	mov al,[bx]
	dec bx
	
	push ax
	push dx
	push 0
	call PLACE_SQUARE
	
	inc dx
	push ax
	push dx
	push [COLOR]
	call PLACE_SQUARE
	
	
	dec cx;
	cmp cx,0;
	jne lpd
	
	pop dx
	pop cx
	pop dx
	pop ax
	
	pop bp
	ret
endp		DROP
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		MOVE_RIGHT
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	
	mov cx,4
	mov bx,offset SHAPE
	add bx,7
lpdr:
	xor ax,ax
	xor dx,dx
	
	mov dl,[bx]
	dec bx
	
	mov al,[bx]
	inc [byte bx]
	dec bx
	
	push ax
	push dx
	push 0
	call PLACE_SQUARE
	
	inc ax
	push ax
	push dx
	push [COLOR]
	call PLACE_SQUARE
	
	
	dec cx;
	cmp cx,0;
	jne lpdr
	
	pop dx
	pop cx
	pop dx
	pop ax
	
	pop bp
	ret
endp		MOVE_RIGHT
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		MOVE_LEFT
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
	push dx
	
	mov cx,4
	mov bx,offset SHAPE
	;add bx,7
lpdl:
	xor ax,ax
	xor dx,dx
	
	mov al,[bx]
	dec [byte bx]
	inc bx
	
	mov dl,[bx]
	inc bx
	
	push ax
	push dx
	push 0
	call PLACE_SQUARE
	
	dec ax
	push ax
	push dx
	push [COLOR]
	call PLACE_SQUARE
	
	
	dec cx;
	cmp cx,0;
	jne lpdl
	
	pop dx
	pop cx
	pop dx
	pop ax
	
	pop bp
	ret
endp		MOVE_LEFT
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		CHECK_FLOOR										;ret - in ax true:1 false:0 
	mov bp, sp
	push bp
	
	push bx
	push cx
	push dx
	push si
	
	mov ax,4
	mov si,offset SHAPE
	xor cx,cx
	xor bx,bx
	
lcf:
	mov bl,[si+1]
	
	cmp bl,19
	jne nec
	mov ax,1
	jmp ec
nec:
	mov cl,[si]
	sub cl,0ah
	
	add bx,offset ARR
	mov dx,[bx+1]
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
	pop dx
	
	pop bp
	ret
endp		CHECK_FLOOR
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
	sub cx,0ah
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
	pop dx
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
	mov cx,20
lc:
	mov al,[si]
	inc si
	dec cx
	cmp cx,0
	jne lc
	
	pop si
	pop dx
	pop cx
	pop dx
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
	mov ah,2ch
	int 21h
	cmp bl,dl
	je w
	
	mov bl,dl
	dec al
	cmp al,0
	jne lw
	
	
	pop si
	pop dx
	pop cx
	pop dx
	pop ax
	
	pop bp
	ret 2

endp		WAIT_
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc		CHECK_KEYS													
	mov bp, sp
	push bp
	
	push ax
	push bx
	push cx
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
	cmp al,1bh  ;escape
	je ex
	jmp nb
a:
	call MOVE_LEFT
	jmp nb
d:
	call MOVE_RIGHT
	jmp nb
ex:
	mov ax, 4c00h
	int 21h
	jmp nb
nb:
	pop si
	pop dx
	pop cx
	pop dx
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
	mov ah,2ch
	int 21h
	mov ax,dx
	and ax,111b
	cmp ax,0
	je r0
	cmp ax,1
	je r1
	cmp ax,2
	je r2
	cmp ax,3
	je r3
	cmp ax,4
	je r4
	cmp ax,5
	je r5
	cmp ax,6
	je r6
	jmp re
r0:
	mov [word bx], 000dh
	mov [word bx+2], 000eh
	mov [word bx+4], 010dh
	mov [word bx+6], 010eh
	mov [COLOR], 10
	jmp er
r1:
	mov [word bx], 000dh
	mov [word bx+2], 000eh
	mov [word bx+4], 010eh
	mov [word bx+6], 010fh
	mov [COLOR], 20
	jmp er
r2:
	mov [word bx], 000dh
	mov [word bx+2], 000eh
	mov [word bx+4], 010ch
	mov [word bx+6], 010dh
	mov [COLOR], 30
	jmp er
r3:
	mov [word bx], 000eh
	mov [word bx+2], 010eh
	mov [word bx+4], 020eh
	mov [word bx+6], 030eh
	mov [COLOR], 40
	jmp er
r4:
	jmp r42
r5:
	jmp r52
r6:
	jmp r62
r42:
	mov [word bx], 000dh
	mov [word bx+2], 000eh
	mov [word bx+4], 000fh
	mov [word bx+6], 010eh
	mov [COLOR], 50
	jmp er
r52:
	mov [word bx], 000dh
	mov [word bx+2], 000eh
	mov [word bx+4], 000fh
	mov [word bx+6], 010dh
	mov [COLOR], 60
	jmp er
r62:
	mov [word bx], 000dh
	mov [word bx+2], 000eh
	mov [word bx+4], 000fh
	mov [word bx+6], 010fh
	mov [COLOR], 70
	jmp er
er:
	pop si
	pop dx
	pop cx
	pop dx
	pop ax
	
	pop bp
	ret

endp		RANDOM_SHAPE
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

start:
	mov ax, @data
	mov ds, ax
	
	mov ah,0
	mov al, 13h
	int 10h
	
	mov cx,6
	
l2:
	call RANDOM_SHAPE
	
	call SPAWN_SHAPE
l:	
	push 4
	call WAIT_
	
	call DROP
	call CHECK_FLOOR
	
	cmp ax,1
	jne l
	
	call SAVE_SHAPE
	call CHECK_ARR
	
	jmp l2

exit:
	mov ax, 4c00h
	int 21h
END start