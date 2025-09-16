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

.macro big_shift_right dest_h, dest_l, src_h, src_l, num
    lghi \dest_l, 0
    ngr \dest_l, \dest_l
    lghi \dest_h, 64
    slfi \dest_h, \num
    srlg \dest_l, \dest_l, 0(\dest_h)
    ogr \dest_l, \src_h
    sllg \dest_l, \dest_l, 0(\dest_h)
    srlg \dest_h, \src_l, \num
    ogr \dest_l, \dest_h
    srlg \dest_h, \src_h, \num
.endm

.macro big_shift_left dest_h, dest_l, src_h, src_l, num
    lghi \dest_h, 0
    ngr \dest_h, \dest_h
    lghi \dest_l, 64
    slfi \dest_l, \num
    sllg \dest_h, \dest_h, 0(\dest_l)
    ogr \dest_h, \src_l
    srlg \dest_h, \dest_h, 0(\dest_l)
    sllg \dest_l, \src_h, 0(\num)
    ogr \dest_h, \dest_l
    sllg \dest_l, \src_l, 0(\num)
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
string_format: .string "%s\0"
char_format: .string "%c\0"
part_1_format: .string "%llu\0"
part_2_format: .string "%019llu\n\0"
one_part_format: .string "%llu\n\0"
one_part_format_2: .string "%llu\n\0"
one_part_format_3: .string "njgklnels %llu\n\0"
negative_symbol: .string "-\0"
negative_symbol_1: .string "-\0"
check_scan: .string "first part: %llu     second part: %llu \n\0"
error_1: .string "Please enter a valid operator \n\0"
error_2: .string "Please enter a valid operator (+ - * /)\n\0"
number_error: .string "Please enter a valid number\n\0"
input_string: .space 60
current_char: .space 1
op: .space 1000

.text
.align 8

.globl main

main:
enter 0
    while:
    brasl %r14, scan_big_int
    cgfi %r0, 1
    je exit
    lgr %r8, %r2
    lgr %r9, %r3

    brasl %r14, handel_op
    cgfi %r0, 1
    je exit
    lgr %r7, %r2

    brasl %r14, scan_big_int
    cgfi %r0, 1
    je exit

    lgr %r4, %r2
    lgr %r5, %r3
    lgr %r2, %r8
    lgr %r3, %r9
    basr %r14, %r7
    brasl %r14, print_big_int
    j while
exit:
leave 0
ret

handel_op:
    enter 0

    start_handel_op:
    larl %r2, string_format
    larl %r3, op
    brasl %r14, scanf
    lghi %r0, 0

    larl %r2, op
    brasl %r14, strlen
    cgfi %r2, 1
    jne print_op_error

    lghi %r0, 0
    larl %r8, op
    llc %r3, 0(%r8)
    cgfi %r3, 43
    jne check_sub
    larl %r2, add
    j exit_handel_op

    check_sub:
    cgfi %r3, 45
    jne check_mul
    larl %r2, sub
    j exit_handel_op

    check_mul:
    cgfi %r3, 42
    jne check_div
    larl %r2, mul
    j exit_handel_op

    check_div:
    cgfi %r3, 47
    jne check_q
    larl %r2, div
    j exit_handel_op

    check_q:
    cgfi %r3, 113
    jne print_op_error

    exit_code:
    lghi %r0, 1

    exit_handel_op:
    leave 0
    ret

    print_op_error:
    larl %r2, error_2
    brasl %r14, printf
    j start_handel_op

add:
    enter 0
    big_add %r3, %r2, %r3, %r2, %r5, %r4
    leave 0
    ret

sub:
    enter 0
    big_not %r4, %r5
    lghi %r1, 1
    lghi %r0, 0
    big_add %r5, %r4, %r5, %r4, %r1, %r0
    big_add %r3, %r2, %r3, %r2, %r5, %r4
    leave 0
    ret

mul:
    enter 0
    msgrkc %r6, %r2, %r5
    msgrkc %r7, %r4, %r3
    mlgr %r2, %r5
    agr %r2, %r6
    agr %r2, %r7
    leave 0
    ret

