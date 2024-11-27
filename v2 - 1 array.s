.data
    O: .space 4
    N: .space 4
    op: .space 4
    v: .space 1024
    i: .space 4
    j: .space 4
    p: .space 4
    u: .space 4
    descriptor: .space 4
    dimensiune: .space 4
    formatScanf: .asciz "%ld"
    formatPrintf: .asciz "%ld: (%ld, %ld)\n"
    formatPrintf_GET: .asciz "(%ld, %ld)\n"
    formatPrintf_EROARE: .asciz "Operatie invalida!\n"

.text

ADD:
    pushl %ebx
    pushl %edi
    pushl %ebp
    mov %esp, %ebp
    
    pushl $descriptor
    push $formatScanf
    call scanf
    add $8,%esp

    pushl $dimensiune
    push $formatScanf
    call scanf
    add $8, %esp

    xor %edx, %edx
    movl dimensiune, %eax
    movl $8, %ebx
    divl %ebx 

    cmp $0, %edx
    je not_inc
    
    inc %eax
    
    not_inc:
        mov $0, %edx
        lea v, %edi

    for_ADD:
        mov (%edi, %edx, 4), %ebx
        cmp $256, %ebx
        je ADD_256
        
        inc %edx
        jmp for_ADD

        ADD_256:
            movl i, %ecx
            addl %ecx, %eax

            for_256:
                cmp %eax, %ecx
                je continue_for_256
        
                lea v, %edi
                movl descriptor, %ebx
                movl %ebx, (%edi, %ecx, 4)

                inc %ecx
                jmp for_256
           
            continue_for_256:
                movl %ecx, i

                inc %ecx
                lea v, %edi
                movl $256, (%edi, %ecx, 4)
            
                jmp exit_ADD    
        

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
    lea v, %edi
    mov (%edi, %ecx, 4), %eax

    for_GET:
        cmp descriptor, %eax
        je continue_GET
        
        cmp $256, %eax
        je afisare_NULL

        inc %ecx
        mov (%edi, %ecx, 4), %eax

        jmp for_GET
    
    continue_GET:
        movl %ecx, p
    
    afisare_GET:
        mov (%edi, %ecx, 4), %eax
        mov 4(%edi, %ecx, 4), %ebx

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
        mov (%edi, %ecx, 4), %eax
        cmp descriptor, %eax
        jne not_equal_DELETE

        xor %eax, %eax
        mov %eax, (%edi, %ecx, 4)

        not_equal_DELETE:
            cmp $256, %eax
            je exit_DELETE
            
            inc %ecx
            jmp for_DELETE

    exit_DELETE:
        pop %ebp
        pop %edi
        pop %ebx

        ret
    
.global main

main:
    xor %ecx, %ecx
    lea v, %edi
    movl $256, (%edi, %ecx, 4)

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

        #cmp $4, %eax
        #je main_DEFRAGMENTATION
        
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
        
        mov (%edi, %ecx, 4), %eax
        mov 4(%edi, %ecx, 4), %ebx

        cmp %eax, %ebx
        je equal_ADD_main
        
        cmp $0, %eax
        je zero_ADD
        
        movl %ecx, u
        movl p, %eax
        mov (%edi, %ecx, 4), %ebx

        push %ecx
        push u
        push %eax
        push %ebx
        push $formatPrintf
        call printf
        add $16, %esp
        pop %ecx
    
        push %ecx
        pushl $0
        call fflush
        add $4, %esp
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
    
    xor %ecx, %ecx
    
    afisare_DELETE:
        cmp i, %ecx
        je exit_op
        
        mov (%edi, %ecx, 4), %eax
        mov 4(%edi, %ecx, 4), %ebx

        cmp %eax, %ebx
        je equal_DELETE_main
        
        cmp $0, %eax
        je zero_DELETE
        
        movl %ecx, u
        movl p, %eax
        mov (%edi, %ecx, 4), %ebx

        push %ecx
        push u
        push %eax
        push %ebx
        push $formatPrintf
        call printf
        add $16, %esp
        pop %ecx
    
        push %ecx
        pushl $0
        call fflush
        add $4, %esp
        pop %ecx
        
        zero_DELETE: 
            movl %ecx, p
            incl p

        equal_DELETE_main: 
            inc %ecx
            jmp afisare_DELETE

et_exit:
    mov $1, %eax
    xor %ebx, %ebx
    int $0x80
