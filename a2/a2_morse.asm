
; a2_morse.asm
; CSC 230: Spring 2018
;
; Student name: Austin Benoit
; Student ID: 
; Date of completed work:
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2018-Feb-10)
; 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are 
; "DO NOT TOUCH" sections. You are *not* to modify the lines
; within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; I have added for this assignment an additional kind of section
; called "TOUCH CAREFULLY". The intention here is that one or two
; constants can be changed in such a section -- this will be needed
; as you try to test your code on different messages.
;


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

.include "m2560def.inc"

.cseg
.equ S_DDRB=0x24
.equ S_PORTB=0x25
.equ S_DDRL=0x10A
.equ S_PORTL=0x10B

	
.org 0
	; Copy test encoding (of SOS) into SRAM
	;
	ldi ZH, high(TESTBUFFER)
	ldi ZL, low(TESTBUFFER)
	ldi r16, 0x30
	st Z+, r16
	ldi r16, 0x37
	st Z+, r16
	ldi r16, 0x30
	st Z+, r16
	clr r16
	st Z, r16

	; initialize run-time stack
	ldi r17, high(0x21ff)
	ldi r16, low(0x21ff)
	out SPH, r17
	out SPL, r16

	; initialize LED ports to output
	ldi r17, 0xff
	sts S_DDRB, r17
	sts S_DDRL, r17

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION **** 
; ***************************************************

	; If you're not yet ready to execute the
	; encoding and flashing, then leave the
	; rjmp in below. Otherwise delete it or
	; comment it out.

;	rjmp stop

    ; The following seven lines are only for testing of your
    ; code in part B. When you are confident that your part B
    ; is working, you can then delete these seven lines. 


 



;	ldi r17, high(TESTBUFFER)
;	ldi r16, low(TESTBUFFER)
;	push r17
;	push r16
;	rcall flash_message
;   pop r16
;   pop r17
	

;	ldi r16,'Z'
;	push r16
;	rcall letter_to_code
;	pop r16
	  
; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION ********** 
; ***************************************************


; ################################################
; #### BEGINNING OF "TOUCH CAREFULLY" SECTION ####
; ################################################

; The only things you can change in this section is
; the message (i.e., MESSAGE01 or MESSAGE02 or MESSAGE03,
; etc., up to MESSAGE09).
;

	; encode a message
	;
	ldi r17, high(MESSAGE07 << 1)
	ldi r16, low(MESSAGE07 << 1)
	push r17
	push r16
	ldi r17, high(BUFFER01)
	ldi r16, low(BUFFER01)
	push r17
	push r16
	rcall encode_message
	pop r16
	pop r16
	pop r16
	pop r16

; ##########################################
; #### END OF "TOUCH CAREFULLY" SECTION ####
; ##########################################


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
	; display the message three times
	;
	ldi r18, 3
main_loop:
	ldi r17, high(BUFFER01)
	ldi r16, low(BUFFER01)
	push r17
	push r16
	rcall flash_message
	dec r18
	tst r18
	brne main_loop


stop:
	rjmp stop
; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================


; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION **** 
; ****************************************************

; Some .def's about how I am going to use registers 
.def input = r16

.def higher = r17
.def lower = r25
.def temp = r19
.def count = r20

;
.def comparison_number = r21
.def sequence = r22
.def count2 = r23
.def temp2 = r24


;********** START OF FLASH MESSAGE *************

; reads the message off of SRAM and passes the encoded bit sequence on r16 
; to morse_flash

flash_message:
; store any values that may be in the used registers
.equ FLASH_OFF_SET = 5

	push YH
	push YL
	push r16
	push XL
	push XH
	
	ldi r16, 0

; where am I on the stack? 
	in YH, SPH 
	in YL, SPL 

; the address I want is 4 and 5 away
; put found address in X
	ldd XL, Y + 4 + FLASH_OFF_SET
	ldd	XH, Y + 5 + FLASH_OFF_SET

; get data from sram then loops till 0x00
; then puts the value 
data_fetch:
	ld r16, X+
	cpi r16, 0x00
	breq done
	
	push XH
	push XL


	rcall morse_flash	


	pop XL
	pop XH
	rjmp data_fetch

done:
;this call a long delay to sperate the words
	ldi r16, 0xff
	rcall morse_flash

	pop XH
	pop XL
	pop r16
	pop YL
	pop YH
	
	ret
;********** END OF FLASH MESSAGE ***************


;********** START OF MORSE FLASH ***************
; Takes a bit sequence from r16 and turns on and off the
; leds as required

