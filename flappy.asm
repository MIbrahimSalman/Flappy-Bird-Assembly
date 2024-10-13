[org 0x0100]

    mov ax,0x0013
    int 0x10

    jmp start

    BackGround:
        mov ax,0xA000
        mov es,ax
        mov di,0

        loop1:
            mov al,0x67
            mov [es:di],al
            add di,1
            cmp di,42000
            jne loop1

        loop2:
            mov al,0x14
            mov [es:di],al
            add di,1
            cmp di,45200
            jne loop2

        loop3:
            mov al,0x02
            mov [es:di],al
            add di,1
            cmp di,64000
            jne loop3
        ret

    start:
        
        call BackGround

mov ax,0x4c00
int 0x21