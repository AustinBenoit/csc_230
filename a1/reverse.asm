; reverse.asm
; CSC 230: Spring 2018
;
; Code provided for Assignment #1
;
; Mike Zastre (2018-Jan-21)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (b). In this and other
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
; Your task: To reverse the bits in the word IN1:IN2 and to store the
; result in OUT1:OUT2. For example, if the word stored in IN1:IN2 is
; 0xA174, then reversing the bits will yield the value 0x2E85 to be
; stored in OUT1:OUT2.

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
    ; These first lines store a word into IN1:IN2. You may
    ; change the value of the word as part of your coding and
    ; testing.
    ;
    ldi R16, 0xA1
    sts IN1, R16
    ldi R16, 0x74
    sts IN2, R16

.equ MASK = 0b00000001          ; Mask to get the last bit


.def working_byte = R17			;defines the register to hold the bit that will be used while shifting
.def mask_result = R18			; result of the mask  
.def shift_count = R19			;defines the register to count the number of shifts done on input
.def output_byte = R20




	; the loop takes the least significant byte of the input then puts then puts the least
	; significant bit of the input to the most significant bit and so on untill
	; all bits are reverses then outputs to the most significant byte of the outputword
	
	lds working_byte, IN2 ; loads the last part of the word to be reversed	

	ldi shift_count, 0x00 ;sets the number of times the loop will run 0-7 (8 times)
	ldi output_byte, 0x00 ;zeros the output byte "did not do this in my first iteration lesson 



SHIFTLOOP1: NOP

	MOV mask_result, working_byte	; copies the working byte to get the last bit
	
	andi mask_result, MASK  		; gets the last bit

	add output_byte, mask_result	; put the last bit into the output

	
	; test to see if 8 loops have been completed
	cpi shift_count, 7  ; set the loop value
	brge DONE1
	inc shift_count     ;increments the loop

	
	; by shifting in opposite directions the bits are swaped

	lsr working_byte 				; shifts the input bits right
	lsl output_byte					; shifts the output bits left
	
	rjmp SHIFTLOOP1	

DONE1: NOP

	sts OUT1, output_byte 

;*******************************************

	; Same as above loop but the most significant input to least significant output

	lds working_byte, IN1 ; loads the last part of the word to be reversed	

	ldi shift_count, 0x00 ;sets the number of times the loop will run 0-7 (8 times)
	ldi output_byte, 0x00 ;zeros the output byte 



SHIFTLOOP2: NOP

	MOV mask_result, working_byte	; copies the working byte to get the last bit
	
	andi mask_result, MASK  		; gets the last bit

	add output_byte, mask_result	; put the last bit into the output

	
	; test to see if 8 loops have been completed
	cpi shift_count, 7  ; set the loop value
	brge DONE2
	inc shift_count     ;increments the loop

	
	; by shifting in opposite directions the bits are swaped

	lsr working_byte 				; shifts the input bits right
	lsl output_byte					; shifts the output bits left
	
	rjmp SHIFTLOOP2	

DONE2: NOP

	sts OUT2, output_byte 


	lds R30, OUT1
	lds R31, OUT2  




; **** END OF "STUDENT CODE" SECTION ********** 



; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
stop:
    rjmp stop

    .dseg
    .org 0x200
IN1:	.byte 1
IN2:	.byte 1
OUT1:	.byte 1
OUT2:	.byte 1
; ==== END OF "DO NOT TOUCH" SECTION ==========
