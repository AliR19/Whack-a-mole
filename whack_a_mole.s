
; ENSE 352 Whack-a-mole Project
; Date: December 7th 2020
; 
; Author: Ali Rizvi, 200379478
; GPIO Test program - Dave Duguid, 2011
; Modified Trevor Douglas 2014

;;; Directives
            PRESERVE8
            THUMB       
;;; Equates

INITIAL_MSP	EQU		0x20001000	; Initial Main Stack Pointer Value


;PORT A GPIO - Base Addr: 0x40010800
GPIOA_CRL	EQU		0x40010800	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOA_CRH	EQU		0x40010804	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOA_IDR	EQU		0x40010808	; (0x08) Port Input Data Register
GPIOA_ODR	EQU		0x4001080C	; (0x0C) Port Output Data Register
GPIOA_BSRR	EQU		0x40010810	; (0x10) Port Bit Set/Reset Register
GPIOA_BRR	EQU		0x40010814	; (0x14) Port Bit Reset Register
GPIOA_LCKR	EQU		0x40010818	; (0x18) Port Configuration Lock Register

;PORT B GPIO - Base Addr: 0x40010C00
GPIOB_CRL	EQU		0x40010C00	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOB_CRH	EQU		0x40010C04	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOB_IDR	EQU		0x40010C08	; (0x08) Port Input Data Register
GPIOB_ODR	EQU		0x40010C0C	; (0x0C) Port Output Data Register
GPIOB_BSRR	EQU		0x40010C10	; (0x10) Port Bit Set/Reset Register
GPIOB_BRR	EQU		0x40010C14	; (0x14) Port Bit Reset Register
GPIOB_LCKR	EQU		0x40010C18	; (0x18) Port Configuration Lock Register

;The onboard LEDS are on port C bits 8 and 9
;PORT C GPIO - Base Addr: 0x40011000
GPIOC_CRL	EQU		0x40011000	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOC_CRH	EQU		0x40011004	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOC_IDR	EQU		0x40011008	; (0x08) Port Input Data Register
GPIOC_ODR	EQU		0x4001100C	; (0x0C) Port Output Data Register
GPIOC_BSRR	EQU		0x40011010	; (0x10) Port Bit Set/Reset Register
GPIOC_BRR	EQU		0x40011014	; (0x14) Port Bit Reset Register
GPIOC_LCKR	EQU		0x40011018	; (0x18) Port Configuration Lock Register

;Registers for configuring and enabling the clocks
;RCC Registers - Base Addr: 0x40021000
RCC_CR		EQU		0x40021000	; Clock Control Register
RCC_CFGR	EQU		0x40021004	; Clock Configuration Register
RCC_CIR		EQU		0x40021008	; Clock Interrupt Register
RCC_APB2RSTR	EQU	0x4002100C	; APB2 Peripheral Reset Register
RCC_APB1RSTR	EQU	0x40021010	; APB1 Peripheral Reset Register
RCC_AHBENR	EQU		0x40021014	; AHB Peripheral Clock Enable Register

RCC_APB2ENR	EQU		0x40021018	; APB2 Peripheral Clock Enable Register  -- Used

RCC_APB1ENR	EQU		0x4002101C	; APB1 Peripheral Clock Enable Register
RCC_BDCR	EQU		0x40021020	; Backup Domain Control Register
RCC_CSR		EQU		0x40021024	; Control/Status Register
RCC_CFGR2	EQU		0x4002102C	; Clock Configuration Register 2

; Times for delay routines
        
DELAYTIME	EQU		120000		; (250 ms/24MHz PLL)
;DELAYTIME	EQU		1600000		; (200 ms/24MHz PLL)
;DELAYTIME	EQU		160000		; (20 ms/24MHz PLL)
;DELAYTIME	EQU		16000		; (2 ms/24MHz PLL)
;DELAYTIME	EQU		800000		; (100 ms/24MHz PLL)
;DELAYTIME	EQU		80000		; (10 ms/24MHz PLL)
;DELAYTIME	EQU		8000		; (1 ms/24MHz PLL)

