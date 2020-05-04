# University of São Paulo - USP
# Institute of Mathematics and Computer Sciences (ICMC)
#
# Simple program that simulates a calculator.
#
# Authors:
#   Gabriel Nogueira
#   Lucas Yamamoto
#   Matheus Penteado
#   Daniel Suzumura
	
	.data
	.align 0
menu_str: .ascii "\n\n    > COOL CALCULATOR 9000 <\n"
	  .ascii "(32 bits floating points numbers)\n"
	  .ascii "   [1] SUM\n"
	  .ascii "   [2] SUBTRACT\n"
	  .ascii "   [3] MULTIPLY\n"
	  .ascii "   [4] DIVIDE\n"
	  .ascii "   [5] SQUARE ROOT\n"
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

input_msg_beginning: .asciiz "Parameter "
input_msg_end: .asciiz ": "

input_msg_sum: .asciiz "Please enter the first term (parameter 1) and the second term (parameter 2).\n"
input_msg_sub: .asciiz "Please enter the subtrahend (parameter 1) and the minuend (parameter 2).\n"
input_msg_mult: .asciiz "Please enter the multiplicand (parameter 1) and the multiplier (parameter 2).\n"
input_msg_div: .asciiz "Please enter the dividend (parameter 1) and the divisor (parameter 2).\n"
input_msg_sqrt: .asciiz "Please enter the radicand (parameter 1).\n"
input_msg_exp: .asciiz "Please enter the base (parameter 1) and the exponent (parameter 2).\n"
input_msg_tab: .asciiz "Please enter a number (parameter 1) to show its multiplication table.\n"
input_msg_bmi: .asciiz "Please enter a weight (parameter 1) and a height (parameter 2).\n"
input_msg_fact: .asciiz "Please enter a number (parameter 1) to calculate its factorial.\n"
input_msg_fib: .asciiz "Please enter a number (parameter 1) to calculate the Fibonacci sequence up until it.\n"

	.align 2
fp_zero: .float 0  # used to make operations with zero easier when using floating points

sum_opcode: .word 1
sub_opcode: .word 2
mult_opcode: .word 3
div_opcode: .word 4
sqrt_opcode: .word 5
exp_opcode: .word 6
tab_opcode: .word 7
bmi_opcode: .word 8
fact_opcode: .word 9
fib_opcode: .word 10
exit_op_str: .word 0


	.text
	.globl main
	
main:
show_menu:
	# print menu msg
	li $v0, 4
	la $a0, menu_str
	syscall
	
	# read operation and check for exit
	li $v0, 5
	syscall
	lw $s0, exit_op_str
	beq $s0, $v0, exit
	move $s0, $v0
	
	# new line 
	jal print_new_line
	
	# Initialize current parameter number as 1
	addi $s2, $zero, 1
	
	# check operation ($s1 will hold the address of the procedure that represents the operation)
	lw $t0, sum_opcode
	bne $s0, $t0, check_sub
	la $s1, sum_op
	
	# Print input message for this operation
	li $v0, 4
	la $a0, input_msg_sum
	syscall
	
	j get_operands2
	
check_sub:
	lw $t0, sub_opcode
	bne $s0, $t0, check_mult
	la $s1, sub_op
	
	# Print input message for this operation
	li $v0, 4
	la $a0, input_msg_sub
	syscall
	
	j get_operands2
	
check_mult:
	lw $t0, mult_opcode
	bne $s0, $t0, check_div
	la $s1, mult_op
	
	# Print input message for this operation
	li $v0, 4
	la $a0, input_msg_mult
	syscall
	
	j get_operands2
	
check_div:
	lw $t0, div_opcode
	bne $s0, $t0, check_sqrt
	la $s1, div_op
	
	# Print input message for this operation
	li $v0, 4
	la $a0, input_msg_div
	syscall
	
	j get_operands2
	
check_sqrt:
	lw $t0, sqrt_opcode
	bne $s0, $t0, check_exp
	la $s1, sqrt_op
	
	# Print input message for this operation
	li $v0, 4
	la $a0, input_msg_sqrt
	syscall
	
	j get_operands1
	
