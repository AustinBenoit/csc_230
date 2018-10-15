; parity.asm
; CSC 230: Spring 2018
;
; Code provided for Assignment #1
;
; Mike Zastre (2018-Jan-21)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (a). In this and other
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
; Your task: To compute the value of the parity bit (or "check" bit)
; that for R16 needed for even parity. For example, if R16 is equal to
; 0b10100010, then it has three set bits, and the parity is 1 (i.e., the
; parity bit would be set). As another example, if R16 is equal to
; 0b01010110, then it has four set bits, and the parity is 0 (i.e., the
; parity bit would be cleared). In our code, simply store the correct
; value of 0 or 1 in PARITY.
;
; Your solution must count bits by using masks, bit shifts, arithmetic
; operations, logical operations, and loops.  You are *not* to construct
; lookup tables (i.e., you are not to precompute an array such value
; 0xA2 has 1 stored with it, value 0x56 has 0 stored with it, etc).
;
; In your solution you are free to modify the original value stored
; in R16.

    .cseg
    .org 0
; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION  ****

.equ MASK_FOR_LAST_BIT = 0b00000001 


.def input = R17  				;defines the register to be used for the input byte 
								;copies the input to retain a copy of the origonal value

.def parity_count = R18 		;defines the register that will count the set bits
.def shift_count = R19			;defines the register to count the number of shifts done on input
.def mask_result = R20  		;defines the register to hold the result of the mask
.def result = R21				;defines the register that will hold the even or odd value 1 for odd, 0 of even

	;Zero registers
	ldi input, 0x00
	ldi parity_count, 0x00
	ldi shift_count, 0x00


    ; You may change the number stored in R16
	ldi R16, 0b11111110

	;copy to input
	MOV input, R16

	;begining of loop that will check which bits have been set
	;uses a mask to check the last bit then adds the value to the parity count 
	;then shifts the bits once to the left to check if the next bit is set and so on until 
	;all eight bits have been checked and the respective values have been added to the parity count

	ldi shift_count, 0x00 ;sets the number of times the loop will run 0-7 (8 times)

;test of loop with count down


SHIFTLOOP: NOP



	ldi mask_result, MASK_FOR_LAST_BIT ; reload the mask
	and mask_result, input 			   ; checks bit in least significant position
	add parity_count, mask_result	   ; add the reult to the parity count
	lsr input						   ; shifts input to the right for next reading bit


	inc shift_count     ;increments the loop
	cpi shift_count, 8  ; set the loop value
	brlt SHIFTLOOP


; after loop parity count now hold the number of bits that were set in the input bit 
; yah binary already tells me if it is even or odd after counting so mask it out and store to var.

	ldi mask_result, MASK_FOR_LAST_BIT
	and parity_count, mask_result

	sts PARITY, parity_count




; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
stop:
    rjmp stop

    .dseg
    .org 0x202
PARITY: .byte 1  ; result of computing parity-bit value for even parity
; ==== END OF "DO NOT TOUCH" SECTION ==========