PRELIMTIME	EQU		3000000		;wait time of 100 ms/24MHz PLL
REACTTIME	EQU		2100000
WINNINGSIGNALTIME EQU 100
WINDELAYTIME EQU 	200000
LOSINGSIGNALTIME EQU  5

; Location to store X random seed
X_LOC		EQU		0x20001008

; Constants for random generator
XN			EQU		0x5FEF1239
A			EQU		1664525
C			EQU		1013904223

;Constants
NUMCYCLES	EQU		15
TIMEDIFF	EQU		120000

; Vector Table Mapped to Address 0 at Reset
            AREA    RESET, Data, READONLY
            EXPORT  __Vectors\

__Vectors	DCD		INITIAL_MSP			; stack pointer value when stack is empty
        	DCD		Reset_Handler		; reset vector
			\
            AREA    MYCODE, CODE, READONLY
			EXPORT	Reset_Handler
			ENTRY\

Reset_Handler		PROC
	    BL UC1			;After pressing RESET button, user performs a system reboot
		B MAIN
		
		
	
	ALIGN
		
;;Usercase 1: In this UC1, the user should hit the RESET (B2) button. 
;;            The program will be entering the Reset_Handler code and the 
;;			  system bootup will occur where the GPIO_ClockInit, GPIO_init
;;			  and TURN_OFF_LED subroutines are called to enable the RCC_APB2ENR
;;			  for ports A,B,C and write to GPIOA_CRH for making ports PA9-PA12
;;			  as output push-pull and then disabling those by writing to
;;			  GPIOx_ODR to turn all LEDs off.
			
			
;;This routine will allow user to enter UC1 (Use case 1)		
UC1	PROC

	BL GPIO_ClockInit		;Enable clocks for ports A,B and C
	
	BL GPIO_init			;Enable GPIO ports as outputs
	
	BL TURN_OFF_LED			;Turn off all LED's
	

	ENDP
		
	ALIGN
		
		
	
;;This routine will enable the clock for the Ports that you need
GPIO_ClockInit PROC

    LDR R6,=RCC_APB2ENR        ; clock address
    LDR R0,=0x1C               ;enabling port A,B and C
    STR R0,[R6]                   
	BX LR
	ENDP

	ALIGN
		
;;This routine enables the GPIO for the LED's.  By default the I/O lines are input so we only need to configure for ouptut.

GPIO_init	PROC

	LDR R6,=GPIOA_CRH          ;address of control register,activate ports for the light
	LDR R0,=0x33330            ;configuring port A9-A12,Output mode max speed 50 MHZ
	STR R0,[R6]               ;store it in R6 to activate the lights
	BX LR	
	ENDP
		
	ALIGN
		
		
		
;;This routine will turn off all the LED's by writing 1 to bits 9,10,11 and 12
;;of GPIOA_ODR as leds are active low and writing 1 will turn them off for pins A9-A12
TURN_OFF_LED PROC
	
	LDR R6,=GPIOA_ODR           
    LDR R0,=0x1E00             ;turning off the light LED1,LED2,LED3 and LED4	
	STR R0,[R6]                ;storing it in R6
	
	;BX LR					   ;return to main function	
	ENDP
		
	ALIGN
	
	
		
;;This is the main part of the program which will run UC2,UC3,UC4,UC5
MAIN PROC
	BL UC2						;Call UC2 function
	
NORMAL_GAME_PLAY
	LDR R6,=GPIOA_ODR           
    LDR R0,=0x1E00             ;turning off the light LED1	
	STR R0,[R6]                ;storing it in R6
	BL UC3					   ;Start UC3
GO_TO_UC4
	BL UC4					   ;Start UC4
GO_TO_UC5
	BL UC5					   ;Start UC5
	
DONE  B DONE

	ENDP
	
	
;;Usercase 2: This will be Waiting for the Player. LED
;;pattern indicate no game in on. To start the game, user must
;;press any of the push buttons.This requires
;;	- Turning on the LEDs by enabling them in GPIOx_ODR.
;;  - Provide a delay of 1s between each LED to get 1 Hz.
;;  - Poll for any of the push buttons to be pressed.
;;  - Read GPIOx_IDR to know status of any push button.
;;	- Buttons are active low, so if GPIOx_IDR bit is 0, it 
;;    means that a button is pressed.Function should end 
;;    and return to MAIN and wait for UC3

	ALIGN

