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
    index0: .space 4
    cnt0: .space 4
    index_DEFRAG: .space 4
    copie_dim: .space 4
    rowend: .space 4
    total: .space 4
    formatScanf: .asciz "%d"
    formatPrintf: .asciz "%d:(%d, %d), (%d, %d)\n"
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
            movl %edx, index0
            movl $0, cnt0

            movl $1024, %ecx
            movl %eax, copie_dim
            movl %edx, index
            xor %edx, %edx
            movl index, %eax
            div %ecx
                
            inc %eax
            mul %ecx
                
            movl %eax, rowend
            mov copie_dim, %eax
            mov index, %edx

            counter_0:
                cmp rowend, %edx
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

        #cmp $2, %eax
        #je main_GET

        #cmp $3, %eax
        #je main_DELETE

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
        je bridge_ADD
    
        push %ecx
        push %eax
        push %edx
        call ADD
        pop %edx
        pop %eax
        pop %ecx

        inc %ecx
        jmp for_ADD_main
    
    bridge_ADD:
        movl k, %edx
        movl %edx, total

    continue_ADD_main:
        movl $0, rowend
        xor %ecx, %ecx     
        lea v, %edi
        movl $0, p

    afisare_ADD:
        cmp k, %ecx
        je restore_ADD

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
        push rowend
        push %eax
        push rowend
        push %ebx
        push $formatPrintf
        call printf
        add $16, %esp
        pop %ecx
    
        movl %ecx, index
        movl $1024, %ecx
        xor %edx, %edx
        movl index, %eax
        div %ecx
        
        movl index, %ecx

        cmp $0, %edx
        je newrow

        zero_ADD: 
            movl %ecx, p
            incl p

        equal_ADD_main: 
            inc %ecx
            jmp afisare_ADD

        newrow:
            incl rowend
            subl $1024, k

            jmp continue_ADD_main
        
        restore_ADD:
            movl total, %edx
            movl %edx, k

et_exit:
    mov $1, %eax
    xor %ebx, %ebx
    int $0x80
