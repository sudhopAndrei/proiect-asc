.data
    O: .space 4
    N: .space 4
    op: .space 4
    v: .space 1024
    i: .space 4
    j: .space 4
    nr: .space 4
    descriptor: .space 4
    dimensiune: .space 4
    desc_arr: .space 256
    p_poz: .space 256
    u_poz: .space 256
    formatScanf: .asciz "%ld"
    formatPrintf_ADD: .asciz "%ld: (%ld, %ld)\n"
    formatPrintf_GET: .asciz "(%ld, %ld)\n"

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
    
    lea desc_arr, %edi
    movl nr, %ecx
    movl descriptor, %edx
    mov %edx, (%edi, %ecx, 4)

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
        movl i, %ecx
        addl %ecx, %eax

        lea p_poz, %edi
        movl nr, %edx
        mov %ecx, (%edi, %edx, 4)

    for_ADD:
        cmp %eax, %ecx
        je exit_ADD
        
        lea v, %edi
        movl descriptor, %ebx
        movl %ebx, (%edi, %ecx, 4)

        lea u_poz, %edi
        movl nr, %edx
        mov %ecx, (%edi, %edx, 4)

        inc %ecx
        jmp for_ADD

    exit_ADD:
        
        incl nr
        movl %ecx, i
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
    lea desc_arr, %edi
    mov (%edi, %ecx, 4), %eax

    for_GET:
        cmp descriptor, %eax
        je afisare_GET
        
        cmp $256, %eax
        je afisare_NULL

        inc %ecx
        mov (%edi, %ecx, 4), %eax

        jmp for_GET
    
    afisare_GET:
        lea p_poz, %edi
        mov (%edi, %ecx, 4), %eax

        lea u_poz, %edi
        mov (%edi, %ecx, 4), %ebx
        
        push %ebx
        push %eax
        push $formatPrintf_GET
        call printf
        add $12, %esp

        jmp exit_GET
    
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

        #cmp $3, %eax
        #je main_DELETE

        #cmp $4, %eax
        #je main_DEFRAGMENTATION

        cmp $4, %eax
        jg et_exit
        
        exit_op:
            incl j
            jmp for_main

main_ADD:
    pushl $N
    pushl $formatScanf
    call scanf
    add $8, %esp

    xor %ecx, %ecx
    movl $0, nr
    
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

    afisare_ADD:
        cmp nr, %ecx
        je limit_ADD
 
        lea desc_arr, %edi   #descriptor
        mov (%edi, %ecx, 4), %eax 

        lea p_poz, %edi   #capatul din stanga
        mov (%edi, %ecx, 4), %ebx

        lea u_poz, %edi   #capatul din dreapta
        mov (%edi, %ecx, 4), %edx
    
        push %ecx
        push %edx
        push %ebx
        push %eax
        push $formatPrintf_ADD
        call printf
        add $16, %esp
        pop %ecx
    
        push %ecx
        pushl $0
        call fflush
        add $4, %esp
        pop %ecx

        inc %ecx
        jmp afisare_ADD
    
    limit_ADD:
        movl nr, %ecx
        inc %ecx
        lea desc_arr, %edi
        movl $256, (%edi, %ecx, 4)
        
        jmp exit_op

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
