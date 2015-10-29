
INIT:
	org 0x0000

	ori $29, $0, 0xfffc
	
	ori $2, $0, 0x0002
	ori $3, $0, 0x0003
	ori $4, $0, 0x0004

	ori $5, $0, 0xfff8

	push $2
	push $3
	push $4

MAIN:	
	beq $29, $5, EXIT

	pop $7
	pop $6
	
	beq $6, $0, ZERO
	beq $7, $0, ZERO
	ori $8, $6, 0x0000
	addi $7, $7, -1
	beq $7, $0, OUTPUT
	
LOOP:
	add $8, $8, $6
	addi $7, $7, -1
	beq $7, $0, OUTPUT
	j LOOP
	
OUTPUT:
	push $8
	j MAIN

ZERO:
	push $0
	j MAIN
	
EXIT:
	halt
