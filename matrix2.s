.data
    O: .space 4
    N: .space 4
    op: .space 4
    v: .space 1048576
    j: .space 4
    k: .space 4 #total numere
    p: .space 4
    u: .space 4
    descriptor: .space 1
    dimensiune: .space 4
    index: .space 4
    cnt0: .space 4
    index_DEFRAG: .space 4
    copie_dim: .space 4
    row: .space 4
    formatScanf: .asciz "%d"
    formatPrintf: .asciz "%d: (%d, %d), (%d, %d)\n"
    formatPrintf_GET: .asciz "(%d, %d), (%d, %d)\n"
    formatPrintf_EROARE: .asciz "Operatie invalida!\n"

.text

ADD:
    pushl %ebx
    pushl %edi
    pushl %ebp
    mov %esp, %ebp
    
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
        mov $0, %edx
        lea v, %edi

    for_ADD:
        xor %ebx, %ebx
        mov (%edi, %edx, 1), %bl

        cmp k, %edx
        je ADD_limit
        
        cmp $0, %ebx
        je ADD_0

        inc %edx
        jmp for_ADD

        ADD_limit:
            movl $1024, %ecx
            movl %eax, copie_dim
            movl %edx, index
            xor %edx, %edx
            movl index, %eax
            div %ecx

            sub %edx, %ecx
        
            movl copie_dim, %eax

            cmp %eax, %ecx
            jb next_line
            
            movl index, %edx
            addl %edx, %eax

            for_limit:
                cmp %eax, %edx
                je continue_for_limit
        
                lea v, %edi
                mov descriptor, %bl
                mov %bl, (%edi, %edx, 1)

                inc %edx
                jmp for_limit
           
            continue_for_limit:
                movl %edx, k

                jmp exit_ADD   

        ADD_0:
            movl $0, cnt0

            movl $1024, %ecx
            movl %eax, copie_dim
            movl %edx, index
            xor %edx, %edx
            movl index, %eax
            div %ecx
                
            inc %eax
            mul %ecx
                
            movl %eax, row
            mov copie_dim, %eax
            mov index, %edx

            counter_0:
                cmp row, %edx
                je move_last
      
                xor %ebx, %ebx
                mov (%edi, %edx, 1), %bl                

                cmp $0, %ebx
                jne continue_ADD_0

                incl cnt0
                inc %edx
                jmp counter_0
            
            continue_ADD_0:
                xor %ecx, %ecx
                movl index, %edx
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
                cmp cnt0, %eax
                jb continue_ADD_0

                jmp for_ADD    
    
    next_line:
        movl %edx, %ecx
        movl index, %edx

        for_next:
            cmp $1024, %ecx
            je exit_next
            
            xor %ebx, %ebx
            mov %bl, (%edi, %edx, 1)

            inc %edx
            inc %ecx

            jmp for_next
        
        exit_next:
            mov %edx, k

            jmp for_ADD

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
        
        cmp k, %ecx
        je afisare_NULL

        inc %ecx
        mov (%edi, %ecx, 1), %al

        jmp for_GET
    
    continue_GET:
        movl %ecx, index
        movl %ecx, %eax
        xor %edx, %edx
        movl $1024, %ecx
        div %ecx
        movl %edx, p
        movl %eax, row
        movl index, %ecx
    
    afisare_GET:
        mov (%edi, %ecx, 1), %al
        mov 1(%edi, %ecx, 1), %bl

        cmp %eax, %ebx
        je equal_GET  

        movl %ecx, index
        mov %ecx, %eax
        xor %edx, %edx
        movl $1024, %ecx
        div %ecx
        movl %edx, u
        movl index, %ecx

        push %ecx
        pushl u
        pushl row
        pushl p
        pushl row
        push $formatPrintf_GET
        call printf
        add $20, %esp
        pop %ecx

        jmp exit_GET

        equal_GET:
            inc %ecx
            jmp afisare_GET
    
    afisare_NULL:

        pushl $0
        pushl $0
        pushl $0
        pushl $0 
        push $formatPrintf_GET
        call printf
        add $20, %esp

    exit_GET:
        pop %ebp
        pop %edi
        pop %ebx

        ret


.global main

main:
    movl $0, k

    pushl $O
    push $formatScanf
    call scanf
    add $8, %esp

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

        #cmp $3, %eax
        #je main_DELETE

        #cmp $4, %eax
        #je main_DEFRAGMENTATION

        #cmp $5, %eax
        #je main_CONCRETE
        
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
        cmp k, %ecx
        je exit_op

        xor %eax, %eax
        xor %ebx, %ebx
        mov (%edi, %ecx, 1), %al
        mov 1(%edi, %ecx, 1), %bl

        cmp %eax, %ebx
        je equal_ADD_main
        
        cmp $0, %eax
        je zero_ADD

        movl %ecx, index
        movl p, %eax
        xor %edx, %edx
        movl $1024, %ecx
        div %ecx
        movl %edx, p
        movl index, %ecx

        movl %ecx, index
        mov %ecx, %eax
        xor %edx, %edx
        movl $1024, %ecx
        div %ecx
        movl %edx, u
        movl %eax, row
        movl index, %ecx

        mov (%edi, %ecx, 1), %bl

        push %ecx
        push u
        push row
        push p
        push row
        push %ebx
        push $formatPrintf
        call printf
        add $24, %esp
        pop %ecx
    
        movl %ecx, index
        movl $1024, %ecx
        xor %edx, %edx
        movl index, %eax
        div %ecx
        
        movl index, %ecx

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

et_exit:
    mov $1, %eax
    xor %ebx, %ebx
    int $0x80
