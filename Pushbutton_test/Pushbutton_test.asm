#include "reg9s12.h"			; include this file in the directory

	org	$2000		; 
	movb	#$FF, DDRB	; set port B as output for all 8 LEDs
	bset	DDRJ, $02	; set port J bit 1 as output (required by Dragon12+)
	bclr	PTJ, $02	; turn off port J bit 1 to enable LEDs
	movb	#$FF, DDRP	; set port P as output  
	movb	#$0F, PTP	; turn off 7-segment displays (in Dragon12+)

	movb	#$00, DDRH	; set port H as input for DIP switches

main	ldaa	#00
	brclr	PTH,$03,pattern1
	jsr	delay		; generate the desired delay (optional)
	jmp	main
pattern1	ldaa	#$01
	staa	PortB		; output to LEDs 
	jmp	main		; start over 

; delay subroutine; use 2 loops to set the desired delay
delay:	ldab	#$40			; adjust the value to change the time delay
delay1:	ldx	#$FFFF		 
delay2:	dbne	x,delay2
	dbne	b,delay1
	rts
	end