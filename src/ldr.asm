org 0x7c00
cpu 8086
bits 16

mov [0x7e00],dx

.loop0:
	xor ax,ax
	int 0x13
	mov ax,0x0202
	xor bx,bx
	mov es,bx
	mov bx,0x500
	mov cx,0x0002
	mov dx,[0x7e00]
	int 0x13
	jc .loop0
jmp 0x500
times (510-($-$$)) db 0
dw 0xaa55
