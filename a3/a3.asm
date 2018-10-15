; a3part4.asm
; CSC 230: Spring 2018
;
; Student name: Austin Benoit
; Student ID:
; Date of completed work: 24 March 2018
;
; *******************************
; Code provided for Assignment #3
;
; Author: Mike Zastre (2018-Mar-08)
; 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#3. As with A#2, there are 
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
;
; In this "DO NOT TOUCH" section are:
;
; (1) assembler directives setting up the interrupt-vector table
;
; (2) "includes" for the LCD display
;
; (3) some definitions of constants we can use later in the
;     program
;
; (4) code for initial setup of the Analog Digital Converter (in the
;     same manner in which it was set up for Lab #4)
;     
; (5) code for setting up our three timers (timer1, timer3, timer4)
;
; After all this initial code, your own solution's code may start.
;

.cseg
.org 0
	jmp reset

; location in vector table for TIMER1 COMPA
;
.org 0x22
	jmp timer1

; location in vector table for TIMER4 COMPA
;
.org 0x54
	jmp timer4

.include "m2560def.inc"
.include "lcd_function_defs.inc"
.include "lcd_function_code.asm"

.cseg

; These two constants can help given what is required by the
; assignment.
;
#define MAX_PATTERN_LENGTH 10
#define BAR_LENGTH 6

; All of these delays are in seconds
;
#define DELAY1 0.5
#define DELAY3 0.1
#define DELAY4 0.01


; The following lines are executed at assembly time -- their
; whole purpose is to compute the counter values that will later
; be stored into the appropriate Output Compare registers during
; timer setup.
;

#define CLOCK 16.0e6 
.equ PRESCALE_DIV=1024  ; implies CS[2:0] is 0b101
.equ TOP1=int(0.5+(CLOCK/PRESCALE_DIV*DELAY1))

.if TOP1>65535
.error "TOP1 is out of range"
.endif

.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif


reset:
	; initialize the ADC converter (which is neeeded
	; to read buttons on shield). Note that we'll
	; use the interrupt handler for timer4 to
	; read the buttons (i.e., every 10 ms)
	;
	ldi temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
	sts ADCSRA, temp
	ldi temp, (1 << REFS0)
	sts ADMUX, r16


	; timer1 is for the heartbeat -- i.e., part (1)
	;
    ldi r16, high(TOP1)
    sts OCR1AH, r16
    ldi r16, low(TOP1)
    sts OCR1AL, r16
    ldi r16, 0
    sts TCCR1A, r16
    ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
    sts TCCR1B, temp
	ldi r16, (1 << OCIE1A)
	sts TIMSK1, r16

	; timer3 is for the LCD display updates -- needed for all parts
	;
    ldi r16, high(TOP3)
    sts OCR3AH, r16
    ldi r16, low(TOP3)
    sts OCR3AL, r16
    ldi r16, 0
    sts TCCR3A, r16
    ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)
    sts TCCR3B, temp

	; timer4 is for reading buttons at 10ms intervals -- i.e., part (2)
    ; and part (3)
	;
    ldi r16, high(TOP4)
    sts OCR4AH, r16
    ldi r16, low(TOP4)
    sts OCR4AL, r16
    ldi r16, 0
    sts TCCR4A, r16
    ldi r16, (1 << WGM42) | (1 << CS42) | (1 << CS40)
    sts TCCR4B, temp
	ldi r16, (1 << OCIE4A)
	sts TIMSK4, r16

    ; flip the switch -- i.e., enable the interrupts
    sei

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================


; *********************************************
; **** BEGINNING OF "STUDENT CODE" SECTION **** 
; *********************************************
.def temp = r16
.def templow = r16
.def temphigh = r17


; Definitions for call button
; see call button

.def DATAH=r29  ;DATAH:DATAL  store 10 bits data from ADC
.def DATAL=r28
.def BOUNDARY_H=r1  ;hold high byte value of the threshhold for button
.def BOUNDARY_L=r0  ;hold low byte value of the threshhold for button, r1:r0

.equ MAX_POS = 5


;===== Set Up Stack =====
	cli
	ldi temphigh, high(RAMEND)
	ldi templow, low(RAMEND)
	out SPH, temphigh
	out SPL, templow
	sei
;===== End set up stack =====