check_exp:
	lw $t0, exp_opcode
	bne $s0, $t0, check_tab
	la $s1, exp_op
	
	# Print input message for this operation
	li $v0, 4
	la $a0, input_msg_exp
	syscall
	
	j get_operands2
	
check_tab:
	lw $t0, tab_opcode
	bne $s0, $t0, check_bmi
	la $s1, tab_op
	
	# Print input message for this operation
	li $v0, 4
	la $a0, input_msg_tab
	syscall
	
	j get_operands1
	
check_bmi:
	lw $t0, bmi_opcode
	bne $s0, $t0, check_fact
	la $s1, bmi_op
	
	# Print input message for this operation
	li $v0, 4
	la $a0, input_msg_bmi
	syscall
	
	j get_operands2
	
check_fact:
	lw $t0, fact_opcode
	bne $s0, $t0, check_fib
	la $s1, fact_op
	
	# Print input message for this operation
	li $v0, 4
	la $a0, input_msg_fact
	syscall
	
	j get_operands1
	
check_fib:
	lw $t0, fib_opcode
	bne $s0, $t0, invalid_op
	la $s1, fib_op
	
	# Print input message for this operation
	li $v0, 4
	la $a0, input_msg_fib
	syscall
	
	j get_operands1
	
invalid_op:
	la $a0, invalid_op_str
	li $v0, 4
	syscall
	j show_menu
	
	
# get operand(s) as user input and store them in $f7 and $f8
get_operands2:
	jal print_input_msg
	
	li $v0, 6
	syscall
	mov.s $f7, $f0
	
	# Increment current parameter number
	addi $s2, $s2, 1

get_operands1:
	jal print_input_msg
	
	li $v0, 6
	syscall
	mov.s $f8, $f0
	
	# execute op (execute the procedure whose address is stored at $s1)
	la $ra, after_op
	jr $s1
	
	
# restart menu loop
after_op:
	j show_menu
	
# exiting program
exit:
	li $v0, 10
	syscall


# Sums $f7 and $f8 and stores the result in $f12.
sum_op:
	addi, $sp, $sp, -4	# Alloc 4 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	
	add.s $f12, $f7, $f8
	
	jal print_result
	
	lw $ra, 0($sp)		# Load the return address from Stack[0]
	addi $sp, $sp, 4	# Pop stack
	jr $ra


# Subtracts $f8 from $f7 and stores the result in $f12.
sub_op:
	addi, $sp, $sp, -4	# Alloc 4 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	
	sub.s $f12, $f7, $f8
	
	jal print_result
	
	lw $ra, 0($sp)		# Load the return address from Stack[0]
	addi $sp, $sp, 4	# Pop stack
	jr $ra


# Multiplies $f7 and $f8 and stores the result in $f12.
mult_op:
	addi, $sp, $sp, -4	# Alloc 4 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	
	mul.s $f12, $f7, $f8
	
	jal print_result
	
	lw $ra, 0($sp)		# Load the return address from Stack[0]
	addi $sp, $sp, 4	# Pop stack
	jr $ra
	
	
# Divides $f7 for $f8 and stores the result in $f12.
div_op:
	addi, $sp, $sp, -4	# Alloc 4 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	
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
	jal print_result
	
end_div:
	lw $ra, 0($sp)		# Load the return address from Stack[0]
	addi $sp, $sp, 4	# Pop stack
	jr $ra
	
	
# Calculates the square root of a radicand with five decimal places
# Parameter: $f8 = radicand
# Returns: $f12 = square root of the radicand with five decimal places
sqrt_op:
	# Start procedure
	addi, $sp, $sp, -8	# Alloc 8 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	s.s $f8, 4($sp)		# Store the radicand at Stack[1]
	
	# check negative input
	mtc1 $zero, $f7
	c.lt.s $f8, $f7
	bc1f start_sqrt
	li $v0, 4
	la $a0, invalid_op_neg
	syscall
	j sqrt_after_print	
	
