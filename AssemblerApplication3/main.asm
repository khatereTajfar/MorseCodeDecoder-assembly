;
; AssemblerApplication3.asm
;
;



.INCLUDE "M32DEF.INC"

.def half_seconds = R17
.def string = R18
.def shift = R19

.org 0x0
	rjmp Main

.org 0x002
	rjmp EXT0_ISR	;for _

.org 0x0006
	rjmp EXT2_ISR	;for .

.org 0x000E
	rjmp T1OCR_ISR


.org 0x0100
Main: ldi r16,High(RAMEND)
	  out sph,r16
	  ldi r16,low(RAMEND)
	  out spl,r16


	  ldi r16,0x00
	  out mcucr,r16

	  ldi r16,1<<ISC2	
	  out mcucsr,r16

	  ldi r16,0xff
	  out ddrc,r16
	  sbi DDRD,2
	  sbi DDRB,2
	  sbi portd,2

	  ldi r16,(1<<INT0) |( 1<<INT2)
	  out gicr,r16
	  sei

	  HERE: jmp HERE

.org 0x0200
EXT0_ISR:
	
	lsl string
	inc shift
	inc string
	ldi half_seconds,0
	call Init_Timer
	reti

.org 0x0300
EXT2_ISR:

	lsl string 
	inc shift
	ldi half_seconds,0
	call Init_Timer
	reti

.org 0x0400
T1OCR_ISR:

	inc half_seconds
	
	
	in r16,PIND   ;11111011
	in r23,PinB	  ;00000100
	and r16,r23
	sbrc r16,2
	jmp end_interrupt	;at least one of the keys was pushed

	cpi half_seconds,1
	brne continue_interrupt
	call Output
	rjmp end_interrupt
continue_interrupt:
	cpi half_seconds,2
	brne end_interrupt
	ldi string,0
	ldi shift,0

end_interrupt:
	reti

.org 0x0500
Init_Timer:
	ldi r16,(1<<OCIE1A)
	out TIMSK,r16
	ldi r16,0
	out TCCR1A,r16
	ldi r16,0x0d
	out TCCR1B,r16
	ldi r16,0
	out TCNT1H,r16
	ldi r16,0
	out TCNT1L,r16
	ldi r16,High(3906)
	out OCR1AH,r16
	ldi r16,Low(3906)
	out OCR1AL,r16
	
	ret

;a=1,2 e=0,1 i=0,2 o=7,3 u=1,3


.org 0x0600
Output:

	cpi shift,1
	brne not_e
	cpi string,0
	brne not_e
	ldi r16,2
	out Portc,r16
	rjmp end_output
not_e:
	cpi shift,2
	brne not_eai
	cpi string,1
	brne not_ea
	ldi r16,1
	out Portc,r16
	rjmp end_output
not_ea:
	cpi string,0
	brne not_eai
	ldi r16,4
	out Portc,r16
	rjmp end_output
not_eai:
	cpi shift,3
	brne end_output
	cpi string,7
	brne not_eaio
	ldi r16,8
	out Portc,r16
	rjmp end_output
not_eaio:
	cpi string,1
	brne end_output
	ldi r16,16
	out Portc,r16
end_output:
	ret
	
	
