Init:
	org 0x0000
	ori $29, $0, 0xfffc

	ori $4, $0, 4 //A
	ori $8, $0, 4 //B
	
	push $8
	push $4


	pop $12 //pop A
	pop $16 //pop B

	
	
loop:	add $14, $14, $12
	addi $16, $16, -1
	bne $16, $0, loop
	
	
exit:	push $14
	halt