;===== zero out the data space
	ldi ZH, high(COUNTER_TEXT)
	ldi ZL, low(COUNTER_TEXT)
	ldi temp, '1' 
	st Z+, temp
	st Z+, temp
	st Z+, temp
	st Z+, temp
	st Z+, temp
	ldi temp, 0
	st Z, temp

	ldi ZH, high(BUTTON_COUNT)
	ldi ZL, low(BUTTON_COUNT)
	ldi temp, 0 
	st Z+, temp
	st Z, temp

	ldi ZH, high(BUTTON_LENGTH)
	ldi ZL, low(BUTTON_LENGTH)
	ldi temp, 1 
	st Z, temp

	ldi ZH, high(DOTDASH_PATTERN)
	ldi ZL, low(DOTDASH_PATTERN)
	ldi temp, 0 
	st Z+, temp
	st Z+, temp
	st Z+, temp
	st Z+, temp
	st Z+, temp
	st Z+, temp
	st Z+, temp
	st Z+, temp
	st Z+, temp
	st Z+, temp
	ldi temp, 0
	st Z, temp

;===== End the zero out =====

;===== LCD display start up =====
	call lcd_init
	call lcd_clr;
;===== END LCD display start up =====

;===== infinite loop REFRESH =====
; The loop polls timer 3. 
; Timer three's delay is set by TOP3
refresh:
	in temp, TIFR3
	sbrs temp, OCF3A
	rjmp refresh
	call update_display	
; reset the timer 
	ldi temp, 1<<OCF3A
	out TIFR3, temp
	jmp refresh
;===== End of REFRESH =====

;===== Catch All Loop =====
stop:
    rjmp stop
;===== End Catch All Loop =====

;===== Update display =====
update_display:
; Save registers
	push temphigh
	push templow
	push ZH
	push ZL

;*----- start heart 
	lds temp, PULSE

	tst temp
	breq spaces

; curser is set to the <> location as defined in write up
; is row 0  col 14 which is 0x0E as defined in lcd program
	ldi templow, 0
	ldi temphigh, 14

	push templow
	push temphigh
	call lcd_gotoxy
	pop temp
	pop temp
; push <
	ldi temp, '<'
	push temp
	call lcd_putchar
	pop temp
; push >
	ldi temp, '>'
	push temp 
	call lcd_putchar
	pop temp
	
	jmp done_br

spaces:
	ldi templow, 0
	ldi temphigh, 14

	push templow
	push temphigh
	call lcd_gotoxy
	pop temp
	pop temp
; push space
	ldi temp, ' '
	push temp
	call lcd_putchar
	pop temp
; push space
	ldi temp, ' '
	push temp 
	call lcd_putchar
	pop temp
done_br:
;*---- Done heart


;*---- count
	;ldi ZH, HIGH(BUTTON_COUNT)
	;ldi ZL, LOW(BUTTON_COUNT)
	lds temphigh,BUTTON_COUNT
	lds templow, BUTTON_COUNT+1

	push temphigh
 	push templow
	ldi r17, high(COUNTER_TEXT)
 	ldi r16, low(COUNTER_TEXT)
	push r17
 	push r16
	rcall to_decimal_text
	pop temp	
	pop temp
	pop temp
	pop temp
; set location 
	ldi templow, 1
	ldi temphigh, 11

	push templow
	push temphigh
	call lcd_gotoxy
	pop temp
	pop temp
; push string
	ldi temphigh, high(COUNTER_TEXT)
	ldi templow, low(COUNTER_TEXT)
	push temphigh
 	push templow
	call lcd_puts 
	pop temp
	pop temp
;*---- end count

;*---- the stars
	ldi templow, 1
	ldi temphigh, 0

	push templow
	push temphigh
	call lcd_gotoxy
	pop temp
	pop temp

	ldi ZH, HIGH(BUTTON_CURRENT)
	ldi ZL, LOW(BUTTON_CURRENT)
	ld temp, z

	tst temp
	breq no_star
;outputs the stars 

	ldi temp, '*'
	push temp
	call lcd_putchar
	call lcd_putchar
	call lcd_putchar
	call lcd_putchar
	call lcd_putchar
	call lcd_putchar
	pop temp
	jmp end_stars

no_star:
	ldi temp, ' '
	push temp
	call lcd_putchar
	call lcd_putchar
	call lcd_putchar
	call lcd_putchar
	call lcd_putchar
	call lcd_putchar
	pop temp
end_stars:
;*---- end stars

;*---- display dotdah
; set location 
	ldi templow, 0
	ldi temphigh, 0
	push templow
	push temphigh
	call lcd_gotoxy
	pop temp
	pop temp
; push string
	ldi temphigh, high(DOTDASH_PATTERN)
	ldi templow, low(DOTDASH_PATTERN)
	push temphigh
 	push templow
	call lcd_puts 
	pop temp
	pop temp

;*---- end display dotdash


; restore registers
	pop ZL
	pop ZH
	pop templow
	pop temphigh
	ret
;===== End of update display =====

