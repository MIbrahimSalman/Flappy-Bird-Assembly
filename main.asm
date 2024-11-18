%define PILLAR_WIDTH 32
%define PILLAR_HEIGHT 128
%define PILLAR_COUNT 3
%define STARTING_ROW 320-22
%define PILLAR_STEP 10
%define PILLAR_GAP 320/3
%define VERTICAL_PILLAR_GAP 60

%define BIRD_HEIGHT 30
%define BIRD_WIDTH 24

; %define BIRD_HEIGHT 40
; %define BIRD_WIDTH 40

section .text
[org 0x0100]

jmp start
%include "file.asm"

transparent_pallette db 0xFF

bg_filename db 'bgg.bmp', 0
bg_handle dw 0

bird_filename db 'bird2.bmp', 0
bird_handle dw 0

pillar_filename db 'pillar.bmp', 0
pillar_handle dw 0

down_pillar_filename db 'pillad.bmp', 0
down_pillar_handle dw 0

bird_row: dw 100
bird_column: dw 100

pillar_columns: dw -1, -1, STARTING_ROW
pillar_heights: dw 50, 70, 64

spacePressed: db 0

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
    mov ax, [bird_row]
    mov bx, 320
    mul bx
    add ax, [bird_column]
    mov di, ax
    mov cx, BIRD_HEIGHT
    .readScreen:
        push cx

        readfile [bird_handle], BIRD_WIDTH, buffer
        mov si, buffer
        mov cx, BIRD_WIDTH
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
        sub di, 320+BIRD_WIDTH
        loop .readScreen

    popa
    ret

; BP+4 => Pillar Row
; BP+6 => Pillar Column
; BP+8 => Pillar Height
drawUpPillar:
    push bp
    mov bp, sp
    pusha

    mov ax, PILLAR_HEIGHT
    sub ax, [BP+8]
    mov bx, PILLAR_WIDTH
    mul bx
    add ax, 54+256*4
    adc ax, 0

    setCursor [pillar_handle], dx, ax
    mov ax, 0xA000
    mov es, ax
    mov ax, [BP+4]
    mov bx, 320
    mul bx
    add ax, [BP+6]
    mov di, ax
    mov cx, [BP+8]
    .readScreen:
        push cx

        readfile [pillar_handle], PILLAR_WIDTH, buffer
        mov si, buffer
        mov cx, PILLAR_WIDTH
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
        sub di, 320+PILLAR_WIDTH
        loop .readScreen

    popa
    mov sp, bp
    pop bp
    ret 6


; BP+4 => Pillar Column
; BP+6 => Pillar Height
drawDownPillar:
    push bp
    mov bp, sp
    pusha

    setCursor [down_pillar_handle], 0, 54+256*4
    mov ax, 0xA000
    mov es, ax
    mov ax, [BP+6]
    mov bx, 320
    mul bx
    add ax, [BP+4]
    mov di, ax
    mov cx, [BP+6]
    .readScreen:
        push cx

        readfile [down_pillar_handle], PILLAR_WIDTH, buffer
        mov si, buffer
        mov cx, PILLAR_WIDTH
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
        sub di, 320+PILLAR_WIDTH
        loop .readScreen

    popa
    mov sp, bp
    pop bp
    ret 4

; BP+4 => Pillar Column
; BP+6 => Pillar Height
drawBackgroundInDownPillarPlace:
    push bp
    mov bp, sp
    pusha

    setCursor [down_pillar_handle], 0, 54+256*4

    mov ax, 0xA000
    mov es, ax
    mov ax, [BP+6]
    mov bx, 320
    mul bx
    mov dx, 54+256*4 + 199*320
    sub dx, ax
    add dx, [BP+4]
    add ax, [BP+4]
    mov di, ax
    mov si, dx

    setCursor [bg_handle], 0, si
    mov cx, [BP+6]
    .readScreen:
        push cx

        readfile [down_pillar_handle], PILLAR_WIDTH, buffer
        readfile [bg_handle], 320, buffer+PILLAR_WIDTH
        mov si, buffer
        mov bx, buffer+PILLAR_WIDTH
        mov cx, PILLAR_WIDTH
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
        sub di, 320+PILLAR_WIDTH
        loop .readScreen

    popa
    mov sp, bp
    pop bp
    ret 4

