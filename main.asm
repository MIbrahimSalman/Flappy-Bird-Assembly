section .text
[org 0x0100]

jmp start
%include "file.asm"

transparent_pallette db 0xFF

bg_filename db 'bg.bmp', 0
bg_handle dw 0

bird_filename db 'bird.bmp', 0
bird_handle dw 0

bird_row: dw 100
bird_column: dw 100

delay:
    push cx
    mov cx, 10
    .l1:
        push cx
        mov cx, 0xFFFF
        .l2:
            loop .l2
        pop cx
        loop .l1
    pop cx
    ret

drawBG:
    pusha

    ; Read the BMP header
    setCursor [bg_handle], 0, 54

    ; Read Pallete
    readfile [bg_handle], 256*4, buffer

    ; Load The Palette
    mov cx, 256;
    mov bx, 0;
    mov si, buffer
    .palleteLoop:
        push cx
        mov ax, 0x1010
        mov dh, [si+2]
        shr dh, 2
        mov ch, [si+1]
        shr ch, 2
        mov cl, [si+0]
        shr cl, 2
        int 0x10;
        pop cx
        add si, 4;
        inc bx;
        loop .palleteLoop

    
    mov ax, 0xA000
    mov es, ax
    mov cx, 200
    mov di, 64000-320
    .readScreen:
        push cx

        readfile [bg_handle], 320, buffer
        mov si, buffer
        mov cx, 320
        .readLine:
            mov al, [si]
            cmp al, [transparent_pallette]
            jz .dontPrint
            mov [es:di], al
            .dontPrint:
            inc di
            inc si
            loop .readLine

        pop cx
        sub di, 320+320
        loop .readScreen

    popa
    ret

drawBird:
    pusha

    setCursor [bird_handle], 0, 54+256*4
    mov ax, 0xA000
    mov es, ax
    mov cx, 40
    mov ax, [bird_row]
    mov bx, 320
    mul bx
    add ax, [bird_column]
    mov di, ax
    .readScreen:
        push cx

        readfile [bird_handle], 40, buffer
        mov si, buffer
        mov cx, 40
        .readLine:
            mov al, [si]
            cmp al, [transparent_pallette]
            jz .dontPrint
            mov [es:di], al
            .dontPrint:
            inc di
            inc si
            loop .readLine

        pop cx
        sub di, 320+40
        loop .readScreen

    popa
    ret

drawBackgroundInBirdPlace:
    pusha

    mov ax, 0xA000
    mov es, ax
    mov ax, [bird_row]
    mov bx, 320
    mul bx
    mov dx, 54+256*4 + 199*320
    sub dx, ax
    add dx, [bird_column]
    add ax, [bird_column]
    mov di, ax
    mov si, dx

    setCursor [bird_handle], 0, 54+256*4
    setCursor [bg_handle], 0, si
    mov cx, 40
    .readScreen:
        push cx

        readfile [bird_handle], 40, buffer
        readfile [bg_handle], 320, buffer+40
        mov si, buffer
        mov bx, buffer+40
        mov cx, 40
        .readLine:
            mov al, [si]
            cmp al, [transparent_pallette]
            je .dontPrint
            mov al, [bx]
            mov [es:di], al
            .dontPrint:
            inc di
            inc si
            inc bx
            loop .readLine

        pop cx
        sub di, 320+40
        loop .readScreen

    popa
    ret

oldisr: dd 0

kbisr:
    push ax
    in al, 0x60

    cmp al, 0xB9
    je .SpaceUP

    jmp .retWithoutChaining
    .continueNormal:
        pop ax
        jmp far [oldisr]
    .retWithoutChaining:
        mov al, 0x20
        out 0x20, al
        pop ax
        iret

    .SpaceUP:
        cmp word [bird_row], 50
        jl .retWithoutChaining
        call drawBackgroundInBirdPlace
        sub word [bird_row], 20
        call drawBird
        jmp .retWithoutChaining

start:
    xor ax, ax;
    int 0x16

    ; Set video mode to 13h (320x200, 256 colors)
    mov ax, 0x13
    int 0x10

    mov ax, 0;
    mov es, ax;
    ; SAVE PREVIOUS KBISR
    mov ax, [es:9*4]
    mov [oldisr], ax
    mov ax, [es:9*4+2];
    mov [oldisr+2], ax

    ; HOOK
    mov [es:9*4+2], cs
    mov word [es:9*4], kbisr

    openfile bird_filename
    mov [bird_handle], ax;
    openfile bg_filename
    mov [bg_handle], ax

    call drawBG
    .infLoop:
        call drawBackgroundInBirdPlace
        add word [bird_row], 5
        call drawBird
        cmp word [bird_row], 195
        jg .stopLoop
        call delay
        jmp .infLoop

    .stopLoop:
    closefile bird_handle
    closefile bg_handle

    ;UNHOOK
    mov ax, [oldisr]
    mov [es:9*4], ax
    mov ax, [oldisr+2];
    mov [es:9*4+2], ax

    xor ax, ax;
    int 0x16

    ; Exit the program
    mov ax, 0x4C00
    int 0x21

buffer: times 64000 db 0