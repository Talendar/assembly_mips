#
# Implementation of the strrchr C function.
# Author: Talendar (Gabriel Nogueira)
#


	.data
	.align 0
buffer: 			.space 128  											# input string buffer
input_string_msg: 	.asciiz "> Input string (max: 127 chars): "				# asks the user for a string
input_char_msg: 	.asciiz "> Character to be searched for: "				# asks the user for a char
success_result_msg: .asciiz "> Last occurrence on offset (zero-indexed): "	# displayed when the character was found
fail_result_msg: 	.asciiz "> Character not found!"						# displayed when the character wasn't found


	.text
main:
	# printing: enter string msg
	la $a0, input_string_msg
	li $v0, 4
	syscall

	# reading user input: string
	la $a0, buffer
	la $a1, 128
	li $v0, 8
	syscall	
	
	# printing: enter char msg
	la $a0, input_char_msg
	li $v0, 4
	syscall
	
	# reading user input: char		
	li $v0, 12
	syscall
	
	# calling strrchar
	la $a0, buffer
	move $a1, $v0
	jal strrchar
	move $s0, $v0							# saving the value returned by strrchar in $s0
	
	# printing: 2 new lines
	jal print_new_line
	jal print_new_line
	
	# checking if the char was found
	beq $s0, $zero, main_print_failure		
	
	# printing: sucess msg
	la $a0, success_result_msg
	li $v0, 4
	syscall
	
	# printing: offset of the char's last occurrence
	la $t0, buffer
	sub $a0, $s0, $t0					   # subtracts the string's base address from the char's address
	li $v0, 1
	syscall
	j main_exit
	
	# printing: failure msg
main_print_failure:
	la $a0, fail_result_msg
	li $v0, 4
	syscall
	
	# leaving
main_exit:
	jal print_new_line
	li $v0, 10
	syscall
	

#
# Locates the last occurrence of a character in a string.
#
# Params:
# 	$a0: address of a null-terminated string.
# 	$a1: character to be searched for.
#
# Returns: 
#	$v0: the address of the last occurrence of the character in the string or 0 if the character isn't found.
#
strrchar:
	addi $sp, $sp, -4				# pushing one item into the stack
	sw $ra, 0($sp)					# saving the return address in the stack
	
	li $v0, 0						# $v0 holds the address of the char's last occurrence
	
strrchar_L1:
	lb $t1, 0($a0)					# $t1 stores the current char being parsed
	bne $t1, $a1, strrchar_L2		# check if it's the char being searched for
	move $v0, $a0					# if it's a match, saves the address
strrchar_L2:
	addi $a0, $a0, 1				# updates the address being read (next char)
	bne $t1, $zero, strrchar_L1		# restart loop if not end of string ($t1 != '\0')
	
	lw $ra, 0($sp)					# recovering the return address from the stack
	addi $sp, $sp, 4				# popped one item from the stack
	jr $ra


#
# Prints a new line character.
#
# Params: none
# Returns: nothing
#
print_new_line:
	li $a0, 10 					    # loads the \n char into $a0
	li $v0, 11
	syscall
	jr $ra
