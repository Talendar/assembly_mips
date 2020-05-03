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
invalid_op_neg: .asciiz "Invalid operand! Operand must be >= 0."
invalid_op_neg_div: .asciiz "Invalid operand! Divisor cant be 0."
invalid_op_neg_exp: .asciiz "Invalid operand! Expoent must be >= 0."
invalid_op_neg_zero: .asciiz "Invalid operand! Operand must be > 0."
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
	
	# execute op (execute the procedure whose address is stored at $s1)
	la $ra, AFTER_OP
	jr $s1
	
	# restart menu loop
	AFTER_OP:
	j SHOW_MENU
	
	# exiting program
	EXIT:
	li $v0, 10
	syscall


# Sums $f7 and $f8 and stores the result in $f12.
sum_op:
	addi, $sp, $sp, -4	# Alloc 4 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	
	add.s $f12, $f7, $f8
	
	jal print_result
	lw $ra, 0($sp)		# Load the return address from Stack[0]
	jr $ra


# Subtracts $f8 from $f7 and stores the result in $f12.
sub_op:
	addi, $sp, $sp, -4	# Alloc 4 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	
	sub.s $f12, $f7, $f8
	
	jal print_result
	lw $ra, 0($sp)		# Load the return address from Stack[0]
	jr $ra


# Multiplies $f7 and $f8 and stores the result in $f12.
mult_op:
	addi, $sp, $sp, -4	# Alloc 4 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	
	mul.s $f12, $f7, $f8
	
	jal print_result
	lw $ra, 0($sp)		# Load the return address from Stack[0]
	jr $ra

		
# Divides $f7 for $f8 and stores the result in $f12.
div_op:
	# check divisor 0
	mtc1 $zero, $f5
	c.eq.s $f8, $f5
	bc1f start_div
	li $v0, 4
	la $a0, invalid_op_neg_div
	syscall
	j end_div
	
	start_div:
		div.s $f12, $f7, $f8
		
		# print result
		addi, $sp, $sp, -4	# Alloc 4 bytes on stack
		sw $ra, 0($sp)		# Store the return address at Stack[0]
		
		jal print_result
		lw $ra, 0($sp)		# Load the return address from Stack[0]
	end_div:
		jr $ra
	
	
# to_do: square root
sqr_op:
	# Start procedure
	addi, $sp, $sp, -8	# Alloc 8 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	s.s $f8, 4($sp)		# Store the radicand at Stack[1]
	
	# check negative input
	mtc1 $zero, $f7
	c.lt.s $f8, $f7
	bc1f start_sqr
	li $v0, 4
	la $a0, invalid_op_neg
	syscall
	j sqr_after_print	
	
	# Initialize registers
	start_sqr:
		# Define initial min to $f0
		mtc1 $zero, $f0		# Set $f0 (min registrator) to 0
		cvt.s.w $f0, $f0	# Convert the content of $f0 to float
		
		# Define constant 2 to $f2
		addi $t0, $zero, 2	# Store the integer 2 at $t0
		mtc1 $t0, $f2		# Set $f2 to 2 using $t0
		cvt.s.w $f2, $f2	# Convert the content of $f2 to float
		
		# Define initial max to $f6
		mov.s $f6, $f8		# Initialize the max registrator $f6
	
	loop_sqr:
		# Loop this binary search until the min isn't less than max
		c.lt.s $f0, $f6
		bc1f end_sqr
		
		# Find the middle of min and max
		add.s $f4, $f0, $f6	# Sum min and max and store in $f4 (mid)
		div.s $f4, $f4, $f2	# Divide the sum by 2 ($f2)
		
		# Get mid squared
		mul.s $f10, $f4, $f4	# Put mid squared in $f10
		
		# Check if mid ($f4) squared is the same as the radicand ($f8)
		c.eq.s $f10, $f8	# Compare with the radicand
		bc1t end_sqr		# Finish loop if equal
		
		# Check if mid ($f4) squared is less than the radicand ($f8)
		c.lt.s $f10, $f8	# Compare with the radicand (flag == false if less for some reason)
		bc1f sqr_less		# Branch if less
		
		# If min is different than mid, set min as mid and continue the loop
		c.eq.s $f0, $f4		# If min is equal mid, then the error is too low to fit the floating precision
		bc1t end_sqr		# If that's the case, then we already got the best result, so end the loop
		mov.s $f0, $f4		# Set min as mid
		j loop_sqr		# Continue the loop
		
		sqr_less:
			# Set max as mid and continue the loop
			c.eq.s $f6, $f4	# If min is equal mid, then the error is too low to fit the floating precision
			bc1t end_sqr	# If that's the case, then we already got the best result, so end the loop
			mov.s $f6, $f4	# Set max as mid
			j loop_sqr	# Continue the loop

	end_sqr:
		# Truncate the result to 2 decimal places
		addi $t0, $zero, 100	# Get the value 100 to $t0
		mtc1 $t0, $f18		# Put 100 in $f18
		cvt.s.w $f18, $f18	# Convert it to float
		mul.s $f4, $f4, $f18	# Multiply the result ($f4) by 100 to preserve the first 2 decimal places
		trunc.w.s $f4, $f4	# Truncate the result to integer
		cvt.s.w $f4, $f4	# Convert it back to float
		div.s $f4, $f4, $f18	# Divide the result by 100 to restore it to 2 decimal places
		
		# print result
		mov.s $f12, $f4		# put the result in $f12 
		jal print_result
		sqr_after_print:
			lw $ra, 0($sp)		# Load the return address from Stack[0]
			addi $sp, $sp, 8	# Pop Stack
			jr $ra			# Return
	
	
