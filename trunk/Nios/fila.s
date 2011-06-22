.include "nios_macros.s"
.equ sws, 0x00003000
.equ leds, 0x00003010
.global _start

_start:	movi r18, 1				#r18 armazena a posicao do primeiro elemento da fila
		movi r13, 1				#r13 armazena a posicao do ultimo elemento da fila
		movi r17, 0				#r17 armazena o ultimo estado da primeira chave
		movi r16, 0				#r16 armazena a fila
		movi r2, 1
		movia r21, sws
		movia r22, leds


loop:	ldbio r20, 0(r21)		#carrega em r20 o conteudo da posicao de memoria
		andi r23, r20, 1		#r23 recebe o and entre r20 e o numero 1 para pegar o primeiro bit da entrada
		beq r0, r23, jkey0		#se a chave está em zero ele apenas mostra o resultado
		beq r17, r23, jkey0		#se a chave não voltou para zero desde a ultima operacao ele não se repete
		
		ldbio r20, 0(r21)		#carrega em r20 o conteudo da posicao de memoria
		andi r14, r20, 2		#r23 recebe o and entre r20 e o numero 2 para pegar o segundo bit da entrada
		beq r0, r14, push		#Se o segundo switch for igual a zero faz o push, se for diferente faz o pop
								#Comeco do pop
		sub r16, r16, r13		#Remove o elemento no comeco da fila fazendo uma subtração dele
		slli r13, r13, 1		#Movimenta a posicao do comeco da fila
		br jkey0				#Terminado o pop ele deve seguir para jkey0 para exibir na saida os valores apropriados
		
push:	
		slli r16, r16, 1		#Shift left para deslocar todos os bits para a esquerda, acrescentando uma posição no comeco da fila
		add r16, r16, r13		#Seta 1 no bit menos significativo, que ficou zero devido ao shift left
		roli r18, r18, 1		#Movimenta a posicao do comeco da fila 
		
jkey0:							#Finished 
		mov r17, r23			#Armazena o estado do switch para determinar se a operação deve ser feita no proximo ciclo
		stbio r16,0(r22)		#Escreve na saida o conteudo da fila armazenada em r16
		br loop			
		
		
	
jkey1:	