#include "reg9s12.h"			; include this file in the directory

led0:	equ	$01		; 0000 0001 => PB0=1 for LED0
led1:	equ	$02		; 0000 0010 => PB1=1  for LED1
led2:	equ	$04		; 0000 0100 => PB2=1  for LED2
led3:	equ	$08		; 0000 1000 => PB3=1  for LED3
led4:	equ	$10		; 0001 0000 => PK4=1  for LED4
led5:	equ	$20		; 0010 0000 => PK5=1  for LED5
led6:	equ	$40		; 0100 0000 => PK6=1  for LED6
led7:	equ	$80		; 1000 0000 => PK7=1  for LED7

	org	$2000		
	movb	#$FF, DDRB	; set bits 0-3 of port B as output (how about $FF?)
	bset	DDRJ, $02	; set port J bit 1 =1 for output (in Dragon12 board)
	bclr	PTJ, $02	; set port J bit 1 =0 to enable the LEDs 

	movb	#$FF, DDRP	; set port P as output
	movb	#$0F, PTP	; turn off 7-segment displays (in Dragon12 board)

; clear all bits to turn off LED0-3 connected PortB bits 0-3
	bclr	PortB,led0+led1+led2+led3+led4+led5+led6+led7
	jsr	delay			; generate the desired delay

main	bset	PortB, led0		; LED 0 on; 
	jsr	delay			; generate the desired delay
	bclr	portB, led0		; LED 0 off; 
	jsr	delay

	bset	PortB, led1		; LED 1
	jsr	delay
	bclr	PortB, led1
	jsr	delay

	bset	PortB, led2		; LED 2
	jsr	delay
	bclr	PortB, led2
	jsr	delay

	bset	PortB, led3		; LED 3
	jsr	delay
	bclr	PortB, led3 
	jsr	delay

	bset	PortB, led4		; LED 4
	jsr	delay
	bclr	PortB, led4
	jsr	delay

	bset	PortB, led5		; LED 5
	jsr	delay
	bclr	PortB, led5
	jsr	delay

	bset	PortB, led6		; LED 6
	jsr	delay
	bclr	PortB, led6
	jsr	delay

	bset	PortB, led7		; LED 7
	jsr	delay
	bclr	PortB, led7
	jsr	delay

	jmp	main			; start over 

; delay subroutine; use 2 loops to set the desired time delay
delay:	ldab	#$40			; adjust the value to change blinking rate
delay1:	ldx	#$FFFF		 
delay2:	dbne	x,delay2
	dbne	b,delay1
	rts
	end

; light up all 8 LEDs one by one consecutively from left most led to right most led