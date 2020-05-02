#
# Simple program that simulates a calculator.
#
	
	.data
menu_str: .ascii "\n\n    > COOL CALCULATOR 9000 <\n"
	      .ascii "(32 bits floating points numbers)\n"
		  .ascii "   [1] SUM\n"
		  .ascii "   [2] SUBTRACT\n"
		  .ascii "   [3] MULTIPLY\n"
		  .ascii "   [4] DIVIDE\n"
		  .ascii "   [5] SQR ROOT\n"
		  .ascii "   [6] EXPONENTIATION\n"
		  .ascii "   [7] MULTIPLICATION TABLE\n"
		  .ascii "   [8] BODY MASS INDEX\n"
		  .ascii "   [9] FACTORIAL\n"
		  .ascii "   [10] FIBONACCI\n"
		  .ascii "   [0] EXIT\n"
		  .asciiz "Operation: "
		  
invalid_op_str: .asciiz "Invalid operation!\n"
result_str: .asciiz "Result: "
print_mult: .asciiz " x "
print_equals: .asciiz " = "

fp_zero: .float 0  # used to make operations with zero easier when using floating points

sum_opcode: .word 1
sub_opcode: .word 2
mult_opcode: .word 3
div_opcode: .word 4
sqr_opcode: .word 5
exp_opcode: .word 6
tab_opcode: .word 7
bmi_opcode: .word 8
fact_opcode: .word 9
fib_opcode: .word 10
exit_op_str: .word 0


	.text
	.globl main
main:
	SHOW_MENU:
	# print menu msg
	li $v0, 4
	la $a0, menu_str
	syscall
	
	# read operation and check for exit
	li $v0, 5
	syscall
	lw $s0, exit_op_str
	beq $s0, $v0, EXIT
	move $s0, $v0
	
	# new line 
	jal print_new_line
	
	# check operation ($s1 will hold the address of the procedure that represents the operation)
	lw $t0, sum_opcode
	bne $s0, $t0, CHECK_SUB
	la $s1, sum_op
	j GET_OPERANDS2
	
	CHECK_SUB:
	lw $t0, sub_opcode
	bne $s0, $t0, CHECK_MULT
	la $s1, sub_op
	j GET_OPERANDS2
	
	CHECK_MULT:
	lw $t0, mult_opcode
	bne $s0, $t0, CHECK_DIV
	la $s1, mult_op
	j GET_OPERANDS2
	
	CHECK_DIV:
	lw $t0, div_opcode
	bne $s0, $t0, CHECK_SQR
	la $s1, div_op
	j GET_OPERANDS2
	
	CHECK_SQR:
	lw $t0, sqr_opcode
	bne $s0, $t0, CHECK_EXP
	la $s1, sqr_op
	j GET_OPERANDS1
	
	CHECK_EXP:
	lw $t0, exp_opcode
	bne $s0, $t0, CHECK_TAB
	la $s1, exp_op
	j GET_OPERANDS2
	
	CHECK_TAB:
	lw $t0, tab_opcode
	bne $s0, $t0, CHECK_BMI
	la $s1, tab_op
	j GET_OPERANDS1
	
	CHECK_BMI:
	lw $t0, bmi_opcode
	bne $s0, $t0, CHECK_FACT
	la $s1, bmi_op
	j GET_OPERANDS2
	
	CHECK_FACT:
	lw $t0, fact_opcode
	bne $s0, $t0, CHECK_FIB
	la $s1, fact_op
	j GET_OPERANDS1
	
	CHECK_FIB:
	lw $t0, fib_opcode
	bne $s0, $t0, INVALID_OP
	la $s1, fib_op
	j GET_OPERANDS1
	
	INVALID_OP:
	la $a0, invalid_op_str
	li $v0, 4
	syscall
	j SHOW_MENU
	
	# get operand(s) as user input and store them in $f7 and $f8
	GET_OPERANDS2:
	li $v0, 6
	syscall
	mov.s $f7, $f0
	GET_OPERANDS1:
	li $v0, 6
	syscall
	mov.s $f8, $f0
	
	# execute op (execute the procedure whose adress is stored at $s1)
	la $ra, AFTER_OP
	jr $s1
	
	# print result stored in $f12 and loop back
	AFTER_OP:
	li $v0, 4
	la $a0, result_str
	syscall
	
	li $v0, 2
	syscall
	j SHOW_MENU
	
	# exiting program
	EXIT:
	li $v0, 10
	syscall


# Sums $f7 and $f8 and stores the result in $f12.
sum_op:
	add.s $f12, $f7, $f8
	jr $ra


# Subtracts $f8 from $f7 and stores the result in $f12.
sub_op:
	sub.s $f12, $f7, $f8
	jr $ra


# Multiplies $f7 and $f8 and stores the result in $f12.
mult_op:
	#mult $a0, $a1
	#mflo $v0
	mul.s $f12, $f7, $f8
	jr $ra

		
# Divides $f7 for $8 and stores the result in $f12.
div_op:
	#div $a0, $a1
	#mflo $v0
	div.s $f12, $f7, $f8
	jr $ra
	
	
# to_do: square root
sqr_op:
	addi, $sp, $sp, -8
	sw $ra, 0($sp)
	s.s $f8, 4($sp)
	
	# to_do: add check for negative numbers
	
	mov.s $f0, $f8		# Initializes the previous aproximation register $f0
	addi $t0, $zero, 2
	mtc1 $t0, $f4		# Sets $f4 to 2
	cvt.s.w $f4, $f4	# Converts the content of $f4 to float
	div.s $f2, $f0, $f4	# Defines an aproximation for the square root value
	
