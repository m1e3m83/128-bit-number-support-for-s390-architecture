.macro enter size
    stmg %r6, %r15, 48(%r15)
    lay %r15, -(160+\size)(%r15)
.endm

.macro leave size
    lay %r15, (160+\size)(%r15)
    lmg %r6, %r15, 48(%r15)
.endm

.macro ret
    br  %r14
.endm

.macro big_not r1, r2 
    xihf \r1, 0xffffffff
    xihf \r2, 0xffffffff
    xilf \r1, 0xffffffff
    xilf \r2, 0xffffffff
.endm   

.macro big_add dest_l, dest_h, src1_l, src1_h, src2_l, src2_h
    lgr \dest_l, \src1_l # Copy src1 into dest
    lgr \dest_h, \src1_h 
    algr \dest_l, \src2_l        
    alcgr \dest_h, \src2_h     
.endm

.data
.align 8


num_1019: .quad 10000000000000000000
dbg: .string "%lld\0"
char_format: .string "%c\0"
part_1_format: .string "%llu\0"
part_2_format: .string "%019llu\n\0"
one_part_format: .string "%llu\n\0"
one_part_format_2: .string "%llu\n\0"
negative_symbol: .string "-\0"
check_scan: .string "first part: %llu     second part: %llu \n\0"
input_string: .space 60
current_char: .space 1

.text
.align 8

.globl main

main:
    enter 0

    brasl %r14, scan_big_int
    lgr %r6, %r2
    lgr %r7, %r3

    brasl %r14, scan_big_int

    lgr %r4, %r6
    lgr %r5, %r7

    brasl %r14, multiply

    brasl %r14, print_big_int

    exit:
    leave 0
    xgr %r2, %r2
ret


scan_big_int: # output in %r2 & %r3
    enter 0
    lghi %r7, 0 # sing
    lghi %r8, 0
    larl %r9, input_string
    larl %r10, current_char

    larl %r3, current_char
    larl %r2, char_format
    brasl %r14, scanf
    llc %r2, 0(%r10)

    cgfi %r2, 45
    jne check_positive
    lghi %r7, 1
    j get_char

    check_positive:
    cgfi %r2, 43
    je get_char

    cgfi %r2, 10
    je exit_get_char
    agfi %r2, -48
    stc %r2, 0(%r8, %r9)
    agfi %r8, 1

    get_char:
        larl %r3, current_char
        larl %r2, char_format
        brasl %r14, scanf
        llc %r2, 0(%r10)
        cgfi %r2, 10
        je exit_get_char
        agfi %r2, -48
        stc %r2, 0(%r8, %r9)
        agfi %r8, 1
        j get_char
    exit_get_char:

    lgr %r2, %r8
    lgr %r3, %r9
    brasl %r14, get_first_long

    lgr %r10, %r2
    lgr %r11, %r3
    cgfi %r3, 0
    je end_scan

    lgr %r2, %r8
    lgr %r3, %r9
    brasl %r14, get_first_long
    lgr %r11, %r2

    end_scan:
    cgfi %r7, 0
    je return_num
    lghi %r7, 0
    lghi %r6, 1
    big_not %r10, %r11
    big_add %r3, %r2, %r10, %r11, %r6, %r7
    leave 0
    ret

    return_num:
    lgr %r3, %r10
    lgr %r2, %r11
    leave 0
    ret

get_first_long:
    enter 0

    lgr %r8, %r2
    lgr %r9, %r3

    xgr %r2, %r2  # first long
    lghi %r4, 2
    lghi %r10, 0  # bit counter
    lghi %r11, 0  # digit counter

    div:
        lr %r5, %r11

        digit_div:
            xr %r0, %r0
            llc %r1, 0(%r5, %r9)
            dr %r0, %r4
            stc %r1, 0(%r5, %r9)
            agfi %r5, 1
            cr %r5, %r8
            je exit_digit_div
            cgfi %r0, 0
            je digit_div
            llc %r1, 0(%r5, %r9)
            agfi %r1, 10
            stc %r1, 0(%r5, %r9)
            j digit_div

        exit_digit_div:
        llc %r5, 0(%r11, %r9)
        cgfi %r5, 0
        jne no_add_digit_counter
        agfi %r11, 1
        no_add_digit_counter:
        xgr %r3, %r3
        sllg %r3, %r0, 0(%r10)
        ogr %r2, %r3
        cr %r11, %r8
        je exit_div
        agfi %r10, 1
        cgfi %r10, 64
        jne div

    lghi %r3, 1
    leave 0
    ret

    exit_div:
    lghi %r3, 0 #end code
    leave 0
    ret

print_big_int:
    enter 0
    cgfi %r2, -1
    jh asolute_print
    lghi %r4, 0
    lghi %r5, 1
    big_not %r2, %r3
    big_add %r9, %r8, %r3, %r2, %r5, %r4
    larl %r2, negative_symbol
    brasl %r14, printf
    lgr %r3, %r9
    lgr %r2, %r8

    asolute_print:
    xgr %r5, %r5
    lgrl  %r5, num_1019    
    dlgr %r2, %r5

    cgfi %r3, 0
    je just_print_low_part
    lgr %r9, %r2

    larl %r2, part_1_format
    brasl %r14, printf

    lgr %r3, %r9
    larl %r2, part_2_format
    brasl %r14, printf
    leave 0
    ret

    just_print_low_part:
    lgr %r3, %r2
    larl %r2, one_part_format
    brasl %r14, printf
    leave 0
    ret



multiply: #input in R4:R5 and R2:R3 result in R2:R3
    enter 0
    lgr %r7, %r2
    lgr %r9, %r4
    mlgr %r6, %r5
    mlgr %r8, %r3

    mlgr %r2, %r5

    agr %r2, %r7
    agr %r2, %r9
    leave 0
ret

devide: #devidend in R2:R3 devisor in R4:R5
    enter 0



    leave 0
    ret