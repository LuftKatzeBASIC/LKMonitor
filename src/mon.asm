bits 16
cpu 8086
org 7c00h
     
cli
mov word [0x20*4], l
mov word [0x20*4+2], cs
sti

mov si,start
call print
l:
        mov ax,0x0e2a
        int 0x10
        mov si,cmd
        call readln
        cmp byte [si],0x00
        je l
        cmp byte [si],'r'
        je run
        cmp byte [si],'s'
        je set
.l0:
        cmp byte [si+2], 0
        jne .nobyte
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
        ;mov al,0xFF
        stc
.nr:
        cmp al,'0'
        jl .err
        sub al,'0'
        ret



readln:
        push si
        xor cx,cx
.m:
        xor ax,ax
        int 0x16
        cmp al,0x08
        je .back

        cmp al,0x0d
        je .enter
        cmp al,0x1b
        je .esc
        mov ah,0x0e
        int 0x10
        mov [si],al
        inc si
        inc cx
        jmp .m
.esc:
        call .back
        loop .esc
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
        pop si
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

run:
        inc si
        cmp byte [si],0x00
        je l.nobyte

                dec si
        mov byte [si],'0'
        inc si

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
        sub si,cx

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
        call dx
        jmp l
set:
        inc si
        cmp byte [si],0x00
        je l.nobyte
        dec si
        mov byte [si],'0'
        inc si
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
        mov [address],dx
        mov si,setaddress
        call print
        mov si,cmd
        inc si
        call print
        mov si,endl
        call print
        jmp l

address: dw 0x600


start: db "LK-MONITOR 0.13"
pa: db 13,10,"Address: 0x600",13,10,0
onlybyte: db "?",13,10,0
setaddress: db "Address: 0x",0
endl: db 13,10,0
times(504-($-$$)) db 0
times(6) db '0'
cmd:
dw 0xaa55
