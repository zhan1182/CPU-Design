Init:
	org 0x0000
	ori $29, $0, 0xfffc

	ori $2, $0, 20 // current day
	
	ori $3, $0, 7 // current month - 1
	ori $4, $0, 15 // current year - 2000

	ori $5, $0, 30
	ori $6, $0, 365

	//push $0
	push $3
	push $5
	push $4
	push $6

stack:	pop $7
	pop $8
	bne $7, $0, loop
	j exit

exit:	add $9, $9, $2
	halt

loop:	add $9, $9, $7
	addi $8, $8, -1
	bne $8, $0, loop
	j stack