;===== Timer that sets the <> =====
; toggles a bit stored in data space
timer1:
	push temphigh
	push templow
	push ZH
	push ZL
	in temp, SREG
	push temp

	ldi ZH, HIGH(PULSE)
	ldi ZL, LOW(PULSE)
	ld temp, Z
	ldi temphigh, 0x01
;exor with exisiting data to toggle
	eor temp, temphigh
; store data
	st Z, temp
; restore registers
	pop temp	
	out SREG, temp
	pop ZL
	pop ZH
	pop templow
	pop temphigh
	reti
;===== END Timer that sets the <> =====

;===== Start button checking =====
timer4:
	push r24
	push DATAH
	push DATAL
	push BOUNDARY_H
	push BOUNDARY_L
	push temphigh
	push templow
	push ZH
	push ZL
	push YH
	push YL
	in temp, SREG
	push temp
; **** check button uses above saved registers 
; **** returns value in temp register
	call check_button

;	ldi ZH, HIGH(BUTTON_CURRENT)
;	ldi ZL, LOW(BUTTON_CURRENT)

	lds templow, BUTTON_CURRENT

;	ldi ZH, HIGH(BUTTON_PREVIOUS)
;	ldi ZL, LOW(BUTTON_PREVIOUS)
	lds temphigh, BUTTON_PREVIOUS

	sts BUTTON_PREVIOUS, templow

; check to see if button has gone from low to high 
	tst templow
	breq end

	eor templow, temphigh
	tst templow
	breq end 


; increments count
;	ldi ZH, HIGH(BUTTON_COUNT)
;	ldi ZL, LOW(BUTTON_COUNT)
;	ld YH, Z+
;	ld YL, Z

;	adiw Y,1
;	; gets z back to starting point
;	sbiw Z, 1
;	
;	st Z+, YH
;	st Z, YL

	lds YH, BUTTON_COUNT 
	lds YL, BUTTON_COUNT + 1
	adiw Y, 1
	sts BUTTON_COUNT, YH
	sts BUTTON_COUNT + 1, YL



end:





; the dot dash pattern
	lds temp, BUTTON_CURRENT
; see if button is high or low 
	tst temp
	breq not_pressed
; Button is high
; inc button length
	lds temp, BUTTON_LENGTH
	inc temp
	sts BUTTON_LENGTH, temp
	jmp finished

not_pressed:
	
; check to see time
	lds temp, BUTTON_LENGTH
;MAY NEED TO MOVE TO GET THE FUNCTONALITY AS SHOWN
	lds temphigh, BUTTON_LENGTH
	ldi temphigh, 1
	sts BUTTON_LENGTH, temphigh
	cpi temp, 20
	brge dash

; if still at 1 then no change in state
	cpi temp, 1
	breq finished

; is the dot case 
	ldi ZH, HIGH(DOTDASH_PATTERN)
	ldi ZL, LOW(DOTDASH_PATTERN)
	ldi r28, 0

dot_loop:

	cpi r28, 10
	breq finished
	
	ld temphigh, Z
	cpi temphigh, 0
	breq cont




	st Z+, temphigh
	inc r28
	jmp dot_loop
cont:
	ldi temp,'.'
	st Z, temp


	jmp finished


dash:
	ldi ZH, HIGH(DOTDASH_PATTERN)
	ldi ZL, LOW(DOTDASH_PATTERN)
	ldi r28, 0

dash_loop:
	cpi r28, 10
	breq finished

	ld temphigh, Z
	cpi temphigh, 0
	breq conts

	st Z+, temphigh
	inc r28
	jmp dash_loop

conts:
	ldi temp,'-'
	st Z, temp

finished:
	pop temp	
	out SREG, temp
	pop YL
	pop YH
	pop ZL
	pop ZH
	pop templow
	pop temphigh
	pop BOUNDARY_L
	pop BOUNDARY_H
	pop DATAL
	pop DATAH
	pop r24
    reti
;===== END Button checking =====







;===== Start check Button =====
;**** Important ****
; This code has been modified from Dr. Zaster
; Taken from lab4 button.asm 
; winter 2018
check_button:
	; start a2d
	lds	r16, ADCSRA	

	; bit 6 =1 ADSC (ADC Start Conversion bit), remain 1 if conversion not done
	; ADSC changed to 0 if conversion is done
	ori r16, 0x40 ; 0x40 = 0b01000000
	sts	ADCSRA, r16

	; wait for A to D conversion to complete, check for bit 6, the ADSC bit
wait:	lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value, use XH:XL to store the 10-bit result
		lds DATAL, ADCL
		lds DATAH, ADCH

		clr r24
		ldi r16, low(0x3E7)
		ldi r17, high(0x3E7)
		cp DATAL, r16
		cpc DATAH, r17
		brsh skip		
		ldi r24,1
