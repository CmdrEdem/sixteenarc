.include "nios_macros.s"
.equ sws, 0x00003000
.equ leds, 0x00003010
.global _start

_start:	movia r2,sws
	movia r3,leds
loop:	ldbio r4,0(r2)
	stbio r4,0(r3)
	br loop