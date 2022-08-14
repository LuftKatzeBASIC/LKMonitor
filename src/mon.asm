bits 16
cpu 8086
org 0x500

mov ax,0x03
int 0x10

cli
mov word [0x20*4], l
mov word [0x20*4+2], cs
sti

mov si,start
call print
l:
        mov ax,[address]
        mov al,ah
        call fhex
        mov ax,[address]
        call fhex
	mov ax,0x0e2a
	int 0x10
	mov si,cmd
	call readln
        mov si,cmd
	cmp byte [si],0x00
	je l
	cmp byte [si],'#'
	je run
	cmp byte [si],'='
	je set
	cmp byte [si],'<'
	je _dec
	cmp byte [si],'>'
	je _inc
	cmp byte [si],'?'
	je _content
.l0:
	call hex
	jc .nobyte
	mov cl,al
	mov al,16
	mul cl
	mov dh,al
	call hex
	jc .nobyte
	add dh,al
	mov bx,[address]
	mov [bx],dh
	inc word [address]
	cmp byte [si],0
	je l
	cmp byte [si+1],0
	jne .l1
	dec si
	mov byte [si],'0'
.l1:
	call .l0
	jmp l
.nobyte:
	mov si, onlybyte
	call print
	jmp l

hex:
	clc
	lodsb
	cmp al,0x00
	je .r
	cmp al,'G'
	jge .err
	cmp al,'9'
	jle .nr
	cmp al,0x0a
	jc .r
	sub al,0x07
	and al,0x0f

.r:
	ret
.err:
	stc
	ret
.nr:
	cmp al,'0'
	jl .err
	sub al,'0'
	ret



readln:
	xor cx,cx
.m:
	xor ax,ax
	int 0x16
	cmp al,0x08
	je .back
        cmp ah,0x0e
        je .back
	cmp al,0x0d
	je .enter
        cmp al,'a'
        jl .n
        cmp al,'z'
        jg .n
        sub al,32
.n:
	mov ah,0x0e
	int 0x10
	mov [si],al
        inc si
	inc cx
	jmp .m
.back:
	cmp cx,0x00
	je .m
	dec cx
	dec si
	mov ax,0x0e08
	int 0x10
	mov ax,0x0e20
	int 0x10
	mov ax,0x0e08
	int 0x10
	jmp .m
.enter:
	mov ax,0x0e0d
	int 0x10
	mov ax,0x0e0a
	int 0x10
	mov byte [si],0
	ret

print:
	mov al,[si]
	cmp al,0
	je .done
	mov ah,0x0e
	int 0x10
	inc si
	jmp print
.done:
	ret

gethex:
	mov byte [si],'0'
	inc si
	cmp byte [si],0x00
	je l.nobyte
	push si
	xor cx,cx
.loop0:
	lodsb
	cmp al,0
	je .done
	inc cx
	jmp .loop0
.done:
	pop si
	mov ax,4
	sub ax,cx
	sub si,ax

	call hex
	jc l.nobyte
	mov cl,al
	mov al,16
	mul cl
	mov dh,al
	call hex
	jc l.nobyte
	add dh,al
	call hex
	jc l.nobyte
	mov cl,al
	mov al,16
	mul cl
	mov dl,al
	call hex
	jc l.nobyte
	add dl,al
	ret

run:
	call gethex
	call dx
	jmp l
set:
	call gethex
	mov [address],dx
	mov si,endl
	call print
	jmp l
_dec:
	dec word [address]
	jmp l

_inc:
	inc word [address]
	jmp l

_content:
	call gethex
	mov si,dx
        push si
        mov si,numbln
        call print
        pop si
        mov cx,0x300
.loop0:
        mov ax,si
        mov al,ah
        call fhex
        mov ax,si
        call fhex
        mov ax,0x0e3a
        int 0x10
        push cx
        mov cx,0x0f
.loop1:
        lodsb
        call fhex
        loop .loop1
        mov cx,0x0f
        sub si,0x0f
        mov ax,0x0e20
        int 0x10
.loop2:
        lodsb
        cmp al,0x7e
        jg .dot
        cmp al,0x20
        jg .putc
.dot:
        mov al,'.'
.putc:
        mov ah,0x0e
        int 0x10
        loop .loop2
        push si
        mov si,endl
        call print
        pop si
        pop cx
        cmp cx,0x0a
        jl l
        sub cx,0x0a
        loop .loop0

fhex:
        push cx
        call .hex
        pop cx
        ret
.hex:
        mov     ah,al
        push    cx
        mov     cl,0x04
        shr     al,cl
        pop     cx
        call    .d
        mov     al,ah
.d:
        and     al,0x0f
        add     al,0x90
        daa
        adc     al,0x40
        daa
        push ax
        mov ah,0x0e
        int 0x10
        pop ax
        ret

address: dw 0xFF00

start:          db "LK-Monitor version 0.44",13,10
                db "Occupied space: 0x500-0x900",13,10
                db "Command buffer: 0x910",13,10,10,0
onlybyte:       db "?"
endl:           db 13,10,0
numbln: db "      1 2 3 4 5 6 7 8 9 A B C D E F",13,10,0
times 1022-($-$$)db 0
times(2)	db '0'
cmd equ $+0x10