loop_sqr:
	# Loops this algorithm until the previous aproximation and the current one are the same
	c.eq.s $f0, $f2
	bc1t end_sqr
	
	# Puts the result of the division between the parameter $f8 and the previous aproximation $f0 in $f6
	div.s $f6, $f8, $f0
	
	# Calculates the average of $f6 and $f0
	add.s $f6, $f6, $f0
	div.s $f6, $f6, $f4
	
	# Updates current and previous aproximation
	mov.s $f0, $f2
	mov.s $f2, $f6
	
	j loop_sqr

end_sqr:
	mov.s $f12, $f2		# $f12 receives the return value
	
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	
	jr $ra
	
	
# to_do: exponentiation
exp_op:
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	s.s $f7, 4($sp)
	s.s $f8, 8($sp)
	
	mov.s $f0, $f7
	addi $t1, $zero, 1
	
	# Delete this 2 lines after fixing the parameters
	cvt.w.s $f8, $f8
	mfc1 $t0, $f8
	
	# to_do: add check for negative $t0
	
loop_exp:
	beq $t0, $t1, end_exp
	
	mul.s $f0, $f0, $f7
	addi $t0, $t0, -1
	
	# to_do: add check for overflow
	
	j loop_exp

end_exp:
	mov.s $f12, $f0
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	jr $ra
		
# to_do: multiplication table
tab_op:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	#Put the value of $zero in $f0
	mtc1  $zero,$f0
	#Convert the value in $f0 to float
	cvt.s.w $f0,$f0

	#Put 1 in $t1
	addi $t1,$zero,1
	#Put the value of $t1 in $f1
	mtc1 $t1,$f1
	#Convert the value in $f1 to float
	cvt.s.w $f1,$f1
	
	#put 1 in $f2
	add.s $f2,$f1,$f0
	
	#Put 11 in $t1
	addi $t1,$zero,11
	#Put the value of $t1 in $f10
	mtc1 $t1,$f10
	#Convert the value in $f10 to float
	cvt.s.w $f10,$f10

loop_tab:	
	c.eq.s $f2,$f10
	bc1t end_tab
	
	add.s $f12,$f2,$f0
	#print the number that is multiplying
	li $v0,2
	syscall
	
	#print +
	li $v0,4
	la $a0,print_mult
	syscall
	
	add.s $f12,$f8,$f0
	#print the number $f8
	li $v0,2
	syscall
	
	#print =
	li $v0,4
	la $a0,print_equals
	syscall
	
	mul.s $f12,$f2,$f8
	
	#print the result
	li $v0,2
	syscall
	
	jal print_new_line
	
	#increment $f1
	add.s $f2,$f2,$f1
	
	j loop_tab

end_tab:
	jal print_new_line
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

		
# to_do: body mass index
bmi_op:
	jr $ra

		
# to_do: factorial docs
fact_op:
	#Put the value of $zero in $f0
	mtc1  $zero,$f0
	#Convert the value in $f0 to float
	cvt.s.w $f0,$f0
	
	#Put 1 in $t1
	addi $t1,$zero,1
	#Put the value of $t1 in $f1
	mtc1 $t1,$f1
	#Convert the value in $f1 to float
	cvt.s.w $f1,$f1
	
	#Put 1 in $f12
	add.s $f12,$f0,$f1
	#Put 0 in $f2
	add.s $f2,$f0,$f0
	loop_fact:
		#If $f8 is equals $f2 finish the loop
		c.eq.s $f8,$f2	
		bc1t end_fact
		
		#Increase the $f2
		add.s $f2,$f2,$f1
		
		#Multiple $F12 by the $f2
		mul.s $f12,$f12,$f2
		
		j loop_fact

	end_fact:
		jr $ra

		
# Prints all the items of the Fibonacci sequence up to the item with index equal to the value stored in $f8. Returns 0 ($f12 = 0).
fib_op:
	# initializing registers
	li $t0, 2  # iteration counter (starts with the 3rd element of the sequence)
	li $t1, 0  # element of index n-2
	li $t2, 1  # element of index n-1
	move $t6, $ra  # saves the return address
	
	cvt.w.s $f8, $f8
	mfc1 $t5, $f8  # $t5 now contains the argument $f8 as an int
	
	# checking input and printing first 2 items of the sequence
	slti $t7, $t5, 1
	bne $t7, $zero, END_FIB
	li $a0, 0
	li $v0, 1
	syscall  # prints 0
	
	slti $t7, $t5, 2
	bne $t7, $zero, END_FIB
	jal print_space
	li $a0,1
	li $v0, 1
	syscall  # prints 1
	
	slti $t7, $t5, 3
	bne $t7, $zero, END_FIB
	
	# printing the rest of the sequence
	FIB_START:
		jal print_space
		add $a0, $t2, $t1  # $a0 receives the sum of the n-1 element with the n-2 element
		
		li $v0, 1
		syscall  # prints the current item (stored in $a0)
		
		move $t1, $t2  # the previous n-1 item now becomes the n-2 item  
		move $t2, $a0  # the previous n item now becomes the n-1 item
		addi $t0, $t0, 1  # increments the iteration counter
	
		slt $t7, $t0, $t5
		beq $t7, 1, FIB_START
	
	END_FIB: 
	jal print_new_line
	l.s $f12, fp_zero
	jr $t6
	
	
# Prints a new line.
print_new_line:
	li $a0, 10
	li $v0, 11
	syscall
	jr $ra
	

# Prints a blank space.
print_space:
	li $a0, 32
	li $v0, 11
	syscall
	jr $ra