UC2		PROC

UC2_LOOP					  ;keep looping untill a button is pressed
	;Turn on LED1
	LDR R0,=GPIOA_ODR
	LDR R1,=0xFDFF            ;9th bit is 0, so it turns on led1 at PA9
	STR R1,[R0]
	
	BL DELAY
	
	;Turn on LED2
	LDR R0,=GPIOA_ODR
	LDR R1,=0xFBFF            ;10th bit is 0, so it turns on led2 at PA10
	STR R1,[R0]

	BL DELAY
	
	;Turn on LED3
	LDR R0,=GPIOA_ODR
	LDR R1,=0xF7FF            ;11th bit is 0, so it turns on led3 at PA11
	STR R1,[R0]

	BL DELAY
	
	;Turn on LED4
	LDR R0,=GPIOA_ODR
	LDR R1,=0xEFFF            ;12th bit is 0, so it turns on led4 at PA12
	STR R1,[R0]

	BL DELAY
	
	B UC2_LOOP				;if none of the buttons pressed, keep looping
	
;;Com out of UC2 if any button is detected
UC2_FINISH	
	B NORMAL_GAME_PLAY
	ENDP


		
;;Usercase 3: The normal gameplay starts in UC3. The user has
;;to wait for a Prelimwait time before starting with the game.
;;Once the game starts, random LEDs turn on for fixed time limit
;;and user has to push the respective button to turn it off. The 
;;faster the user presses the button, the lesser the reaction time
;;gets. This gets repeated for a few cycles and the success or
;;failure of the user is decided based on his ability to hit the push
;;buttons in time. This subroutine can be divided into following sub-tasks:
;;	- Loading a counter with PrelimWait time.
;;	- Get a random seed x and store in some address.
;;	- Preload counter with the ReactTime and an offset
;;	  to decrement from it for every cycle.
;;	- Get into random generator subroutine and create
;;	  a random number using the formula Xn+1 = (AXn + C)mod m
;;	  where A=1664525, C=1013904223,m=2**32.
;;	- We will leave out operation mod m here because m is 2**32
;;	  which requires a 64 bit register to hold the value and is
;;	  too huge to store in a 32 bit register which will make mod
;;	  operation unwantedly complex.
;;	- The random generator will generate a random number out of 1,2,3 or 4 by right
;;	  shifting this huge number by 30 to get the MSB 2 bits.
;;	- If this number is 3, LED 3 will get chance to turn on and so on.
;;	- Thus this random generation sequence will direct which LED to 
;;	  turn on at present.This present LED becomes Xn for next 
;;	  calculation and Xn+1 being the LED for the next time.
;;	- To turn on LED, we need to enable it by writing 0 in GPIOx_ODR.
;;	- Start counter in ReactTime and decrement it to 0
;;	- While this counter is decrementing, parallely poll for the 
;;	  corresponding push button to be pressed by monitoring the
;;	  respective GPIOx_IDR bit e.g if LED 3 is on, wait for pushbutton
;;	  3 to be pressed wihin ReactTime.
;;	- At a time, only one LED should be on, so there should be 4 different
;;	  subroutines for the turning on and off of 4 different LED's
;;	- subroutine will be called according to button colour eg. if blue button 
;;	  is for led3, then BLUE_LED3_ON subroutine will turn on and off LED3.
;;	-  We will wait for WAIT_BLUE_BUTTON subroutine to know if user pressed 
;;	  push button BLUE and so on for other Buttons as well.

	ALIGN
UC3		PROC
	
;;Generate a random seed number and store in address
	LDR R4,=XN
	LDR R5,=X_LOC
	STR R4, [R5]				;Store Xn in memory address 0x20001008

;;Need to make sure that all LEDs are turned off
WAIT_LED1_OFF
	LDR R8,=GPIOA_ODR    	;Load the output address for LED1
	LDR R0,[R8]          	;reading the LED1 status in R0	
	AND R0,#0x200        	;Reading the 9th bit, should be 1
	LSR R0, #9
	CMP R0,#0x1				;check that LED1 is turned off
	BNE	WAIT_LED1_OFF
	