morse_flash:
; this tests to see if the long delay is needed, 
		cpi input,0xff
		brne not_long_delay
		rcall delay_long
		rcall delay_long
		rcall delay_long
	ret

; the portion of the code here parse the binary input
; into two registers one that has the number of dashes/dots
; and another has a sequence of dashes or dots 
not_long_delay:
; zero out the registers
		ldi comparison_number, 0
		ldi count2, 0
		ldi sequence,0

; get the sequence of dashes and dots
		mov sequence, input
		andi sequence, 0b00001111

; gets the number of dashes and dots
		swap input
		mov comparison_number, input
		andi comparison_number, 0b00001111

; check to see if the number of dashes and dots is empty
		cpi comparison_number, 0
		breq finished_flash


; the code below ensure that the right dash or dot is read 
; this is achived by moving the bit sequence over to account for 
; sequences that are shorter than 4


; move the sequence over to ensure I have the right bit in the right place	
        ldi temp, 4
		sub temp, comparison_number 

sequence_loop:
		
		cpi temp, 0
		breq begin_flash

		lsl sequence
		dec temp
		rjmp sequence_loop


; This reads if the bit is a dash or a dot and calls 
begin_flash:		

; temp is used to get last bit of the sequence and see if it is a one or a zero
; sequence is them shifted right to get ready for the next loop
		mov temp2, sequence
		andi temp2, 0b00001000
		lsl sequence
		inc count2

; check to see if long flash with the mask above this comparison value is needed
		cpi temp2, 0b00001000
		breq long_flash
; short flash
		ldi input, 6
		rcall leds_on
		rcall delay_short
		rcall leds_off
		rcall delay_long
; check to see if done flashing the letter
		cp count2, comparison_number
		brge finished_flash
		rjmp begin_flash

long_flash:
		ldi input, 6

		rcall leds_on
		rcall delay_long
		rcall leds_off
		rcall delay_long
; check to see if done flashing the letter
		cp count2, comparison_number
		brge finished_flash
		rjmp begin_flash
	
finished_flash:
	ret

;********** END OF MORSE FLASH *****************


;********** START OF LEDS ON *******************
leds_on:
; two loops first loop turns on the first two leds
;2nd loop turn on the other 4 leds

; temp is used to hold the value so the first two leds can be turned on
; temp is created to use cpse
		ldi temp, 2	
		; zero out leds and counter
		ldi count, 0
		ldi lower, 0
		ldi higher, 0
		;turns off all leds
		sts S_PORTB, lower
		sts S_PORTL, higher
loop1:
		cp input, count
		breq finished
		
		lsl higher
		lsl higher
		ori higher, 0b00000011
		inc count
		
		cpse count, temp
		rjmp loop1

loop2:
		cp input, count
		breq finished
		
		lsl lower
		lsl lower
		ori lower, 0b00000011
		inc count
		rjmp loop2
		
finished:
; store the number of leds on to memory locaton with the ports
		sts S_PORTB, higher
		sts S_PORTL, lower

	ret
;********** END OF LEDS ON *********************


;********** START OF LEDS OFF ******************
leds_off:
; turn leds off store 0 in port
		ldi r17, 0
		sts S_PORTB, r17
		sts S_PORTL, r17
	ret
;********** END OF LEDS OFF ********************


;********** START OF ENCODE MESSAGE ************

encode_message:


; get the message's first character
ldi r16, 0

; where am I on the stack? 
	in YH, SPH
	in YL, SPL


	ldd ZH, Y + 7  ; high message
	ldd ZL, Y + 6 ; low message

	ldd XH, Y + 5   ; sram high
	ldd XL, Y + 4   ; sram low

; loop reads the character from the message 
; then stores the value recived from r0 into
; sram as defined in the assignment
loopy_loop:
	lpm r16, Z+

	cpi r16, 0 
	breq message_read

	push r16
	rcall letter_to_code
	pop r16

	st X+ , r0
	
	rjmp loopy_loop

message_read:
; make sure message has zero at end
	clr r0
	st X, r0
	ret	

;********** END OF ENCODE MESSAGE **************


;********** START OF LETTER TO CODE ************

letter_to_code:
; save stack values
	push YH
	push YL

	push ZH
	push Zl

	push XH
	push XL

	push r16
	push r17
	push r18


.equ OFF_SET = 13

; location of stored table
	ldi ZH, high(ITU_MORSE <<1)
	ldi ZL, low(ITU_MORSE <<1)

; gets pointer to stack data to get letter
	in YH, SPH
	in YL, SPL

; zero register 0
	clr r0

; letter now in r17	
	ldd r17, Y + OFF_SET

