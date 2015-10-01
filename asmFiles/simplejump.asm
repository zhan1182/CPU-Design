
	org 0x0000
	ori $2, $0, 0x1234
	ori $3, $0, 0x1234
	j jumptarget
	ori $4, $0, 0x1234
	ori $5, $0, 0x1234
	ori $6, $0, 0x1234

jt2:
	halt


jumptarget:
	ori $7, $0, 0x1234
	ori $8, $0, 0x1234
	ori $9, $0, 0x1234
	ori $10, $0, 0x1234
	j jt2