WAIT_LED2_OFF
	LDR R8,=GPIOA_ODR    	;Load the output address for LED2
	LDR R0,[R8]          	;reading the LED2 status in R0	
	AND R0,#0x400        	;Reading the 10th bit, should be 1
	LSR R0, #10
	CMP R0,#0x1				;check that LED2 is turned off
	BNE	WAIT_LED2_OFF

WAIT_LED3_OFF
	LDR R8,=GPIOA_ODR    	;Load the output address for LED3
	LDR R0,[R8]          	;reading the LED3 status in R0	
	AND R0,#0x800        	;Reading the 11th bit, should be 1
	LSR R0, #11
	CMP R0,#0x1				;check that LED3 is turned off
	BNE	WAIT_LED3_OFF
	
WAIT_LED4_OFF
	LDR R8,=GPIOA_ODR    	;Load the output address for LED4
	LDR R0,[R8]          	;reading the LED4 status in R0	
	AND R0,#0x1000        	;Reading the 12th bit, should be 1
	LSR R0, #12
	CMP R0,#0x1				;check that LED4 is turned off
	BNE	WAIT_LED4_OFF

;;Initialization of counters
	LDR R4,=REACTTIME
	PUSH {R4}				    ;Store Reacttime in Stack
	MOV R9, #0x0				;Clear the Score counter
	MOV R11, #0x0				;Clear the flag
	MOV R10, #0x0				;Clear the Numcycles counter
	LDR R10,=NUMCYCLES			;Load 15 into the Counter
	
;;Wait for few milliseconds in PrelimTime delay
PRELIMWAIT	
	 
	LDR R6,=PRELIMTIME
LOOP2
	SUB R6, R6, #0x1
	CMP R6, #0x0
	BNE LOOP2

;;Start the Game - Turn random LED on
GAME_START
	BL RANDOM_NUM_GEN
	
;;Check the outcome of Random number generator
	CMP R0, #0
	BEQ RED_LED1_ON				;Turn on and off LED1 which is linked to Red Button
	
	CMP R0, #1
	BEQ BLACK_LED2_ON			;Turn on and off LED2 which is linked to Black Button
	
	CMP R0, #2
	BEQ BLUE_LED3_ON			;Turn on and off LED3 which is linked to Blue Button
    
	CMP R0, #3
	BEQ GREEN_LED4_ON			;Turn on and off LED4 which is linked to Green Button
	
	
	

;;Subroutine to turn on LED1, wait for ReactTime
;;turn off after ReactTime is over. If user presses
;;Red button, increment score counter
RED_LED1_ON
	LDR R2,=GPIOA_ODR
	LDR R1,=0xFDFF            	;9th bit is 0, so it turns on led1 at PA9
	STR R1,[R2]
	BL REACTTIME_WAIT_1			;Turn on for ReactTime
	LDR R6,=GPIOA_ODR           
    LDR R0,=0x1E00             	;turning off the light LED1	
	STR R0,[R6]
	CMP R11, #1					;If flag is set, button was pressed, else discontinue
	BNE STOP_PLAY				;If flag is 0, UC3 Alternate Path: ReactTime expires
	ADD R9, R9, #1				;Increment score counter if button pressed correctly
	MOV R11, #0					;Clear the flag before next attempt
	SUB R10, R10, #1			;Decrement the cycle counter
	CMP R10, #0					;Check if 15 times completed
	BNE PRELIMWAIT
	B	END_SUCCESS
	
;;Subroutine to turn on LED2, wait for ReactTime
;;turn off after ReactTime is over. If user presses
;;Black button, increment score counter
BLACK_LED2_ON
	LDR R2,=GPIOA_ODR
	LDR R1,=0xFBFF            	;10th bit is 0, so it turns on led2 at PA10
	STR R1,[R2]
	BL REACTTIME_WAIT_2			;Turn on for ReactTime
	LDR R6,=GPIOA_ODR           
    LDR R0,=0x1E00             	;turning off the light LED2	
	STR R0,[R6]                	
	CMP R11, #1					;If flag is set, it means button was pressed so increment score count
	BNE STOP_PLAY				;If flag is 0, UC3 Alternate Path: ReactTime expires
	ADD R9, R9, #1				;Increment score counter if button pressed correctly
	MOV R11, #0					;Clear the flag before next attempt
	SUB R10, R10, #1			;Decrement the cycle counter
	CMP R10, #0					;Check if 15 time completed
	BNE PRELIMWAIT				;keep continuing if less than 15
	B	END_SUCCESS				;Branch to UC4	

STOP_PLAY
	B GO_TO_UC5					;Branch to UC5 when user loses				

END_SUCCESS
	B GO_TO_UC4					;Branch to UC4 when user succeeds
	
	
;;Subroutine to turn on LED3, wait for ReactTime
;;turn off after ReactTime is over. If user presses
;;Blue button, increment score counter
BLUE_LED3_ON
	LDR R2,=GPIOA_ODR
	LDR R1,=0xF7FF            	;11th bit is 0, so it turns on led3 at PA11
	STR R1,[R2]
	BL REACTTIME_WAIT_3			;Turn on for ReactTime
	LDR R6,=GPIOA_ODR           
    LDR R0,=0x1E00             	;turning off the light LED3	
	STR R0,[R6]
	CMP R11, #1					;If flag is set, button was pressed, else discontinue
	BNE STOP_PLAY				;If flag is 0, UC3 Alternate Path: ReactTime expires
	ADD R9, R9, #1				;Increment score counter if button pressed correctly
	MOV R11, #0					;Clear the flag before next attempt
	SUB R10, R10, #1			;Decrement the cycle counter
	CMP R10, #0					;Check if 15 times completed
	BNE PRELIMWAIT
	B	END_SUCCESS

;;Subroutine to turn on LED4, wait for ReactTime
;;turn off after ReactTime is over. If user presses
;;Green button, increment score counter
GREEN_LED4_ON
	LDR R2,=GPIOA_ODR
	LDR R1,=0xEFFF            	;12th bit is 0, so it turns on led1 at PA12
	STR R1,[R2]
	BL REACTTIME_WAIT_4			;Turn on for ReactTime
	LDR R6,=GPIOA_ODR           
    LDR R0,=0x1E00             	;turning off the light LED4	
	STR R0,[R6]
	CMP R11, #1					;If flag is set, button was pressed, else discontinue
	BNE STOP_PLAY				;If flag is 0, UC3 Alternate Path: ReactTime expires
	ADD R9, R9, #1				;Increment score counter if button pressed correctly
	MOV R11, #0					;Clear the flag before next attempt
	SUB R10, R10, #1			;Decrement the cycle counter
	CMP R10, #0					;Check if 15 times completed
	BNE PRELIMWAIT
	B	END_SUCCESS
	ENDP
	
	ALIGN
;;React Time delay which keeps on decreasing
REACTTIME_WAIT_1 PROC
		POP {R6}				;Get last time's ReactTime
		LDR R7,=TIMEDIFF
		SUB R6, R6, R7			;Decrement the Reacttime on every call
		PUSH {R6}				;Push the updated ReactTime onto Stack			
LOOP3
WAIT_RED_BUTTON
		LDR R8,=GPIOB_IDR
		LDR R0,[R8]          	;reading the button 1 status in R0
		AND R0,#0x100       
		CMP R0,#0				;Wait for Red push button to be pressed
		BNE CONTINUE_DELAY1
		MOV R11, #1				;Set flag for pressing Pushbutton
		B WHACKED1				;If currect button is pressed, turn uff the LED
CONTINUE_DELAY1		
		SUB R6, R6, #0x1		;else continue timer
		CMP R6, #0x0
		BNE LOOP3
WHACKED1
		BX LR

		ENDP
			
		ALIGN
;;React Time delay which keeps on decreasing
REACTTIME_WAIT_2 PROC
		POP {R6}				;Get last time's ReactTime
		LDR R7,=TIMEDIFF
		SUB R6, R6, R7			;Decrement the Reacttime on every call
		PUSH {R6}				;Push the updated ReactTime onto Stack			
LOOP4
WAIT_BLACK_BUTTON
		LDR R8,=GPIOB_IDR
		LDR R0,[R8]          	;reading the button 2 status in R0
		AND R0,#0x200       
		CMP R0,#0				;Wait for Black push button to be pressed
		BNE CONTINUE_DELAY2
		MOV R11, #1				;Set flag for pressing Pushbutton
		B WHACKED2				;If currect button is pressed, turn uff the LED
CONTINUE_DELAY2		
		SUB R6, R6, #0x1		;else continue timer
		CMP R6, #0x0
		BNE LOOP4
WHACKED2
		BX LR

		ENDP
			
		ALIGN
;;React Time delay which keeps on decreasing
REACTTIME_WAIT_3 PROC
		POP {R6}				;Get last time's ReactTime
		LDR R7,=TIMEDIFF
		SUB R6, R6, R7			;Decrement the Reacttime on every call
		PUSH {R6}				;Push the updated ReactTime onto Stack			
LOOP5
WAIT_BLUE_BUTTON
		LDR R8,=GPIOC_IDR
		LDR R0,[R8]          	;reading the button 3 status in R0
		AND R0,#0x1000       
		CMP R0,#0				;Wait for Blue push button to be pressed
		BNE CONTINUE_DELAY3
		MOV R11, #1				;Set flag for pressing Pushbutton
		B WHACKED3
CONTINUE_DELAY3		
		SUB R6, R6, #0x1		;else continue timer
		CMP R6, #0x0
		BNE LOOP5
WHACKED3
		BX LR

		ENDP
			
			
		ALIGN
;;React Time delay which keeps on decreasing
REACTTIME_WAIT_4 PROC
		POP {R6}				;Get last time's ReactTime
		LDR R7,=TIMEDIFF
		SUB R6, R6, R7			;Decrement the Reacttime on every call
		PUSH {R6}				;Push the updated ReactTime onto Stack			
LOOP6
WAIT_GREEN_BUTTON
		LDR R8,=GPIOA_IDR
		LDR R0,[R8]          	;reading the button 4 status in R0
		AND R0,#0x20       
		CMP R0,#0				;Wait for Green push button to be pressed
		BNE CONTINUE_DELAY4
		MOV R11, #1				;Set flag for pressing Pushbutton
		B WHACKED4
CONTINUE_DELAY4		
		SUB R6, R6, #0x1		;else continue timer
		CMP R6, #0x0
		BNE LOOP6
WHACKED4
		BX LR

		ENDP
			
			
;;Usercase 4: The user has won the game and has been able to hit all the buttons
;;in time to give a score of 15 displayed in R9. In UC4, the specific display
;;pattern is displayed on the 4 LEDs by blinking LED4 and LED1 simultaneouly
;;for 0.5s,and then blinking LED2 and LED3 simultaneously
;;for next 0.5s and then repeating this pattern for about 10 seconds which is the 
;;WinningSignalTime that signifies winning of the game and then display the score 
;;of the user using the LED's e.g if user has won 15 times in a row, then the LED
;;should display all ON which is binary equivalent of 15 (1111). This is shown for 
;;1 minute and then game returns to UC2.To achive these steps in this order
;;		- Load the WinningSignalTime in register
;;		- Load the display pattern by enabling GPIOx_ODR.Also if in the display pattern 
;;		  some count is required, that is also loaded into registers
;;		- Generate specified pattern and then load a counter of 1 minute in register
;;		- Start decrementing the counter and display the proficiency level
;;		- Proficiency level is set as 15 (1111) as the user has passed 15 levels.
		
	ALIGN
UC4 PROC
	
	LDR R5,=WINNINGSIGNALTIME			;Load WinningSignalTime counter in R5
LOOP7	
;;Generate winning LED pattern. LED1 and LED3 are turned on. LED2 and LED4 are turned off
	LDR R0,=GPIOA_ODR
	LDR R1,=0xF5FF            			;turns on led1 at PA9 and led3 at PA11
	STR R1,[R0]
	;wait for  a delay
	BL DELAY2
;;LED1 and LED3 are turned off. LED2 and LED4 are turned on
	LDR R0,=GPIOA_ODR
	LDR R1,=0xEBFF            			;turns on led2 at PA10 and led4 at PA12
	STR R1,[R0]	
	BL DELAY2
	SUB R5, R5, #1						;Decrement WinningSignalTime count
	CMP R5, #0
	BNE LOOP7
	
;;After this, display the proficiency level of user
	LDR R0,=GPIOA_ODR
	LDR R1,=0xE1FF            			;turns on all the LED's
	STR R1,[R0]
	MOV R7, #0x0						;Clear the 1 minute counter
	;Wait for 1 minute 
LOOP8
	BL DELAY
	ADD R7, R7, #1
	CMP R7, #120							
	BNE LOOP8							;Delay till 1 minute
	;Turn off the LED's
	LDR R0,=GPIOA_ODR
	LDR R1,=0x1EFF            			;turns off all the LED's
	STR R1,[R0]
	B UC2
	ENDP
		
		
;;Usercase 5: The user has lost the game and the losing signal
;;will be displayed on the 4 LEDs where losing signal is the
;;score of the user in binary in flashing pattern eg.If user
;;has scored 9 before losing, then the binary value is 1001 and
;;so LED4 and LED1 will be flashing.This pattern is continued
;;for LosingSignalTime and after that control is returned to
;;UC2 subroutine. The steps which needs to be followed are:
;;		- Load the LosingSignalTime signal into register and
;;		  start decrementing the counter till 0.
;;		- Meanwhile, get the binary equivalent of the score in R9
;;		  by doing a UDIV and SUB to get the mod of R9 by 10 and
;;		  dividing R9 by 10. Based on this information, the
;;		  respective LEDs are enabled by writing to GPIOx_ODR in
;;		  active low state.
;;		- After completing this, branching to UC2 is done.

	ALIGN
UC5	PROC
	
	LDR R7,=LOSINGSIGNALTIME
	;Get binary equivalent of R9 and store the digits in different registers
	;Thus we will store the bits from R3 to R0 MSB to LSB
	MOV R6, #0
	MOV R8, #2
	;To get binary bits of R9, the procedure followed is
	; while(R9 > 0)
	; {
	;    remainder = R9 mod 2
	;    R9 = R9/2
	; }
	;As Cortex M3 doesn't support mod operation, we need to follow subroutine
	;to achieve this
	UDIV R0, R9, R8					;R9/2
	MUL R0, R0, R8					;quotient*2
	SUB R0, R9, R0					;Remainder = dividend - (quotient *divisor)
	UDIV R9, R9, R8					;R9=R9/2
	
	UDIV R1, R9, R8					
	MUL R1, R1, R8					
	SUB R1, R9, R1					
	UDIV R9, R9, R8

	UDIV R2, R9, R8					
	MUL R2, R2, R8					
	SUB R2, R9, R2					
	UDIV R9, R9, R8
	
	UDIV R3, R9, R8					
	MUL R3, R3, R8					
	SUB R3, R9, R3					
	UDIV R9, R9, R8
	
	MOV R5, #0xFFFF

LOOP13
	;Turn on specific LEDs based on the binary digits
	CMP R3, #1
	BNE SWITCH_1
	LDR R11,=GPIOA_ODR
	LDR R10, [R11]						;Read the contents of GPIOA_ODR
	EOR R10, R10, R5				;Invert the logic of GPIOA_ODR
	ORR R10, R10, #0x1000				;OR with 12th bit set to enable LED4
	EOR R10, R10, R5				;INvert again to original with 12th bit cleared
	MOV R12, R10
	STR R12,[R11]
SWITCH_1	
	CMP R2, #1
	BNE SWITCH_2
	LDR R11,=GPIOA_ODR
	LDR R10, [R11]						;Read the contents of GPIOA_ODR
	EOR R10, R10, R5				;Invert the logic of GPIOA_ODR
	ORR R10, R10, #0x0800				;OR with 11th bit set to enable LED3
	EOR R10, R10, R5				;Invert again to original with 11th bit cleared
	MOV R12, R10
	STR R12,[R11]
