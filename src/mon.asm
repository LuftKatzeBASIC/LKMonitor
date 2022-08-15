bits 16
cpu 8086
org 0x500


mov dx,[0x7e00]
mov [drive],dx

mov ax,0x03
int 0x10

cli
mov word [0x20*4], l
mov word [0x20*4+2], cs
sti

mov si,start
call print

l:
        mov al,[drive]
        call fhex
        mov ax,0x0e3a
        int 0x10
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
        cmp byte [si],'['
        je prvdrv
        cmp byte [si],']'
        je nxtdrv
	cmp byte [si],'?'
	je content
        cmp byte [si],'.'
        je string
        cmp word [si],0x646c
        je ld
        cmp word [si],0x7473
        je st
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

string:
        mov di,[address]
        mov si,cmd+1
.loop0:
        cmp word [si],0x6e2a
        jne .s1
        mov al,13
        mov [di],al
        inc di
        mov al,10
        mov [di],al
        inc di
        inc si
        inc si
        jmp .loop0
.s1:
        cmp word [si],0x2a2a
        jne .s2
        mov al,'*'
        mov [di],al
        inc di
        inc si
        inc si
        jmp .loop0
.s2:
        movsb
        cmp byte [si],0
        je .done
        jmp .loop0
.done:
        mov [address],di
        jmp l

hex:
	clc
	lodsb
        cmp al,'a'
        jl .n
        cmp al,'z'
        jg .n
        sub al,32
.n:
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
        cmp byte [si+1],0
        je .here
	call gethex
	call dx
	jmp l
.here:
        mov dx,[address]
        call dx
        jmp l
set:
	call gethex
	mov [address],dx
	mov si,endl
	call print
	jmp l
_dec:
        cmp byte [si+1],0
        je .sdec
        call gethex
        sub [address],dx
        jmp l
.sdec:
	dec word [address]
	jmp l

_inc:
        cmp byte [si+1],0
        je .sinc
        call gethex
        add [address],dx
        jmp l
.sinc:
	inc word [address]
	jmp l

prvdrv:
        cmp byte [si+1],0
        je .sdec
        call gethex
        sub [drive],dl
        jmp l
.sdec:
        dec word [drive]
        jmp l

nxtdrv:
        cmp byte [si+1],0
        je .sinc
        call gethex
        add [drive],dl
        jmp l
.sinc:
        inc word [drive]
        jmp l



content:
        cmp byte [si+1],0
        je .here
	call gethex
        jmp .ddd
.here:
        mov dx,[address]
.ddd:
        mov [_c_end],dx
        add word [_c_end],0x100
	mov si,dx
        push si
        mov si,numbln
        call print
        pop si
.loop0:
        mov ax,0x0100
        int 0x16
        cmp ax,0x2e03
        je _ctrlc
        mov ax,si
        mov al,ah
        call fhex
        mov ax,si
        call fhex
        mov ax,0x0e3a
        int 0x10
        mov cx,0x10
.loop1:
        lodsb
        call fhex
        loop .loop1
        mov cx,0x10
        sub si,0x10
        mov ax,0x0e20
        int 0x10
.loop2:
        lodsb
        cmp al,0x20
        jg .t2
        jmp .dot
.t2:
        cmp al,0x7f
        jg .dot
        jmp .k
.dot:
        mov al,'.'
.k:
        mov ah,0x0e
        int 0x10
        loop .loop2
        push si
        mov si,endl
        call print
        pop si
        cmp si,[_c_end]
        jle .loop0
        jmp l



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


ld:
        inc si
        call gethex
        call calc
        mov [RWOTS],dx
        mov byte [RWOTEC], 0x07
.try:
        cmp byte [RWOTEC], 0x00
        je l.nobyte
        dec byte [RWOTEC]
        xor ax,ax
        int 0x13
        mov ax,0x0201
        xor bx,bx
        mov es,bx
        mov bx,[address]
        mov cx,[RWOTS]
        mov dx,[drive]
        int 0x13
        jc .try
        jmp l


st:
        inc si
        call gethex
        call calc
        mov [RWOTS],dx
        mov byte [RWOTEC], 0x07
.try:
        cmp byte [RWOTEC], 0x00
        je l.nobyte
        dec byte [RWOTEC]
        xor ax,ax
        int 0x13
        mov ax,0x0301
        xor bx,bx
        mov es,bx
        mov bx,[address]
        mov cx,[RWOTS]
        mov dx,[drive]
        int 0x13
        jc .try
        jmp l

calc:
        add dx,0x04
        mov ax,dx
        xor dx,dx
.loop0:
        cmp ax,[DTS] 
        jl .done
        sub ax,[DTS]
        inc dh
.done:
        mov dl,al
        ret


_ctrlc:
        xor ax,ax
        int 0x16
        jmp l

DTS: dw 0x09
address: dw 0xF000

start:          db "LK-Monitor version 1.1",13,10,0
onlybyte:       db "?"
endl:           db 13,10,0
numbln: db "      0 1 2 3 4 5 6 7 8 9 A B C D E F     ASCII:",13,10,0
drive equ 0x0007
_c_end equ 0xF05

RWOTS equ 0xF03
RWOTEC equ 0xF01

times 1018-($-$$)db 0
times(4)	db '0'
cmd:
