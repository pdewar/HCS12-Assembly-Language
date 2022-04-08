#include "reg9s12.h"

lcd_dat 	equ	PortK   	; LCD data pins (PK5~PK2)
lcd_dir 	equ   	DDRK    	; LCD data direction port
lcd_E   	equ   	$02     	; E signal pin
lcd_RS  	equ   	$01     	; RS signal pin

	org	$1000
counter	rmb	1

	org   	$2000
	lds   	#$2000  	; set up stack pointer
	jsr   	openLCD 	; initialize the LCD
	ldx   	#msg1		; point to the first line of message
	jsr   	putsLCD		; display in the LCD screen
	ldaa	#$C0		; move to the second row 
	jsr	cmd2LCD	;	"
	ldx   	#msg2		; point to the second line of message
	jsr   	putsLCD

; here add instructions to shift the display to see the whole sentence,
	ldaa	#14	;loop shifts diplay to the left by 14
	staa	counter
loop	ldaa	#$18
	jsr	cmd2lcd
	jsr	delay
	dec	counter
	bne	loop	
	
	ldaa	#14	;loop shifts display to the right by 14
	staa	counter
loopy	ldaa	#$1C
	jsr	cmd2lcd
	jsr	delay
	dec	counter
	bne	loopy

	swi


msg1 	dc.b   	"Hello world!",0
msg2 	dc.b  	"My name Peter Dewar",0


; additional delay loop to slow down the display shift 
delay	ldab	#$4F		
delay1	ldx	#$FFFF	;	
delay2	dbne	x,delay2	;	
	dbne	b,delay1		;	
	rts

; the command is contained in A when calling this subroutine from main program
cmd2LCD	psha				; save the command in stack
	bclr  	lcd_dat, lcd_RS	; set RS=0 for IR => PTK0=0
	bset  	lcd_dat, lcd_E 	; set E=1 => PTK=1
	anda  	#$F0    	; clear the lower 4 bits of the command
	lsra 			; shift the upper 4 bits to PTK5-2 to the 
	lsra            	; LCD data pins
	oraa  	#$02  		; maintain RS=0 & E=1 after LSRA
	staa  	lcd_dat 	; send the content of PTK to IR 
	nop			; delay for signal stability
	nop			; 	
	nop			;	
	bclr  	lcd_dat,lcd_E   ; set E=0 to complete the transfer

	pula			; retrieve the LCD command from stack
	anda  	#$0F    	; clear the lower four bits of the command
	lsla            	; shift the lower 4 bits to PTK5-2 to the
	lsla            	; LCD data pins
	bset  	lcd_dat, lcd_E 	; set E=1 => PTK=1
	oraa  	#$02  		; maintain E=1 to PTK1 after LSLA
	staa  	lcd_dat 	; send the content of PTK to IR
	nop			; delay for signal stability
	nop			;	
	nop			;	
	bclr  	lcd_dat,lcd_E	; set E=0 to complete the transfer

	ldy	#1		; adding this delay will complete the internal
	jsr	delay50us	; operation for most instructions
	rts

openLCD movb	#$FF,lcd_dir		; configure Port K for output
	ldy   	#2		; wait for LCD to be ready
	jsr   	delay100ms	;	"
	ldaa  	#$28            ; set 4-bit data, 2-line display, 5 × 8 font
	jsr   	cmd2lcd         ;       "	
	ldaa  	#$0F            ; turn on display, cursor, and blinking
	jsr   	cmd2lcd         ;       "
	ldaa  	#$06             ; move cursor right (entry mode set instruction)
	jsr   	cmd2lcd         ;       "
	ldaa  	#$01            ; clear display screen and return to home position
	jsr   	cmd2lcd         ;       "
	ldy   	#2              ; wait until clear display command is complete
	jsr   	delay1ms   	;       "
	rts 	

; The character to be output is in accumulator A.
putcLCD	psha                    ; save a copy of the chasracter
	bset  	lcd_dat,lcd_RS	; set RS=1 for data register => PK0=1
	bset  	lcd_dat,lcd_E  	; set E=1 => PTK=1
	anda  	#$F0            ; clear the lower 4 bits of the character
	lsra           		; shift the upper 4 bits to PTK5-2 to the
	lsra            	; LCD data pins
	oraa  	#$03            ; maintain RS=1 & E=1 after LSRA
	staa  	lcd_dat        	; send the content of PTK to DR
	nop                     ; delay for signal stability
	nop                     ;      
	nop                     ;     
	bclr  	lcd_dat,lcd_E   ; set E=0 to complete the transfer

	pula			; retrieve the character from the stack
	anda  	#$0F    	; clear the upper 4 bits of the character
	lsla            	; shift the lower 4 bits to PTK5-2 to the
	lsla            	; LCD data pins
	bset  	lcd_dat,lcd_E   ; set E=1 => PTK=1
	oraa  	#$03            ; maintain RS=1 & E=1 after LSLA
	staa  	lcd_dat		; send the content of PTK to DR
	nop			; delay for signal stability
	nop			;
	nop			;
	bclr  	lcd_dat,lcd_E   	; set E=0 to complete the transfer

	ldy	#1		; wait until the write operation is complete
	jsr	delay50us	; 
	rts


putsLCD	ldaa  	1,X+   		; get one character from the string
	beq   	donePS		; reach NULL character?
	jsr   	putcLCD
	bra   	putsLCD
donePS	rts 


delay1ms 	movb	#$90,TSCR	; enable TCNT & fast flags clear
		movb	#$06,TMSK2 	; configure prescale factor to 64
		bset	TIOS,$01		; enable OC0
		ldd 	TCNT
again0		addd	#375		; start an output compare operation
		std	TC0		; with 50 ms time delay
wait_lp0		brclr	TFLG1,$01,wait_lp0
		ldd	TC0
		dbne	y,again0
		rts

delay100ms 	movb	#$90,TSCR	; enable TCNT & fast flags clear
		movb	#$06,TMSK2 	; configure prescale factor to 64
		bset	TIOS,$01		; enable OC0
		ldd 	TCNT
again1		addd	#37500		; start an output compare operation
		std	TC0		; with 50 ms time delay
wait_lp1		brclr	TFLG1,$01,wait_lp1
		ldd	TC0
		dbne	y,again1
		rts

delay50us 	movb	#$90,TSCR	; enable TCNT & fast flags clear
		movb	#$06,TMSK2 	; configure prescale factor to 64
		bset	TIOS,$01		; enable OC0
		ldd 	TCNT
again2		addd	#15		; start an output compare operation
		std	TC0		; with 50 ms time delay
wait_lp2		brclr	TFLG1,$01,wait_lp2
		ldd	TC0
		dbne	y,again2
		rts

		end

;The program displays hello world! on the top line op the display
;And dsiplays my name on the second line of the display
;The dsiplay shifts to show my full name completely