SWITCH_2	
	CMP R1, #1
	BNE SWITCH_3
	LDR R11,=GPIOA_ODR
	LDR R10, [R11]						;Read the contents of GPIOA_ODR
	EOR R10, R10, R5				;Invert the logic of GPIOA_ODR
	ORR R10, R10, #0x0400				;OR with 10th bit set to enable LED2
	EOR R10, R10, R5				;Invert again to original with 10th bit cleared
	MOV R12, R10
	STR R12,[R11]
SWITCH_3	
	CMP R0, #1
	BNE TURN_OFF1
	LDR R11,=GPIOA_ODR
	LDR R10, [R11]						;Read the contents of GPIOA_ODR
	EOR R10, R10, R5				;Invert the logic of GPIOA_ODR
	ORR R10, R10, #0x0200				;OR with 9th bit set to enable LED1
	EOR R10, R10, R5				;Invert again to original with 9th bit cleared
	MOV R12, R10
	STR R12,[R11]
	
	
TURN_OFF1
	
	;Switch on till a small delay before switching off to give an effect of Flashing
	BL DELAY
	BL DELAY
	
	;Turn off the LEDs
	LDR R11,=GPIOA_ODR
	LDR R12,=0x1E00
	STR R12, [R11]
	
	;Switch off till a small delay before switching on to give an effect of Flashing
	BL DELAY
	BL DELAY
	
	SUB R7, R7, #1
	CMP R7, #0
	BNE LOOP13
	B UC2
	LTORG 
	ENDP
	
 

	ALIGN
;;Delay2 
DELAY2		PROC
	
		;Complete the delay function
		LDR R6, =WINDELAYTIME

LOOP10
		SUB R6, R6, #0x1
		CMP R6, #0x0
		BNE LOOP10 
        BX LR

		ENDP	
	
	ALIGN	
;;Delay 
DELAY		PROC
	
	;Complete the delay function
	LDR R6, =DELAYTIME

LOOP
	;;Waiting for player to press Red button
	
	LDR R8,=GPIOB_IDR    	;Load the input address for button1 and 2, PB8	
	LDR R4,[R8]          	;reading the button 1 status in R0		
	AND R4,#0x100        	;sets bit 8 as 1
    LSR R4, #8				;right shift by 8
	CMP R4,#0            	;if 0, means button 1 is pressed
	BEQ UC2_FINISH
	
	;;Waiting for player to press Black button
	
	LDR R8,=GPIOB_IDR    	;Load the input address for button1 and 2, PB8	
	LDR R4,[R8]          	;reading the button 1 status in R0		
	AND R4,#0x200        	;sets bit 8 as 1
    LSR R4, #9				;right shift by 8
	CMP R4,#0            	;if 0, means button 1 is pressed
	BEQ UC2_FINISH
	
	;;Waiting for player to press Blue button
	
	LDR R8,=GPIOC_IDR 		;Load Port input data register address for PC12, button3	
	LDR R4,[R8]          	;reading the button 1 status in R0		
	AND R4,#0x1000        	;sets bit 8 as 1
    LSR R4, #12				;right shift by 8
	CMP R4,#0            	;if 0, means button 1 is pressed
	BEQ UC2_FINISH
	
	;;Waiting for player to press Green button
	
	LDR R10,=GPIOA_IDR     	;Load Port A5 Input Data Register address, button4	
	LDR R4,[R10]			;reading the button 4 status in R0
    AND R4,#0x20
	LSR R4, #5
    CMP R4,#0				;if 0, means button 4 is pressed
    BEQ UC2_FINISH
		
	SUB R6, R6, #0x1
	CMP R6, #0x0
	BNE LOOP 
    BX LR
	ENDP
			


;;Random number generation subroutine
	ALIGN
RANDOM_NUM_GEN PROC	
	
	LDR R4,=A					;Load the constant A
	LDR R1, [R5]				;Load the Xn seed from memory 0x20001008
	MUL R6, R4, R1				;(A * Xn)
	LDR R4,=C					;Load the constant C
	ADD R7, R4, R6				;Xn+1 = (A*Xn  +  C)  random seed
	STR R7, [R5]				;Store the updated Xn in memory 
	LSR R7, #30					;Extract bits 31,30 of the Xn+1 by right shifting by 30
	MOV R0, R7
	BX LR
	ENDP
	
	ALIGN
	END