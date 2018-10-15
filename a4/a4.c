/* a4.c
 * CSC Spring 2018
 * 
 * Student name: Austin Benoit
 * Student UVic ID: 
 * Date of completed work: 29 March 2018 
 *
 *
 * Code provided for Assignment #4
 *
 * Author: Mike Zastre (2018-Mar-25)
 *
 * This skeleton of a C language program is provided to help you
 * begin the programming tasks for A#4. As with the previous
 * assignments, there are "DO NOT TOUCH" sections. You are *not* to
 * modify the lines within these section.
 *
 * You are also NOT to introduce any new program-or file-scope
 * variables (i.e., ALL of your variables must be local variables).
 * YOU MAY, however, read from and write to the existing program- and
 * file-scope variables. Note: "global" variables are program-
 * and file-scope variables.
 *
 * UNAPPROVED CHANGES to "DO NOT TOUCH" sections could result in
 * either incorrect code execution during assignment evaluation, or
 * perhaps even code that cannot be compiled.  The resulting mark may
 * be zero.
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define DELAY1 0.000001
#define DELAY3 0.01

#define PRESCALE_DIV1 8
#define PRESCALE_DIV3 64
#define TOP1 ((int)(0.5 + (F_CPU/PRESCALE_DIV1*DELAY1))) 
#define TOP3 ((int)(0.5 + (F_CPU/PRESCALE_DIV3*DELAY3)))

#define PWM_PERIOD ((long int)500)

volatile long int count = 0;
volatile long int slow_count = 0;


ISR(TIMER1_COMPA_vect) {
	count++;
}


ISR(TIMER3_COMPA_vect) {
	slow_count += 5;
}

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */

void led_state(uint8_t LED, uint8_t state) {
	DDRL = 0xFF;
	uint8_t ledmask = 1 << (7 - 2 * LED);

	if (state){
	
	PORTL |= ledmask;

	}else{
	PORTL &= ~(ledmask);

	}



}



void SOS() {
	DDRL = 0xFF;
    uint8_t light[] = {
        0x1, 0, 0x1, 0, 0x1, 0,
        0xf, 0, 0xf, 0, 0xf, 0,
        0x1, 0, 0x1, 0, 0x1, 0,
        0x0
    };

    int duration[] = {
        100, 250, 100, 250, 100, 500,
        250, 250, 250, 250, 250, 500,
        100, 250, 100, 250, 100, 250,
        250
    };

	int length = 19;



	for(int i = 0; i < length; i++){
		

		
		for(int j = 0; j < 4; j++){
		/* goes through each light and checks if it needs to be turned on */
			uint8_t mask = 1<<j;  
			mask &= light[i];
			led_state(j,mask);
		}
		
		_delay_ms(duration[i]);
	
	}





}


void glow(uint8_t LED, float brightness) {
	DDRL = 0xFF;
	int threshold = PWM_PERIOD * brightness;
	int cur_state = 0;

	for(;;){
		if(count < threshold && !cur_state){
			led_state(LED, 1);
			cur_state = 1;

		}else if (count < PWM_PERIOD && cur_state){
			led_state(LED,0);
			cur_state = 0;
			
		}else if (count > PWM_PERIOD){
		count = 0;

		}
	}
}



void pulse_glow(uint8_t LED) {
	DDRL = 0xFF;
	int threshold = 0;
	int going_up = 1; 
	int cur_state = 0;

	for(;;){

	// up loop
	// 0 - 500

	if (slow_count > 5){
		if(going_up){
			threshold++;
		} else{
			threshold--;
		}

		slow_count = 0;
		
		if(threshold > PWM_PERIOD)
		{
			threshold = PWM_PERIOD;
			going_up ^= 1;
		}
	
		 if(threshold < 0)
		{
			threshold = 0;
			going_up ^= 1;
		}
	}



		if(count < threshold && !cur_state){
			led_state(LED, 1);
			cur_state = 1;

		}else if (count < PWM_PERIOD && cur_state){
			led_state(LED,0);
			cur_state = 0;
			
		}else if (count > PWM_PERIOD){
		count = 0;

		
		}

	}

	

}


void light_show() {
		DDRL = 0xFF;

		uint8_t light[] = {
        0xf, 0, 0xf, 0, 0xf, 0, // three flash
        0x6, 0, 0x9, 0,         //  in out 
		0xf, 0, 0xf, 0, 0xf, 0,  // three flash
		0x9, 0, 0x6, 0,           //out in 

		0x8, 0xc, 0x6, 0x3, 0x1, //snake right
		0x3, 0x6, 0xc, 0x8,       //snake left
		0xc, 0x6, 0x3, 0x1, //snake right
		0x3, 0x6, 0,   // snake left stop in mid

		0xf, 0, 0xf, 0,  // flash twice
		0x6, 0, 0x6, 0  // flash mid twice

    };

    int duration[] = {
        200, 200, 200, 200, 200, 200,
        100, 100, 100, 100,
		200, 200, 200, 200, 200, 200, 
		100, 100, 100, 100,

		100, 100, 100, 100, 100,
		100, 100, 100, 100,
		100, 100, 100, 100,
		100, 100, 100,

		200, 200, 200, 200,
		200, 200, 200, 200
    };

	int length = 44;





	for(int i = 0; i < length; i++){
		for(int j = 0; j < 4; j++){
		/* goes through each light and checks if it needs to be turned on */
			uint8_t mask = 1<<j;  
			mask &= light[i];
			led_state(j,mask);
		}
		
		_delay_ms(duration[i]);
	
	}

	_delay_ms(1000);

}


/* ***************************************************
 * **** END OF FIRST "STUDENT CODE" SECTION **********
 * ***************************************************
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

int main() {
    /* Turn off global interrupts while setting up timers. */

	cli();

	/* Set up timer 1, i.e., an interrupt every 1 microsecond. */
	OCR1A = TOP1;
	TCCR1A = 0;
	TCCR1B = 0;
	TCCR1B |= (1 << WGM12);
    /* Next two lines provide a prescaler value of 8. */
	TCCR1B |= (1 << CS11);
	TCCR1B |= (1 << CS10);
	TIMSK1 |= (1 << OCIE1A);

	/* Set up timer 3, i.e., an interrupt every 10 milliseconds. */
	OCR3A = TOP3;
	TCCR3A = 0;
	TCCR3B = 0;
	TCCR3B |= (1 << WGM32);
    /* Next line provides a prescaler value of 64. */
	TCCR3B |= (1 << CS31);
	TIMSK3 |= (1 << OCIE3A);


	/* Turn on global interrupts */
	sei();

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */

/* This code could be used to test your work for part A.

for(;;){
	led_state(0, 1);
	_delay_ms(1000);
	led_state(1, 1);
	_delay_ms(1000);
	led_state(2, 1);
	_delay_ms(1000);
	led_state(3, 1);
	_delay_ms(1000);
	led_state(0, 0);
	_delay_ms(1000);
	led_state(1, 0);
	_delay_ms(1000);
	led_state(2, 0);
	_delay_ms(1000);
	led_state(3, 0);
	_delay_ms(1000);

	}
*/
 /*This code could be used to test your work for part B.
	for(;;){
	SOS();
	}
	*/


/* This code could be used to test your work for part C.

	glow(0, 1);
*/



/* This code could be used to test your work for part D.
*/ 
	pulse_glow(3);



/* This code could be used to test your work for the bonus part.

for(;;){
	light_show();
}
*/
for(;;)
;
/* ****************************************************
 * **** END OF SECOND "STUDENT CODE" SECTION **********
 * ****************************************************
 */
}
