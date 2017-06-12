global printer, print_board
extern resume
extern WorldWidth, WorldLength, cells_array

sys_write:      equ 4
stdout:         equ 1
stderr:         equ 2
newline: 		equ 10
space: 			equ 32
        
%macro  print_char 0
        pushad
        mov     eax, sys_write
        mov     ebx, stdout
        mov 	ecx, char_buffer
        mov 	edx, 1
        int     80h
        popad
%endmacro

%macro  dbg_print_char 0
        pushad
        mov     eax, sys_write
        mov     ebx, stderr
        mov 	ecx, char_buffer
        mov 	edx, 1
        int     80h
        popad
%endmacro

section .bss
char_buffer: 	resb 1

section .data

section .text

printer:
		call 	print_board
		xor 	ebx, ebx
		call 	resume
		jmp 	printer

print_board:
        mov     ecx,0
        
.external_loop:
        cmp     dword ecx,[WorldLength]
        jge     .finish_external_loop
        
        mov     edx,0
        
.inner_loop:
        cmp     dword edx,[WorldWidth]
        jge     .finish_inner_loop
        push    edx
        mov     dword eax,[WorldWidth]
        mul     ecx
        pop     edx
        add     eax,edx
        mov 	dword ebx, [cells_array + eax*4]
        add 	ebx, 0x30		; convert to ascii
        mov 	byte [char_buffer], bl
        print_char
        mov 	byte [char_buffer], space
        print_char
        inc     edx
        jmp     .inner_loop
        
.finish_inner_loop:
        mov 	byte [char_buffer], newline
        print_char
        inc     ecx
        jmp     .external_loop
        
.finish_external_loop:
        ;xor ebx, ebx
        ;call resume             ; resume scheduler
		
        ;jmp printer
        ret