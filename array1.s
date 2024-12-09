.data
    O: .space 4
    N: .space 4
    op: .space 4
    v: .space 1024
    i: .space 4
    j: .space 4
    p: .space 4
    u: .space 4
    descriptor: .space 1
    dimensiune: .space 4
    index0: .space 4
    cnt0: .space 4
    index_DEFRAG: .space 4
    formatScanf: .asciz "%d"
    formatPrintf: .asciz "%d: (%d, %d)\n"
    formatPrintf_GET: .asciz "(%d, %d)\n"
    formatPrintf_EROARE: .asciz "Operatie invalida!\n"
    formatPrintf_EROARE2: .asciz "Nu incape!\n"

.text

ADD:
    pushl %ebx
    pushl %edi
    pushl %ebp
    mov %esp, %ebp
    
    begin_ADD:

        push $descriptor
        push $formatScanf
        call scanf
        add $8,%esp

        pushl $dimensiune
        push $formatScanf
        call scanf
        add $8, %esp

        xor %edx, %edx
        movl dimensiune, %eax
        mov $8, %ebx
        div %ebx 

        cmp $0, %edx
        je not_inc
    
        inc %eax
    
    not_inc:
        mov $1024, %ecx
        subl i, %ecx
        cmp %ecx, %eax
        ja eroare

        mov $0, %edx
        lea v, %edi

    for_ADD:
        xor %ebx, %ebx
        mov (%edi, %edx, 1), %bl
        
        cmp i, %edx
        je ADD_limit
        
        cmp $0, %ebx
        je ADD_0

        inc %edx
        jmp for_ADD

        ADD_limit:
            movl i, %ecx
            addl %ecx, %eax

            for_limit:
                cmp %eax, %ecx
                je continue_for_limit
        
                lea v, %edi
                mov descriptor, %bl
                mov %bl, (%edi, %ecx, 1)

                inc %ecx
                jmp for_limit
           
            continue_for_limit:
                movl %ecx, i
            
                jmp exit_ADD   

        ADD_0:
            movl %edx, index0
            movl $0, cnt0
            counter_0:
                mov (%edi, %edx, 1), %bl
                                
                cmp i, %edx
                je move_last
                
                cmp $0, %ebx
                jne continue_ADD_0

                incl cnt0
                inc %edx
                jmp counter_0
            
            continue_ADD_0:
                cmp cnt0, %eax
                ja skip_space
                
                xor %ecx, %ecx
                movl index0, %edx
                lea v, %edi
                
                for_0:
                    cmp %eax, %ecx
                    je exit_ADD

                    mov descriptor, %bl
                    mov %bl, (%edi, %edx, 1)

                    inc %ecx
                    inc %edx
                    jmp for_0 
                
            move_last:
                movl index0, %edx

                movl i, %ecx
                sub cnt0, %ecx
                movl %ecx, i

                jmp for_ADD

            skip_space:
                movl index0, %edx
                addl cnt0, %edx
                jmp for_ADD  

    eroare:
        push %eax
        push %ecx
        push %edx
        push $formatPrintf_EROARE2
        call printf
        add $4, %esp
        pop %edx
        pop %ecx
        pop %eax
        
        jmp begin_ADD   

    exit_ADD:
        
        popl %ebp
        popl %edi
        popl %ebx
        
        ret

GET:
    push %ebx
    push %edi
    push %ebp
    mov %esp, %ebp

    push $descriptor
    push $formatScanf
    call scanf
    add $8, %esp

    xor %ecx, %ecx
    xor %eax, %eax
    lea v, %edi
    mov (%edi, %ecx, 1), %al

    for_GET:
        cmp descriptor, %eax
        je continue_GET
        
        cmp i, %ecx
        je afisare_NULL

        inc %ecx
        mov (%edi, %ecx, 1), %al

        jmp for_GET
    
    continue_GET:
        movl %ecx, p
    
    afisare_GET:
        mov (%edi, %ecx, 1), %al
        mov 1(%edi, %ecx, 1), %bl

        cmp %eax, %ebx
        je equal_GET  
        
        movl p, %eax
        movl %ecx, u

        push u
        push %eax
        push $formatPrintf_GET
        call printf
        add $12, %esp

        jmp exit_GET

        equal_GET:
            inc %ecx
            jmp afisare_GET
    
    afisare_NULL:
        xor %eax, %eax
        xor %ebx, %ebx
        
        push %eax
        push %ebx
        push $formatPrintf_GET
        call printf
        add $12, %esp

    exit_GET:
        pop %ebp
        pop %edi
        pop %ebx

        ret

DELETE:
    push %ebx
    push %edi
    push %ebp
    mov %esp, %ebp

    push $descriptor
    push $formatScanf
    call scanf
    add $8, %esp

    lea v, %edi
    xor %ecx, %ecx

    for_DELETE:
        xor %eax, %eax
        mov (%edi, %ecx, 1), %al
        cmp descriptor, %eax
        jne not_equal_DELETE

        xor %eax, %eax
        mov %al, (%edi, %ecx, 1)

        not_equal_DELETE:
            cmp i, %ecx
            je exit_DELETE
            
            inc %ecx
            jmp for_DELETE

    exit_DELETE:
        pop %ebp
        pop %edi
        pop %ebx

        ret
    
