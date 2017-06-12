        global scheduler, current_cell
        extern resume, end_co
        extern WorldLength,WorldWidth, num_of_cells
        extern cors
	extern num_of_gens, print_freq
	sys_write	equ 4
	stderr  	equ 2

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
        current_generation:     resd 1
        current_cell:           resd 1
        print_counter:          resd 1
        freq_counter:           resd 1
        optimized_num_of_cells: resd 1

section .data
align 16
        test_string:		        db "hello!",10
        test_string_size:		equ $ - test_string
        
section .text
align 16
scheduler:
        mov     dword ecx, [print_freq]         ; update ecx to the value of k
        mov     dword [freq_counter], ecx
        mov     dword ecx, [num_of_cells]
        add     ecx,2
        mov     dword [optimized_num_of_cells], ecx


.sched_func:
        mov     dword edx, [current_generation] ;
        inc     edx                             ; update the number of current_generation 
        mov     dword [current_generation], edx ;

        mov     dword [current_cell], 2               ; set first cell

        cmp     dword edx, [num_of_gens]        ; check if all generations has ended
        jle     .calculate_loop
        call    end_co
        
.calculate_loop:
        mov     dword ebx,[current_cell]        ; get current cell=co routine index
        call    resume                          ; call cell co routine
 

.print_check_before_update:
        mov     dword ecx, [freq_counter]
        dec     ecx
        mov     dword [freq_counter], ecx
        cmp     dword ecx, 0                    ; check if need to call printer
        jg      .continue_calculate_loop         ; if no need to call, loop to the begining
        
        push    ebx
        mov     ebx, 1                          ; printer = coroutine 1
        call    resume                          ; call printer after k cell routines
        pop     ebx
        mov     dword ecx,[print_freq]          ; reset the value of k
        mov     dword [freq_counter], ecx

.continue_calculate_loop:
        inc     ebx                             ; increase to next cell co routine
        mov     dword [current_cell], ebx       ; update next cell

        cmp     dword ebx,[optimized_num_of_cells]        ; check if there are more cells to claculate
        jl      .calculate_loop
        
        mov     dword [current_cell], 2         ; set first set

.update_loop:
        mov     dword ebx,[current_cell]        ; get current cell=co routine index
        call    resume                          ; call cell co routine

.print_check_update:
        mov     dword ecx, [freq_counter]
        dec     ecx
        mov     dword [freq_counter], ecx

        cmp     dword ecx, 0                    ; check if need to call printer
        jg      .continue_update_loop            ; if no need to call, loop to the begining
        
        push    ebx
        mov     ebx, 1                          ; printer = coroutine 1
        call    resume                          ; call printer after k cell routines
        pop     ebx
        mov     dword ecx,[print_freq]          ; reset the value of k
        mov     dword [freq_counter], ecx

.continue_update_loop:
        inc     ebx                             ; increase to next cell co routine
        mov     dword [current_cell], ebx       ; update next cell

        cmp     dword ebx,[optimized_num_of_cells]        ; check if there are more cells to claculate
        jl      .update_loop
        

.finish_generation:
        jmp     .sched_func