start_sqrt:
	# Define initial min to $f0
	mtc1 $zero, $f0		# Set $f0 (min registrator) to 0
	cvt.s.w $f0, $f0	# Convert the content of $f0 to float
	
	# Define constant 2 to $f2
	addi $t0, $zero, 2	# Store the integer 2 at $t0
	mtc1 $t0, $f2		# Set $f2 to 2 using $t0
	cvt.s.w $f2, $f2	# Convert the content of $f2 to float
	
	# Define initial max to $f6
	mov.s $f6, $f8		# Initialize the max registrator $f6

loop_sqrt:
	# Loop this binary search until the min isn't less than max
	c.lt.s $f0, $f6
	bc1f end_sqrt
	
	# Find the middle of min and max
	add.s $f4, $f0, $f6	# Sum min and max and store in $f4 (mid)
	div.s $f4, $f4, $f2	# Divide the sum by 2 ($f2)
	
	# Get mid squared
	mul.s $f10, $f4, $f4	# Put mid squared in $f10
	
	# Check if mid ($f4) squared is the same as the radicand ($f8)
	c.eq.s $f10, $f8	# Compare with the radicand
	bc1t end_sqrt		# Finish loop if equal
	
	# Check if mid ($f4) squared is less than the radicand ($f8)
	c.lt.s $f10, $f8	# Compare with the radicand (flag == false if less for some reason)
	bc1f sqrt_less		# Branch if less
	
	# If min is different than mid, set min as mid and continue the loop
	c.eq.s $f0, $f4		# If min is equal mid, then the error is too low to fit the floating precision
	bc1t end_sqrt		# If that's the case, then we already got the best result, so end the loop
	mov.s $f0, $f4		# Set min as mid
	j loop_sqrt		# Continue the loop
	
sqrt_less:
	# Set max as mid and continue the loop
	c.eq.s $f6, $f4		# If min is equal mid, then the error is too low to fit the floating precision
	bc1t end_sqrt		# If that's the case, then we already got the best result, so end the loop
	mov.s $f6, $f4		# Set max as mid
	j loop_sqrt		# Continue the loop

end_sqrt:
	# Truncate the result up to 5 decimal places
	addi $t0, $zero, 100000	# Get the value 100000 to $t0
	mtc1 $t0, $f18		# Put 100 in $f18
	cvt.s.w $f18, $f18	# Convert it to float
	mul.s $f4, $f4, $f18	# Multiply the result ($f4) by 100000 to preserve the first 5 decimal places
	trunc.w.s $f4, $f4	# Truncate the result to integer
	cvt.s.w $f4, $f4	# Convert it back to float
	div.s $f4, $f4, $f18	# Divide the result by 100000 to restore it to 5 decimal places
	
	# print result
	mov.s $f12, $f4		# put the result in $f12 
	jal print_result
	
sqrt_after_print:
	lw $ra, 0($sp)		# Load the return address from Stack[0]
	addi $sp, $sp, 8	# Pop Stack
	jr $ra			# Return
	
	
# Calculates a number to the power of a positive integer exponent
# Parameter: $f7 = base, $f8 = exponent (truncates to integer during execution)
# Return: $f12 = the base to the power of the exponent
exp_op:
	# Start procedure
	addi $sp, $sp, -12	# Alloc 12 bytes on stack
	sw $ra, 0($sp)		# Store the return address at Stack[0]
	s.s $f7, 4($sp)		# Store the base parameter at Stack[1]
	s.s $f8, 8($sp)		# Store the exponent parameter at Stack[2]
	
	# check negative input
	mtc1 $zero, $f5
	c.lt.s $f8, $f5
	bc1f start_exp
	li $v0, 4
	la $a0, invalid_op_neg_exp
	syscall
	j exp_after_print	
		
start_exp:
	# Initialize partial result register
	addi $t1, $zero, 1	# Get value 1 in $t1
	mtc1 $t1, $f0		# Get value 1 from $t1 to the partial result register
	cvt.s.w $f0, $f0 	# Convert partial result register to float
	
	# Convert the exponent register to integer while truncating it and put in $t0
	cvt.w.s $f8, $f8	# Convert exponent register while truncating it
	mfc1 $t0, $f8		# Put in $t0
	
