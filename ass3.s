global _start
extern init_co, start_co, resume, current_cell
extern scheduler, printer, print_board
extern cell

global WorldLength, WorldWidth, cells_array, num_of_gens, print_freq, num_of_cells

sys_exit:       equ 1
sys_read: 		equ 3
sys_write:      equ 4
sys_open: 		equ 5
sys_close:		equ 6

stdin: 			equ 0
stdout:         equ 1
stderr:         equ 2

O_RDONLY: 		equ 0

newline: 		equ 10

%macro  dbg_print_char 0
        pushad
        mov     eax, sys_write
        mov     ebx, stderr
        mov 	ecx, char_buffer
        mov 	edx, 1
        int     80h
        popad
%endmacro

%macro  dbg_print_str 2
        pushad
        mov     eax, sys_write
        mov     ebx, stderr
        mov 	ecx, %1
        mov 	edx, %2
        int     80h
        popad
%endmacro

section .bss
align 16
		filename: 		resb 16*6
		WorldWidth:     resd 1
		WorldLength:    resd 1
		print_freq:     resd 1
		num_of_gens:    resd 1
		cells_array:    resd 100*100
		num_of_cells:	resd 1

		char_buffer: 	resb 1
		
section .data
align 16
        dbgmode:        db 0
        dbgmodemsg: 	db "running in debug mode", 10
        dbgmodesize:	equ $ - dbgmodemsg

section .text
align 16
_start:
        enter   0, 0

        mov     ecx, [ebp + 4]         	; ecx = argc
        mov     esi, [ebp + 12]         ; esi = argv
        cmp     ecx, 6
        jle      .nodebug
        ;;;;;;;;;;;;;;;;;;;;;;; COMPARE WITH '-d' OR NOT
        mov     byte [dbgmode], 1
        add     esi, 3
        dbg_print_str dbgmodemsg, dbgmodesize
.nodebug:
		mov 	edi, filename
		call 	strcpy			; first argument - file name
		inc 	esi
		call 	readinputfile

        call    atoi            ; second argument - length
        mov     dword [WorldLength], eax
        inc     esi
        call    atoi            ; third argument - width
        mov     dword [WorldWidth], eax
        inc     esi
        call    atoi			; forth argument - generation number
        mov     dword [num_of_gens], eax
        inc     esi
        call    atoi			; fifth argument - print frequency
        mov     dword [print_freq], eax

        xor     ebx, ebx        ; scheduler is co-routine 0
        mov     edx, scheduler
        call    init_co         ; initialize scheduler state

        inc     ebx             ; printer i co-routine 1
        mov     edx, printer
        call    init_co         ; initialize printer state

		push 	ebx
		call 	print_board
		pop 	ebx

		mov     ecx, [WorldLength]	;
        mov     eax, [WorldWidth]	;
        mul     ecx					;	board size = WorldWidth * WorldLength 
        mov 	ecx, eax			;
     	mov 	dword [num_of_cells], eax

.coroutineinitloop:
		inc 	ebx
		mov 	edx, cell_func
		call 	init_co
		loop 	.coroutineinitloop

        xor     ebx, ebx        ; starting co-routine = scheduler
        call    start_co        ; start co-routines
	
        ;; exit
        mov     eax, sys_exit
        xor     ebx, ebx
        int     80h

atoi:	; esi - source string representing a number in decimal
		; returns in eax - the number represented
        enter   0, 0
        push    ecx

        xor     eax, eax
        xor     edx, edx
.loop:
        movzx   ecx, byte [esi]	; get next character
        cmp     ecx, 0
        je      .end_loop
        imul 	eax, 10

        sub     ecx, 0x30
        add     eax, ecx
        inc     esi
        jmp     .loop

.end_loop:
		pop 	ecx
		leave
		ret

strcpy:
		enter	0, 0
		push 	eax
.loop:
		cmp 	byte [esi], 0
		je  	.end_loop
		mov 	byte al, [esi]
		mov 	byte [edi], al

		inc 	esi
		inc 	edi
		jmp .loop
		
.end_loop:
		mov 	byte [edi], 0
		pop 	eax
		leave
		ret


readinputfile:
		enter 	0, 0
		sub 	esp, 8

		mov 	eax, sys_open
		mov 	ebx, filename
		mov 	ecx, O_RDONLY
		mov 	edx, 0777
		int 	0x80
		mov 	dword [ebp - 4], eax	; save the fd
		mov 	dword [ebp - 8], 0		; zero a counter


.readbyte:
		mov 	eax, sys_read
		mov 	ebx, [ebp - 4]
		mov 	ecx, char_buffer
		mov 	edx, 1
		int 	0x80

		cmp 	eax, 0
		je  	.end
		cmp 	byte [char_buffer], 10
		je  	.readbyte

		mov 	ecx, [ebp - 8]
		cmp 	byte [char_buffer], 0x01 + 0x30
		jne 	.cont
		mov 	[cells_array + ecx*4], eax
.cont:
		inc 	ecx
		mov 	dword [ebp - 8], ecx
		jmp 	.readbyte

.end:
		mov 	eax, sys_close
		mov 	ebx, [ebp - 4]
		int 	0x80

		leave
		ret
		
cell_func:
		mov 	dword eax, [current_cell]
		sub 	eax, 2	; cell number
		push 	eax

		xor 	edx, edx
		div 	dword [WorldWidth]
		push 	edx		; modulo
		push 	eax		; div
		call 	cell	; calculate state
		add 	esp, 2*4;
		push 	eax		; save returned state
		
		xor 	ebx, ebx
		call 	resume
		
		pop 	eax		; retreive state
		pop 	ebx		; retreive cell number
		mov 	dword [cells_array + ebx*4], eax
		
		xor 	ebx,ebx
		call 	resume
		jmp 	cell_func