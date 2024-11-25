.data
    N: .space 4
    v: .space 1024
    i: .space 4
    nr: .space 4
    descriptor: .space 4
    dimensiune: .space 4
    desc_arr: .space 256
    p_poz: .space 256
    u_poz: .space 256
    formatScanf: .asciz "%ld"
    formatPrintf_ADD: .asciz "%ld: (%ld, %ld)\n"

.text

ADD:
    pushl %ebx
    pushl %edi
    pushl %esp
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
        je exit
        
        lea v, %edi
        movl descriptor, %ebx
        movl %ebx, (%edi, %ecx, 4)

        lea u_poz, %edi
        movl nr, %edx
        mov %ecx, (%edi, %edx, 4)

        inc %ecx
        jmp for_ADD

    exit:
        
        incl nr
        movl %ecx, i
        popl %esp
        popl %edi
        popl %ebx
        
        ret
    
.global main

main:
    pushl $N
    pushl $formatScanf
    call scanf
    add $8, %esp

    xor %ecx, %ecx
    movl $0, i
    movl $0, nr
for: 
    cmp N, %ecx
    je continue
    
    push %ecx
    push %eax
    push %edx
    call ADD
    pop %edx
    pop %eax
    pop %ecx

    inc %ecx
    jmp for

continue:
    xor %ecx, %ecx   

afisare_ADD:
    cmp nr, %ecx
    je et_exit
 
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

et_exit:
    mov $1, %eax
    xor %ebx, %ebx
    int $0x80