; checks to see if it is a space and thus is 0xff
	cpi r17, ' '
	breq space

; a counter for the high byte
	ldi r18, 0;

conv_loop:
	; gets the first letter from list
	lpm r16, Z
	; check to see if done going through list
	cpi r16, 0x00
	breq conv_done

	;check to see if list value in the letter 
	cp r16, r17
	breq inner_conv_loop

	; moves to next letter in list
	adiw ZH:Zl, 8
; the letter has not been found so go to next letter
	rjmp conv_loop

inner_conv_loop:
; move from the letter to the first dash or dot
		adiw ZH:ZL, 1
; load dash or dot into r16
		lpm r16, Z
; check to see if at end of encoding letter 
		cpi r16, 0x00
		breq conv_done
; check if dot or dash is needed
		cpi r16, '.'  
		breq dot
; This adds the dash 
		lsl r0
		inc r0
; skip the dot bit
		rjmp next
dot:
; this adds the dot
		lsl r0
next:
		inc r18

		rjmp inner_conv_loop;
conv_done:
	; r18 has the sequence length in it 
	; swap to get it two the right position then add zeros in
	; the low nibble for when it is "and"ed with the dots and dashes sequence
	swap r18
	add r0 ,r18

; restore the registers
	pop r18
	pop r17
	pop r16

	pop XL
	pop XH

	pop ZL
	pop ZH

	pop YL
	pop YH
 
	ret	 

; This branch handles if the a space has been inputed 
; and a long branch is needed
space:
; get the long delay in r0, 0xFF
	dec r0 

; restore the registers
	pop r18
	pop r17
	pop r16

	pop XL
	pop XH

	pop ZL
	pop ZH

	pop YL
	pop YH
 
	ret	 

;********** END OF LETTER TO CODE **************


; **********************************************
; **** END OF SECOND "STUDENT CODE" SECTION **** 
; **********************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

delay_long:
	rcall delay
	rcall delay
	rcall delay
	ret

delay_short:
	rcall delay
	ret

; When wanting about a 1/5th of second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code.
;
delay_busywait:

	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit
	
	ldi r17, 0xff
delay_busywait_loop2:
	dec	r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


;.org 0x1000

ITU_MORSE: .db "A", ".-", 0, 0, 0, 0, 0
	.db "B", "-...", 0, 0, 0
	.db "C", "-.-.", 0, 0, 0
	.db "D", "-..", 0, 0, 0, 0
	.db "E", ".", 0, 0, 0, 0, 0, 0
	.db "F", "..-.", 0, 0, 0
	.db "G", "--.", 0, 0, 0, 0
	.db "H", "....", 0, 0, 0
	.db "I", "..", 0, 0, 0, 0, 0
	.db "J", ".---", 0, 0, 0
	.db "K", "-.-.", 0, 0, 0
	.db "L", ".-..", 0, 0, 0
	.db "M", "--", 0, 0, 0, 0, 0
	.db "N", "-.", 0, 0, 0, 0, 0
	.db "O", "---", 0, 0, 0, 0
	.db "P", ".--.", 0, 0, 0
	.db "Q", "--.-", 0, 0, 0
	.db "R", ".-.", 0, 0, 0, 0
	.db "S", "...", 0, 0, 0, 0
	.db "T", "-", 0, 0, 0, 0, 0, 0
	.db "U", "..-", 0, 0, 0, 0
	.db "V", "...-", 0, 0, 0
	.db "W", ".--", 0, 0, 0, 0
	.db "X", "-..-", 0, 0, 0
	.db "Y", "-.--", 0, 0, 0
	.db "Z", "--..", 0, 0, 0
	.db 0, 0, 0, 0, 0, 0, 0, 0

MESSAGE01: .db "A A A", 0
MESSAGE02: .db "SOS", 0
MESSAGE03: .db "A BOX", 0
MESSAGE04: .db "DAIRY QUEEN", 0
MESSAGE05: .db "THE SHAPE OF WATER", 0, 0
MESSAGE06: .db "DARKEST HOUR", 0, 0
MESSAGE07: .db "THREE BILLBOARDS OUTSIDE EBBING MISSOURI", 0, 0
MESSAGE08: .db "OH CANADA OUR OWN AND NATIVE LAND", 0
MESSAGE09: .db "I CAN HAZ CHEEZBURGER", 0

; First message ever sent by Morse code (in 1844)
MESSAGE10: .db "WHAT GOD HATH WROUGHT", 0


.dseg
.org 0x200
BUFFER01: .byte 128
BUFFER02: .byte 128
TESTBUFFER: .byte 4

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================
