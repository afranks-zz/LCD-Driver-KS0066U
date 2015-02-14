/*
 * LCD_Driver.asm
 *
 *  Created: 1/28/2015 5:35:47 PM
 *   Author: Adam
 */ 
; WIP. Delays currently used instead of checking if the LCD is busy. Not really optimal.
.ORG 0x000
rjmp main



main:

ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

call loadmem

ldi r16, 32
call delayxms


ldi r17, 0x3F
out DDRD, r17

ldi r16, 16
rcall delayxms

ldi r17, 0x02
rcall sendinstr

ldi r17, 0x02
rcall sendinstr

ldi r17, 0x0C
rcall sendinstr

ldi r16, 1
rcall delayxms

ldi r17, 0x00
rcall sendinstr

ldi r17, 0x0C
rcall sendinstr

ldi r16, 1
rcall delayxms

ldi r17, 0x00
rcall sendinstr

ldi r17, 0x01
rcall sendinstr

ldi r16, 2
rcall delayxms

ldi r17, 0x00
rcall sendinstr

ldi r17, 0x06
rcall sendinstr




; This just loads the initial message. You can also just send letters instead.
ldi yh, 0x01
ldi yl, 0x00
rcall rsletter

rjmp fin

rsletter:
ld xl, y+
tst xl
breq rsdone
mov xh, xl
andi xl, 0x0F
lsr xh
lsr xh
lsr xh
lsr xh
rcall delay1ms_looping
rcall sendletter
rjmp rsletter

rsdone:
ret


fin:
rjmp fin

delayxms: ; 4
rcall delay1ms_looping ; 16000 per call
dec r16 ; 1
brne delayxms ; 2/1
ret ; 4



delay1ms_looping:
; 4 cycles to call
ldi zl, 0xe7 ; 1 cycle
ldi zh, 0x03 ; 1 cycle
push r0 ; 2
pop r0 ; 2
nop ; 1

delayxus_loop: ; x -> 0x03E7 = ~1 ms

call delay1us_floop
sbiw z, 1 ; 2 cycles
brne delayxus_loop ; 1/2 cycles

ret ; 4 cycles

delay1us_floop:
; 4 cycles to call
push r0 ; 2
pop r0 ; 2

ret ; 4 cycles

delay1us:
; 4 cycles to call
push r0 ; 2
push r1 ; 2
pop r1 ; 2
pop r0 ; 2

ret ; 4 cycles


sendinstr:
out PORTD, r17
sbi PORTD, 4
cbi PORTD, 4

rcall delay1us

ret

sendletter:
out PORTD, xh
sbi PORTD, 5
sbi PORTD, 4
cbi PORTD, 4
cbi PORTD, 5

out PORTD, xl
sbi PORTD, 5
sbi PORTD, 4
cbi PORTD, 4
cbi PORTD, 5


rcall delay1us

ret

loadmem:

ldi zh, HIGH(name*2)
ldi zl, LOW(name*2)
ldi yh, 0x01
ldi yl, 0x00

loadloop:
lpm r0, z+
st y+, r0
tst r0
brne loadloop
ret

name:
.db "INITIAL MSG",0