skip:	
	sts BUTTON_CURRENT, r24
	ret

;===== END Check Button =====


;===== Convert to ASCII Decimal =====
; Taken from Dr.Zaster code posted online

; First parameter: 16-bit value for which a
; text representation of its decimal form is to
; be stored.
;
; Second parameter: 16-bit address in data memory
; in which the text representation is to be stored.
;
to_decimal_text:
 .def countL=r18
 .def countH=r19
 .def factorL=r20
 .def factorH=r21
 .def multiple=r22
 .def pos=r23
 .def zero=r0
 .def ascii_zero=r16
 push countH
 push countL
 push factorH
 push factorL
 push multiple
 push pos
 push zero
 push ascii_zero
 push YH
 push YL
 push ZH
 push ZL
 in YH, SPH
 in YL, SPL
 ; fetch parameters from stack frame
 ;
 .set PARAM_OFFSET = 16
 ldd countH, Y+PARAM_OFFSET+3
 ldd countL, Y+PARAM_OFFSET+2
 ; this is only designed for positive
 ; signed integers; we force a negative
 ; integer to be positive.
 ;
 andi countH, 0b01111111
 clr zero
 clr pos
 ldi ascii_zero, '0'
 ; The idea here is to build the text representation
 ; digit by digit, starting from the left-most.
 ; Since we need only concern ourselves with final
 ; text strings having five characters (i.e., our
 ; text of the decimal will never be more than
 ; five characters in length), we begin we determining
 ; how many times 10000 fits into countH:countL, and
 ; use that to determine what character (from �0� to
 ; �9�) should appear in the left-most position
 ; of the string.
 ;
 ; Then we do the same thing for 1000, then
 ; for 100, then for 10, and finally for 1.
 ;
 ; Note that for *all* of these cases countH:countL is
 ; modified. We never write these values back onto
 ; that stack. This means the caller of the function
 ; can assume call-by-value semantics for the argument
 ; passed into the function.
 ;
to_decimal_next:
 clr multiple
to_decimal_10000:
 cpi pos, 0
 brne to_decimal_1000
 ldi factorL, low(10000)
 ldi factorH, high(10000)
 rjmp to_decimal_loop
to_decimal_1000:
 cpi pos, 1
 brne to_decimal_100
 ldi factorL, low(1000)
 ldi factorH, high(1000)
rjmp to_decimal_loop
to_decimal_100:
 cpi pos, 2
 brne to_decimal_10
 ldi factorL, low(100)
 ldi factorH, high(100)
 rjmp to_decimal_loop
to_decimal_10:
 cpi pos, 3
 brne to_decimal_1
 ldi factorL, low(10)
 ldi factorH, high(10)
 rjmp to_decimal_loop
to_decimal_1:
 mov multiple, countL
 rjmp to_decimal_write
to_decimal_loop:
 inc multiple
 sub countL, factorL
 sbc countH, factorH
 brpl to_decimal_loop
 dec multiple
 add countL, factorL
 adc countH, factorH
to_decimal_write:
 ldd ZH, Y+PARAM_OFFSET+1
 ldd ZL, Y+PARAM_OFFSET+0
 add ZL, pos
 adc ZH, zero
 add multiple, ascii_zero
 st Z, multiple
 inc pos
 cpi pos, MAX_POS
 breq to_decimal_exit
 rjmp to_decimal_next
to_decimal_exit:
 pop ZL
 pop ZH
 pop YL
 pop YH
 pop ascii_zero
 pop zero
 pop pos
 pop multiple
 pop factorL
 pop factorH
 pop countL
 pop countH
 .undef countL
 .undef countH
 .undef factorL
 .undef factorH
 .undef multiple
 .undef pos
 .undef zero
 .undef ascii_zero
 ret
;===== END Convert to ASCII Decimal =====


; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION ********** 
; ***************************************************


; ################################################
; #### BEGINNING OF "TOUCH CAREFULLY" SECTION ####
; ################################################

; The purpose of these locations in data memory are
; explained in the assignment description.
;

.dseg

PULSE: .byte 1
COUNTER: .byte 2
DISPLAY_TEXT: .byte 16
BUTTON_CURRENT: .byte 1
BUTTON_PREVIOUS: .byte 1
BUTTON_COUNT: .byte 2
BUTTON_LENGTH: .byte 1
DOTDASH_PATTERN: .byte MAX_PATTERN_LENGTH+1
COUNTER_TEXT: .byte 6
; ##########################################
; #### END OF "TOUCH CAREFULLY" SECTION ####
; ##########################################

