

#----------------------------------------------------------
# First Processor
#----------------------------------------------------------
	org   0x0000              # first processor p0
	ori   $sp, $zero, 0x3ffc  # stack, stack pointer is to the 0x3ffc. load address, save address
	#ori   $gp, $zero, 0x700  # init the global pointer, point to the beginning of the buffer
	ori   $a3, $zero, 0x800  # init the shared address
	ori   $a2, $zero, 0x728  # the end of the buffer
	ori   $s7, $zero, 0      # init producer counter
	ori   $s6, $zero, 255    # init producer total
	ori   $s0, $zero, 1	# init seed as 1, $s0 stores the tmp value
generate:
	beq   $s6, $s7, exit_1
	jal   produce
	j     generate
exit_1:
	lw    $gp, 0($a3)
	lw    $s1, -4($gp)
	halt

produce:
	push $ra
	
	# Get the lock
	ori $a0, $zero, lock_value
	jal lock

	# Check buffer address, if buffer is full, return
	lw $gp, 0($a3)
	beq $gp, $a2, produce_return
	
	# Call the sub-routine, generate next random number
	or  $a0, $s0, $zero	# put the seed into $a0
	jal crc32
	sw $v0, 0($gp)

	# Update seed and increment buffer address, increment the total produced number
	or $s0, $zero, $v0 # put v0 into s0 for next produce
	addi $gp, $gp, 4
	addi $s7, $s7, 1

	# Save the buffer address to the shared address
	sw $gp, 0($a3)

produce_return:	
	# Unlock
	ori $a0, $zero, lock_value
	jal unlock
	
	# Return
	pop $ra
	jr $ra
	
# pass in an address to lock function in argument register 0
# returns when lock is available
lock:
aquire:
	ll    $t0, 0($a0)         # load lock location, $gp saves the putting address of the producer
	bne   $t0, $0, aquire     # wait on lock to be open
	addiu $t0, $t0, 1
	sc    $t0, 0($a0)
	beq   $t0, $0, lock       # if sc failed retry
	jr    $ra


# pass in an address to unlock function in argument register 0
# returns when lock is free
unlock:
	sw    $0, 0($a0)
	jr    $ra
	
#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
	org   0x200               # second processor p1
	ori   $sp, $zero, 0x7ffc  # stack
	ori   $a3, $zero, 0x800  # init the shared address
	ori   $a2, $zero, 0x700  # the begin of the buffer
	ori   $s5, $zero, 0x900  # init the resutls mem address
	ori   $s4, $zero, 0xffff # lower 16 bits mask
	ori   $s7, $zero, 0      # init consumer counter
	ori   $s6, $zero, 255    # init consumer total

consume_begin:
	beq $s6, $s7, exit_2
	jal   consume
	j consume_begin
exit_2:	
	lw $s0, 0($s5) # load the max
	lw $s1, 4($s5) # load the min
	lw $s2, 8($s5) # load the sum
	
	halt

consume:
	push	$ra

	# Get the lock
	ori $a0, $zero, lock_value
	jal lock

	# load the buffer address, return if at the beginning of the buffer
	lw $gp, 0($a3)
	beq $gp, $a2, consume_return

	# Load buffer value
	addi $gp, $gp, -4
	lw $s3, 0($gp)

	# Get the lower 16 bits
	and $s3, $s3, $s4
	
	# Load the 3 results
	lw $s0, 0($s5) # load the max
	lw $s1, 4($s5) # load the min
	lw $s2, 8($s5) # load the sum

	# Add the new value to the sum, store the sum back to mem
	add $s2, $s2, $s3
	sw $s2, 8($s5)
	
	# Call the max sub-routine
	or $a0, $zero, $s0
	or $a1, $zero, $s3
	jal max

	# Save the max back to mem
	sw $v0, 0($s5)

	
	# Call the min sub-routine
	or $a0, $zero, $s1
	or $a1, $zero, $s3
	jal min

	# Save the max back to mem
	sw $v0, 4($s5)	

	# increment the total consumed number
	addi $s7, $s7, 1

	# Save the buffer address to the shared address
	sw $gp, 0($a3)

	
consume_return:	
	# Unlock
	ori $a0, $zero, lock_value
	jal unlock
	
	pop	$ra
	jr	$ra