DEFRAGMENTATION:
    push %ebx
    push %edi
    push %ebp
    mov %esp, %ebp

    lea v, %edi
    xor %ecx, %ecx
    movl $0, index_DEFRAG

    for_DEFRAG:
        movl %ecx, index_DEFRAG
        cmp i, %ecx
        je exit_DEFRAG
        
        xor %eax, %eax
        mov (%edi, %ecx, 1), %al
        cmp $0, %eax
        jne continue_DEFRAG

        for_move:
            cmp i, %ecx
            je end_loop_DEFRAG

            mov 1(%edi, %ecx, 1), %al
            mov %al, (%edi, %ecx, 1)

            inc %ecx

            jmp for_move

        continue_DEFRAG:
            inc %ecx
            jmp for_DEFRAG

        end_loop_DEFRAG:
            decl i
            movl index_DEFRAG, %ecx
            jmp for_DEFRAG

    exit_DEFRAG:
        pop %ebp
        pop %edi
        pop %ebx

        ret


.global main

main:
    pushl $O
    push $formatScanf
    call scanf
    add $8, %esp
    
    movl $0, i
    movl $0, j

    for_main:
        movl j, %ecx
        cmp O, %ecx
        je et_exit
    
        pushl $op
        push $formatScanf
        call scanf
        add $8, %esp
        movl op, %eax

        cmp $1, %eax
        je main_ADD

        cmp $2, %eax
        je main_GET

        cmp $3, %eax
        je main_DELETE

        cmp $4, %eax
        je main_DEFRAGMENTATION
        
        push %ecx
        push $formatPrintf_EROARE
        call printf
        add $4, %esp
        pop %ecx
        jmp for_main
        
        exit_op:
            incl j
            jmp for_main

main_ADD:
    pushl $N
    pushl $formatScanf
    call scanf
    add $8, %esp

    xor %ecx, %ecx
    
    for_ADD_main: 
        cmp N, %ecx
        je continue_ADD_main
    
        push %ecx
        push %eax
        push %edx
        call ADD
        pop %edx
        pop %eax
        pop %ecx

        inc %ecx
        jmp for_ADD_main

    continue_ADD_main:
        xor %ecx, %ecx     
        lea v, %edi
        movl $0, p

    afisare_ADD:
        cmp i, %ecx
        je exit_op
        
        xor %eax, %eax
        xor %ebx, %ebx
        mov (%edi, %ecx, 1), %al
        mov 1(%edi, %ecx, 1), %bl

        cmp %eax, %ebx
        je equal_ADD_main
        
        cmp $0, %eax
        je zero_ADD
        
        movl %ecx, u
        movl p, %eax
        mov (%edi, %ecx, 1), %bl

        push %ecx
        push u
        push %eax
        push %ebx
        push $formatPrintf
        call printf
        add $16, %esp
        pop %ecx
    
        zero_ADD: 
            movl %ecx, p
            incl p

        equal_ADD_main: 
            inc %ecx
            jmp afisare_ADD


main_GET:
    push %ecx
    push %eax
    push %edx
    call GET
    pop %edx
    pop %eax
    pop %ecx

    jmp exit_op

main_DELETE:
    push %ecx
    push %eax
    push %edx
    call DELETE
    pop %edx
    pop %eax
    pop %ecx
    
    lea v, %edi
    xor %ecx, %ecx
    movl $0, p
    
    afisare_DELETE:
        cmp i, %ecx
        je exit_op
        
        xor %eax, %eax
        xor %ebx, %ebx
        mov (%edi, %ecx, 1), %al
        mov 1(%edi, %ecx, 1), %bl

        cmp %eax, %ebx
        je equal_DELETE_main
        
        cmp $0, %eax
        je zero_DELETE
        
        movl %ecx, u
        movl p, %eax
        mov (%edi, %ecx, 1), %bl

        push %ecx
        push u
        push %eax
        push %ebx
        push $formatPrintf
        call printf
        add $16, %esp
        pop %ecx
    
        zero_DELETE: 
            movl %ecx, p
            incl p

        equal_DELETE_main: 
            inc %ecx
            jmp afisare_DELETE

main_DEFRAGMENTATION:
    push %eax
    push %ecx
    push %edx
    call DEFRAGMENTATION
    pop %edx
    pop %ecx
    pop %eax
    
    xor %ecx, %ecx
    lea v, %edi
    movl $0, p

    afisare_DEFRAG:
        cmp i, %ecx
        je exit_op

        xor %eax, %eax
        xor %ebx, %ebx
        mov (%edi, %ecx, 1), %al
        mov 1(%edi, %ecx, 1), %bl
        
        cmp %eax, %ebx
        je equal_DEFRAG_main
        
        movl %ecx, u
        movl p, %eax
        mov (%edi, %ecx, 1), %bl

        push %ecx
        push u
        push %eax
        push %ebx
        push $formatPrintf
        call printf
        add $16, %esp
        pop %ecx

        movl %ecx, p
        incl p
        
        equal_DEFRAG_main:
            inc %ecx
            jmp afisare_DEFRAG

et_exit:
    mov $1, %eax
    xor %ebx, %ebx
    int $0x80
