.data
    N: .space 4
    v: .space 1024
    i: .space 4
    descriptor: .space 4
    dimensiune: .space 4
    formatScanf: .asciz "%d"
    formatPrintf: .asciz "%d "
    endline: .asciz "\n"

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

    pushl $dimensiune
    push $formatScanf
    call scanf
    add $8, %esp

    xor %edx, %edx
    movl dimensiune, %eax
    movl $8, %ebx
    divl %ebx 
    inc %eax
    
    lea v, %edi
    movl i, %ecx
    addl %ecx, %eax

    for_ADD:
        cmp %eax, %ecx
        je exit
        
        movl descriptor, %ebx
        movl %ebx, (%edi, %ecx, 4)

        inc %ecx
        jmp for_ADD

    exit:

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
for: 
    cmp N, %ecx
    je continue

    push %eax
    push %ecx
    push %edx
    call ADD
    pop %edx
    pop %ecx
    pop %eax

    inc %ecx
    jmp for

continue:
    lea v, %edi
    xor %ecx, %ecx   

afisare_ADD:
    cmp i, %ecx
    je endline_ADD

    mov (%edi, %ecx, 4), %eax
    push %ecx
    push %eax
    push $formatPrintf
    call printf
    add $4, %esp
    pop %eax
    pop %ecx
    
    push %ecx
    pushl $0
    call fflush
    add $4, %esp
    pop %ecx

    inc %ecx
    jmp afisare_ADD

endline_ADD:
    mov $4, %eax
    mov $1, %ebx
    mov $endline, %ecx
    mov $2, %edx
    int $0x80

et_exit:
    mov $1, %eax
    xor %ebx, %ebx
    int $0x80
