; modulo.asm
; CSC 230: Spring 2018
;
; Code provided for Assignment #1
;
; Mike Zastre (2018-Jan-21)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (c). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: Compute the value of M % N, and store that value in memory
; location RESULT. You are to compute the value by repeated subtraction
; of N from M.
;
; To simply your solution, please make the following assumptions:
; (1) 0 < M <= 32767 (i.e., M is a positive 16-bit two's complement #)
; (2) 0 < N <= 127 (i.e., N is a positive 16-bit two's complement #).
;
; For example, 370 % 120 is 10. Given the constraints above, you are
; guaranteed the result of value of the modulo result can be stored as a
; byte (i.e., no need to store the result as a 16-bit two's complement
; number, rather instead store it as an 8-bit two's complement number).
; 
; Please see the assignment description for additional suggestions
; on implementing a solution.

    .cseg
    .org 0
    
    .def MH=r17
    .def ML=r16
    .def NH=r19
    .def NL=r18
; ==== END OF "DO NOT TOUCH" SECTION ==========

; Here are assembler directives for assigning values to M and N. Note,
; though, that you will instead want to work with MH, ML, NH and NL.
; You can change M and N as part of your working of coding and testing.
; Note there is a "DO NOT TOUCH" section below containing code that
; computes MH, ML, NH and NL based on the .equ values.
;
    .equ M=0x4255    ; this is decimal 16981
    .equ N=0x1d      ; this is decimal 29
                     ; M % N is 0x10 (decimal 16)

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
	ldi ML, (M & 0xff)
	ldi MH, ((M >> 8) & 0xff)
	ldi NL, (N & 0xff)
	ldi NH, ((N >> 8) & 0xff)
; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 


; The values in MH, ML, NH and NL may be overwritten by your
; code if this is necessary. 

; holds an intermediate copy of M
.def temp_low = r21
.def temp_high = r22

;zero the registers 
ldi temp_low, 0
ldi temp_high, 0
 


; the loop does a subtraction on the the low bytes then subtracts the high bytes
; (with a carry if needed). 
; loop then checks to see if the high byte has a carry flag set, if the flag is set then
; the subtraction has underflowed if it has underflowed then the last subtaction had the Mod 
; the loop hold a copy of the last subtraction in the temp register that is then copied to the 
; result 


not_set: nop

	sub ML,NL
	sbc MH,NH

	brcs is_set 

; Keeps the value of the current subtraction to be used when the subraction underflows
	mov temp_high, MH
	mov temp_low, ML


	rjmp not_set

is_set: nop


	sts RESULT, temp_low


; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
stop:
	rjmp stop


.dseg
.org 0x200
RESULT: .byte 1
; ==== END OF "DO NOT TOUCH" SECTION ==========
