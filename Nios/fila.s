.include "nios_macros.s"
.equ sws, 0x00003000
.equ leds, 0x00003010
.global _start

_start:	mov r2, 0 ;r2 é o registrador de começo da fila
		mov r3, 0 ;r3 é o registrador de fim da fila
		movia r5, sws
		movia r6, leds


loop:	ldbio r4, 0(r5)
		mov r7, 1
		and r8, r4, r7
		bne r0, r8, jkey1
		
	stbio r4,0(r6)
	br loop
	
jkey1:	