; BP+4 => Pillar Row
; BP+6 => Pillar Column
; BP+8 => Pillar Height
drawBackgroundInUpPillarPlace:
    push bp
    mov bp, sp
    pusha

    mov ax, PILLAR_HEIGHT
    sub ax, [BP+8]
    mov bx, PILLAR_WIDTH
    mul bx
    add ax, 54+256*4
    adc ax, 0

    setCursor [pillar_handle], dx, ax

    mov ax, 0xA000
    mov es, ax
    mov ax, [BP+4]
    mov bx, 320
    mul bx
    mov dx, 54+256*4 + 199*320
    sub dx, ax
    add dx, [BP+6]
    add ax, [BP+6]
    mov di, ax
    mov si, dx

    setCursor [bg_handle], 0, si
    mov cx, [BP+8]
    .readScreen:
        push cx

        readfile [pillar_handle], PILLAR_WIDTH, buffer
        readfile [bg_handle], 320, buffer+PILLAR_WIDTH
        mov si, buffer
        mov bx, buffer+PILLAR_WIDTH
        mov cx, PILLAR_WIDTH
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
        sub di, 320+PILLAR_WIDTH
        loop .readScreen

    popa
    mov sp, bp
    pop bp
    ret 6

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
    mov cx, BIRD_HEIGHT
    .readScreen:
        push cx

        readfile [bird_handle], BIRD_WIDTH, buffer
        readfile [bg_handle], 320, buffer+BIRD_WIDTH
        mov si, buffer
        mov bx, buffer+BIRD_WIDTH
        mov cx, BIRD_WIDTH
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
        sub di, 320+BIRD_WIDTH
        loop .readScreen

    popa
    ret

oldisr: dd 0

kbisr:
    pusha
    in al, 0x60

    cmp al, 0xB9
    je .SpaceUP

    jmp .retWithoutChaining
    .continueNormal:
        popa
        jmp far [oldisr]
    .retWithoutChaining:
        mov al, 0x20
        out 0x20, al
        popa
        iret

    .SpaceUP:
        mov byte [spacePressed], 1
        jmp .retWithoutChaining

movePillars:
    pusha
    mov cx, PILLAR_COUNT
    mov bx, PILLAR_COUNT*2
    .movePillar:
        sub bx, 2

        cmp word [pillar_columns+bx], -1
        je .skipPillar

        push word [pillar_heights+bx]
        push word [pillar_columns+bx]
        push 182
        call drawBackgroundInUpPillarPlace

        mov ax, [pillar_heights+bx]
        add ax, VERTICAL_PILLAR_GAP
        sub ax, 182
        neg ax
        push word ax
        push word [pillar_columns+bx]
        call drawBackgroundInDownPillarPlace

        sub word [pillar_columns+bx], PILLAR_STEP
        cmp word [pillar_columns+bx], 0
        jge .dontReset
            mov word [pillar_columns+bx], STARTING_ROW-PILLAR_STEP
        .dontReset:

        push word [pillar_heights+bx]
        push word [pillar_columns+bx]
        push 182
        call drawUpPillar

        mov ax, [pillar_heights+bx]
        add ax, VERTICAL_PILLAR_GAP
        sub ax, 182
        neg ax
        push word ax
        push word [pillar_columns+bx]
        call drawDownPillar

        cmp word [pillar_columns+bx], STARTING_ROW-PILLAR_GAP-PILLAR_STEP
        jg .skipPillar
        cmp bx, 0
        je .skipPillar
        cmp word [pillar_columns+bx-2], -1
        jne .skipPillar
        mov word [pillar_columns+bx-2], STARTING_ROW-PILLAR_STEP
        .skipPillar:
        loop .movePillar
    popa
    ret

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
    openfile pillar_filename
    mov [pillar_handle], ax
    openfile down_pillar_filename
    mov [down_pillar_handle], ax

    call drawBG

    .infLoop:
        call drawBackgroundInBirdPlace
        cmp byte [spacePressed], 0
        je .dontMoveUp
            mov byte [spacePressed], 0
            cmp word [bird_row], 65
            jl .dontMoveUp
            sub word [bird_row], 25
        .dontMoveUp:
        add word [bird_row], 5
        call drawBird
        cmp word [bird_row], 182
        jge .stopLoop
        call movePillars
        call delay
        jmp .infLoop

    .stopLoop:
    closefile bird_handle
    closefile bg_handle
    closefile pillar_handle
    closefile down_pillar_handle

    ;UNHOOK
    mov ax, 0;
    mov es, ax;
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