#################################### Init buffer ###################################
	org 0x700 # address of buffer
	cfw 0x0000 #1
	cfw 0x0000 #2
	cfw 0x0000 #3
	cfw 0x0000 #4
	cfw 0x0000 #5
	cfw 0x0000 #6
	cfw 0x0000 #7
	cfw 0x0000 #8
	cfw 0x0000 #9
	cfw 0x0000 #10

#################################### Init counter ###################################
	org 0x800 # shared buffer address
	cfw 0x700
	

#################################### Init results ###################################
	org 0x900 # address of results
	cfw 0x0000 # Max
	cfw 0xffff # Min
	cfw 0x0000 # Total

#################################### Lock Value ####################################
lock_value:
	cfw 0x0000


#################################### Generate Random ################################
	
#REGISTERS
#at $1 at
#v $2-3 function returns
#a $4-7 function args
#t $8-15 temps
#s $16-23 saved temps (callee preserved)
#t $24-25 temps
#k $26-27 kernel
#gp $28 gp (callee preserved)
#sp $29 sp (callee preserved)
#fp $30 fp (callee preserved)
#ra $31 return address

# USAGE random0 = crc(seed), random1 = crc(random0)
#       randomN = crc(randomN-1)
#------------------------------------------------------
# $v0 = crc32($a0)
crc32:
  lui $t1, 0x04C1
  ori $t1, $t1, 0x1DB7
  or $t2, $0, $0
  ori $t3, $0, 32

l1:
  slt $t4, $t2, $t3
  beq $t4, $zero, l2

  srl $t4, $a0, 31
  sll $a0, $a0, 1
  beq $t4, $0, l3
  xor $a0, $a0, $t1
l3:
  addiu $t2, $t2, 1
  j l1
l2:
  or $v0, $a0, $0
  jr $ra
#------------------------------------------------------

###################################################### Divide ############################

# registers a0-1,v0-1,t0
# a0 = Numerator
# a1 = Denominator
# v0 = Quotient
# v1 = Remainder

#-divide(N=$a0,D=$a1) returns (Q=$v0,R=$v1)--------
divide:               # setup frame
  push  $ra           # saved return address
  push  $a0           # saved register
  push  $a1           # saved register
  or    $v0, $0, $0   # Quotient v0=0
  or    $v1, $0, $a0  # Remainder t2=N=a0
  beq   $0, $a1, divrtn # test zero D
  slt   $t0, $a1, $0  # test neg D
  bne   $t0, $0, divdneg
  slt   $t0, $a0, $0  # test neg N
  bne   $t0, $0, divnneg
divloop:
  slt   $t0, $v1, $a1 # while R >= D
  bne   $t0, $0, divrtn
  addiu $v0, $v0, 1   # Q = Q + 1
  subu  $v1, $v1, $a1 # R = R - D
  j     divloop
divnneg:
  subu  $a0, $0, $a0  # negate N
  jal   divide        # call divide
  subu  $v0, $0, $v0  # negate Q
  beq   $v1, $0, divrtn
  addiu $v0, $v0, -1  # return -Q-1
  j     divrtn
divdneg:
  subu  $a0, $0, $a1  # negate D
  jal   divide        # call divide
  subu  $v0, $0, $v0  # negate Q
divrtn:
  pop $a1
  pop $a0
  pop $ra
  jr  $ra
#-divide--------------------------------------------


##################################################### Max & Min #########################

# registers a0-1,v0,t0
# a0 = a
# a1 = b
# v0 = result

#-max (a0=a,a1=b) returns v0=max(a,b)--------------
max:
  push  $ra
  push  $a0
  push  $a1
  or    $v0, $0, $a0
  slt   $t0, $a0, $a1
  beq   $t0, $0, maxrtn
  or    $v0, $0, $a1
maxrtn:
  pop   $a1
  pop   $a0
  pop   $ra
  jr    $ra
#--------------------------------------------------

#-min (a0=a,a1=b) returns v0=min(a,b)--------------
min:
  push  $ra
  push  $a0
  push  $a1
  or    $v0, $0, $a0
  slt   $t0, $a1, $a0
  beq   $t0, $0, minrtn
  or    $v0, $0, $a1
minrtn:
  pop   $a1
  pop   $a0
  pop   $ra
  jr    $ra
#--------------------------------------------------