# to_do: exponentiation
exp_op:
	# Start procedure
	addi $sp, $sp, -12	# Alloc 12 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	s.s $f7, 4($sp)		# Store the base parameter at Stack[1]
	s.s $f8, 8($sp)		# Store the power parameter at Stack[2]
	
	# check negative input
	mtc1 $zero, $f5
	c.lt.s $f8, $f5
	bc1f start_exp
	li $v0, 4
	la $a0, invalid_op_neg_exp
	syscall
	j exp_after_print	
	
	# Initialize registers
	start_exp:
	# Initialize partial result register
	addi $t1, $zero, 1	# Get value 1 in $t1
	mtc1 $t1, $f0		# Get value 1 from $t1 to the partial result register
	cvt.s.w $f0, $f0 	# Convert partial result register to float
	
	# Convert the power register to integer while truncating it and put in $t0
	cvt.w.s $f8, $f8	# Convert power register while truncating it
	mfc1 $t0, $f8		# Put in $t0
	
	loop_exp:
		# Check if it reach the final result
		beq $t0, $zero, end_exp		# End loop when power is 1
		
		# Calculate one interation
		mul.s $f0, $f0, $f7		# Multiply the partial result with the base parameter
		addi $t0, $t0, -1		# Subtracts 1 of the power for the next iteration
		
		# Continue the loop
		j loop_exp			# Redo the loop

	end_exp:
		# print
		mov.s $f12, $f0		# put the result in $f12 
		jal print_result
		# End procedure
		exp_after_print:
			lw $ra, 0($sp)			# Load the return address from Stack[0]
			addi $sp, $sp, 12		# Pop stack
			jr $ra				# Return
	
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
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

		
# to_do: body mass index
bmi_op:
	# Start procedure
	addi $sp, $sp, -12	# Alloc 12 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	s.s $f7, 4($sp)		# Store the weight parameter at Stack[1]
	s.s $f8, 8($sp)		# Store the height parameter at Stack[2]
	
	# check negative input and zero
	mtc1 $zero, $f5
	c.le.s $f7, $f5
	bc1t bmi_print_error
	c.le.s $f8, $f5
	bc1f bmi_start
	bmi_print_error:
		li $v0, 4
		la $a0, invalid_op_neg_zero
		syscall
		j bmi_after_print
	
	# Calculates body mass (weight / (height * height))
	bmi_start:
		mul.s $f1, $f8, $f8	# Multiply height by itself and store at $f1
		div.s $f0, $f7, $f1	# Divide weight by height squared and store at $f0
	
		# Print
		mov.s $f12, $f0		# put the result in $f12 
		jal print_result
	# End procedure
	bmi_after_print:
		lw $ra, 0($sp)		# Load the return address from Stack[0]
		addi $sp, $sp, 12	# Pop stack
		jr $ra			# Return
		
#Calculates the integer part of $f8 factorial
#Parameter: $f8 will be truncate, so just the integer part will be use
#Return: $f12 -> The factorial of the integer part of $f8
fact_op: 
	# Start procedure
	addi $sp, $sp, -8	# Alloc 8 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	s.s $f8, 4($sp)		# Store the parameter at Stack[1]
	
	# check negative input
	mtc1 $zero, $f5
	c.lt.s $f8, $f5
	bc1f start_fact
	li $v0, 4
	la $a0, invalid_op_neg
	syscall
	j fact_after_print	
	
	start_fact:
	#t0 will store the integer part of the $f8
	cvt.w.s $f8,$f8  #Convert the value of $f8 from single to integer
	mfc1 $t0,$f8     #Put the integer value of $f8 in $t0
	#put back in $f8
	mtc1  $t0,$f8	#put the integer value of $t0 in $f8
	cvt.s.w $f8,$f8	#convert to single again
	#So the value of $f8 was truncate
	
	mtc1  $zero,$f0	#Put the value of $zero in $f0
	cvt.s.w $f0,$f0	#Convert the value in $f0 to float
	
	addi $t1,$zero,1	#Put 1 in $t1
	mtc1 $t1,$f1	#Put the value of $t1 in $f1
	cvt.s.w $f1,$f1	#Convert the value in $f1 to float
	
	#$f12 will store the result of the factorial
	add.s $f12,$f0,$f1	#Put 1 in $f12

	add.s $f2,$f0,$f0	#Put 0 in $f2
	
	#Loop of factorial
	loop_fact:
		#If $f8 is equals $f2 finish the loop
		#$f8 is the value we want to reach and the $f2 is the auxiliary variable that will be incremented in each interaction
		c.eq.s $f8,$f2	
		bc1t end_fact
		
		add.s $f2,$f2,$f1	#Increase the $f2
		mul.s $f12,$f12,$f2	#Multiple $F12 by the $f2
		
		#Go back to the loop
		j loop_fact
	
	# End procedure
	end_fact:
		# print result
		jal print_result
		
		fact_after_print:
			lw $ra, 0($sp)		# Load the return address from Stack[0]
			addi $sp, $sp, 8	# Pop stack
			jr $ra			# Return

		
# Prints all the items of the Fibonacci sequence up to the item with index equal to the value stored in $f8. Returns 0 ($f12 = 0).
fib_op:
	addi $sp, $sp, -4	# Alloc 4 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]

	# check negative input
	mtc1 $zero, $f5
	c.lt.s $f8, $f5
	bc1f FIB_NO_ERROR
	li $v0, 4
	la $a0, invalid_op_neg
	syscall
	j END_FIB	

	# initializing registers
	FIB_NO_ERROR:
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
		lw $ra, 0($sp)		# Load the return address from Stack[0]
		addi $sp, $sp, 4	# Pop stack
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
	

# Prints the result stored in the register $f12.
print_result:
	li $v0, 4
	la $a0, result_str
	syscall
	
	li $v0, 2
	syscall
	jr $ra