div:
    enter 0

    lgr %r12, %r2
    xgr %r12, %r4
    srlg %r12, %r12, 63

    lghi %r7, 0
    lghi %r8, 0
    lghi %r9, 1

    cgfi %r2, -1
    jh check_num_2
    big_not %r2, %r3
    big_add %r3, %r2, %r3, %r2, %r9, %r8

    check_num_2:
    cgfi %r4, -1
    jh end_check
    big_not %r4, %r5
    big_add %r5, %r4, %r5, %r4, %r9, %r8

    end_check:

    cgfi %r4, 0
    je check_low_part
    flogr %r10, %r4
    sllg %r8, %r9, 0(%r10)
    lgr %r9, %r10
    big_shift_left %r10, %r11, %r4, %r5, %r9
    j end_find_msb

    check_low_part:
    cgfi %r5, 0

    flogr %r10, %r5
    sllg %r7, %r9, 0(%r10)
    lgr %r9, %r10
    big_shift_left %r10, %r11, %r5, %r4, %r9
    agfi %r9, 64
    end_find_msb:

    lghi %r0, 0
    lghi %r1, 0

    div_while:
        cgfi %r9, 0
        jl exit_div_while
        clgr %r2, %r10
        jh div_sub
        jl continue_while
        clgr %r3, %r11
        jl continue_while

        div_sub:
        stmg %r0, %r1, 48(%r15)
        lay %r15, -(160)(%r15)

        lgr %r4, %r10
        lgr %r5, %r11
        brasl %r14, sub

        lay %r15, (160)(%r15)
        lmg %r0, %r1, 48(%r15)

        ogr %r0, %r7
        ogr %r1, %r8

        continue_while:
        big_shift_right %r4, %r5, %r7, %r8, 1
        lgr %r7, %r4
        lgr %r8, %r5
        big_shift_right %r4, %r5, %r10, %r11, 1
        lgr %r10, %r4
        lgr %r11, %r5
        agfi %r9, -1
        j div_while
    exit_div_while:

    cgfi %r12, 0
    je return_num
    big_not %r0, %r1
    lghi %r4, 0
    big_add %r1, %r0, %r1, %r0, %r12, %r4

    return_num_div:    
    lgr %r2, %r0
    lgr %r3, %r1
    leave 0
    ret

scan_big_int: # output in %r0 & %r1
    enter 0

    start_scan:
    lghi %r7, 0 # sing
    lghi %r8, 0
    larl %r9, input_string
    larl %r10, current_char
    lghi %r11, 1 # error flag

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
    je start_scan

    cgfi %r2, 32
    je start_scan

    cgfi %r2, 113
    je check_just_q

    agfi %r2, -48
    brasl %r14, is_bcd
    stc %r2, 0(%r8, %r9)
    agfi %r8, 1

    get_char:
        larl %r3, current_char
        larl %r2, char_format
        brasl %r14, scanf
        llc %r2, 0(%r10)
        cgfi %r2, 10
        je exit_get_char
        cgfi %r2, 32
        je exit_get_char
        agfi %r2, -48
        brasl %r14, is_bcd
        stc %r2, 0(%r8, %r9)
        agfi %r8, 1
        j get_char
    exit_get_char:

    cgfi %r8, 0
    je print_number_error

    cgfi %r11, 0
    je print_number_error

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
    lghi %r0, 0
    leave 0
    ret

    return_num:
    lghi %r0, 0
    lgr %r3, %r10
    lgr %r2, %r11
    leave 0
    ret

    check_just_q:
    larl %r3, current_char
    larl %r2, char_format
    brasl %r14, scanf
    llc %r2, 0(%r10)
    cgfi %r2, 10
    je exit_code
    cgfi %r2, 32
    je exit_code
    lghi %r11, 0
    j get_char

    print_number_error:
    larl %r2, number_error
    brasl %r14, printf
    j start_scan

is_bcd:
    cgfi %r2, 0
    jl not_bcd
    cgfi %r2, 10
    jl exit_check_bcd
    not_bcd:
    lghi %r11, 0
    exit_check_bcd:
    ret

get_first_long:
    enter 0

    lgr %r8, %r2
    lgr %r9, %r3

    xgr %r2, %r2  # first long
    lghi %r4, 2
    lghi %r10, 0  # bit counter
    lghi %r11, 0  # digit counter

    div_2:
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
        jne div_2

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
    larl %r2, negative_symbol_1
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