loop_exp:
	# Check if it reach the final result
	beq $t0, $zero, end_exp	# End loop when power is 1
	
	# Calculate one interation
	mul.s $f0, $f0, $f7	# Multiply the partial result with the base parameter
	addi $t0, $t0, -1	# Subtracts 1 of the power for the next iteration
	
	# Continue the loop
	j loop_exp		# Redo the loop

end_exp:
	# print
	mov.s $f12, $f0		# put the result in $f12 
	jal print_result

	
exp_after_print:
	# End procedure
	lw $ra, 0($sp)		# Load the return address from Stack[0]
	addi $sp, $sp, 12	# Pop stack
	jr $ra			# Return
	
	
# Shows the multiplication table of a number
# Parameter: $f8 = fixed number of the multiplication table
# Return: Nothing, it only prints the multiplication table
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
	
		
# Calculates body mass index
# Parameters: $f7 = weight, $f8 = height
# Return: $f12 = body mass index
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

bmi_start:
	# Calculates body mass (weight / (height * height))
	mul.s $f1, $f8, $f8	# Multiply height by itself and store at $f1
	div.s $f0, $f7, $f1	# Divide weight by height squared and store at $f0
	
	# Print
	mov.s $f12, $f0		# put the result in $f12 
	jal print_result
	
bmi_after_print:
	# End procedure
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
	cvt.w.s $f8,$f8  	#Convert the value of $f8 from single to integer
	mfc1 $t0,$f8     	#Put the integer value of $f8 in $t0
	
	#put back in $f8
	mtc1  $t0,$f8		#put the integer value of $t0 in $f8
	cvt.s.w $f8,$f8		#convert to single again
	#So the value of $f8 was truncate
	
	mtc1  $zero,$f0		#Put the value of $zero in $f0
	cvt.s.w $f0,$f0		#Convert the value in $f0 to float
	
	addi $t1,$zero,1	#Put 1 in $t1
	mtc1 $t1,$f1		#Put the value of $t1 in $f1
	cvt.s.w $f1,$f1		#Convert the value in $f1 to float
	
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
	bc1f fib_no_error
	li $v0, 4
	la $a0, invalid_op_neg
	syscall
	j end_fib	

# initializing registers
fib_no_error:
	li $t0, 2  		# iteration counter (starts with the 3rd element of the sequence)
	li $t1, 0  		# element of index n-2
	li $t2, 1  		# element of index n-1
	
	cvt.w.s $f8, $f8
	mfc1 $t5, $f8  		# $t5 now contains the argument $f8 as an int
	
	# checking input and printing first 2 items of the sequence
	slti $t7, $t5, 1
	bne $t7, $zero, end_fib
	li $a0, 0
	li $v0, 1
	syscall  		# prints 0
	
	slti $t7, $t5, 2
	bne $t7, $zero, end_fib
	jal print_space
	li $a0,1
	li $v0, 1
	syscall  		# prints 1
	
	slti $t7, $t5, 3
	bne $t7, $zero, end_fib
	
# printing the rest of the sequence
fib_start:
	jal print_space
	add $a0, $t2, $t1  	# $a0 receives the sum of the n-1 element with the n-2 element
	
	li $v0, 1
	syscall  		# prints the current item (stored in $a0)
	
	move $t1, $t2  		# the previous n-1 item now becomes the n-2 item  
	move $t2, $a0  		# the previous n item now becomes the n-1 item
	addi $t0, $t0, 1	# increments the iteration counter

	slt $t7, $t0, $t5
	beq $t7, 1, fib_start
	
end_fib: 
	lw $ra, 0($sp)		# Load the return address from Stack[0]
	addi $sp, $sp, 4	# Pop stack
	jr $ra
	
	
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
	
	
# Prints the input message using the number stored in $a0
print_input_msg:
	# Print first part of the input message
	li $v0, 4		# Set syscall to print string
	la $a0, input_msg_beginning	# Get the beginning of the input message
	syscall
	
	# Print the number of the current parameter being read
	li $v0, 1		# Set syscall to print integer
	move $a0, $s2		# Get current parameter number from $s2
	syscall
	
	# Print the second part of the input message
	li $v0, 4		# Set syscall to print integer
	la $a0, input_msg_end	# Get the end of the input message
	syscall
	
	jr $ra
