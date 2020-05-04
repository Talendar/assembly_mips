# Implementation of the bubble sort algorithm.
# Author: Talendar (Gabriel Nogueira)


	.data
	.align 0
new_line_char: .asciiz "\n"
space_char: .asciiz " "
	.align 2
array: .word 5, 2, 10, 3, 14, 8, 4, 0, 9, 1, 6, 7, 15, 11, 12, 13   # array to be sorted
n: .word 16  							    # size of the array


	.text
main:
	la $a0, array  		# loading the array's address into $a0
	la $a1, n
	lw $a1, 0($a1) 		# loading the array size n into $a1
	jal print_array 	# printing the array before sorting
	
	la $a0, array  		# loading the array's address into $a0
	la $a1, n
	lw $a1, 0($a1) 		# loading the array size n into $a1
	jal bubble_sort     	# sorting	
	
	jal print_new_line
	
	la $a0, array  		# loading the array's address into $a0
	la $a1, n
	lw $a1, 0($a1) 		# loading the array size n into $a1
	jal print_array		# printing the array after sorting
	
	li $v0, 10
	syscall
	

# Sort the given array using bubble sort.
#
# Params:
# 	$a0: address of the array.
# 	$a1: array's size.
#
# Returns: nothing
bubble_sort:
	addi $sp, $sp, -4
	sw $ra, 0($sp)  					# saving the return address in the stack
	
	addi $a1, $a1, -1					# n-- (needed for the bs_internal_loop)
	
bs_swap_loop:							# loops until no swap was performed
	li $t0, 0  							# swapped ($t0) = false (0)
	li $t1, 0							# i ($t1) = 0

bs_for_loop:							# for(int i = 1; i < n; i++)
	bge $t1, $a1, bs_for_end				# break if i >= n
	
	sll $t3, $t1, 2						# multiplying i by 4 and storing the result in $t3
	add $t3, $t3, $a0					# getting the address of array[i] and putting it in $t3
	lw $t6, 0($t3)						# a ($t6) = array[i]
	lw $t7, 4($t3)						# b ($t7) = array[i+1]
	
	ble $t6, $t7, bs_for_inc				# if(a > b)
	sw $t6, 4($t3)						# array[i] = array[i+1]
	sw $t7, 0($t3)						# array[i+1] = array[i] (previous value)
	li $t0, 1							# swapped = true
	
bs_for_inc:
	addi $t1, $t1, 1					# i++
	j bs_for_loop			
	
bs_for_end:
	bne $t0, $zero, bs_swap_loop				# restart swap loop if swapped = true
	
	lw $ra, 0($sp)  					# recovering the return address from the stack
	addi $sp, $sp, 4
	jr $ra
	
	
# Prints all the elements of the given array.
#
# Params:
# 	$a0: address of the array.
# 	$a1: array's size.
#
# Returns: nothing
print_array:
	addi $sp, $sp, -16					# spilling 4 registers in the stack
	sw $ra, 0($sp)  					# saving the return address in the stack
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	move $s0, $a0						# uses $s0 to hold the array's address
	li $s1, 0							# i ($s1) = 0
print_array_start:						# for(i = 0; i < n; i++)
	bge $s1, $a1, print_array_end				# break if i >= n
	
	sll $s2, $s1, 2						# multiplying i by 4 and storing the result in $s2
	add $s2, $s2, $s0					# getting the address of array[i] and putting it in $s2				
	lw $a0, 0($s2)
	li $v0, 1
	syscall							# prints array[i]
	
	jal print_space
	
	addi $s1, $s1, 1					# i++
	j print_array_start
	
print_array_end:
	lw $ra, 0($sp)  					# recovering the return address
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16					# popping 4 items from the stack
	jr $ra
	
	
# Prints a new line character.
# 
# Params: none
# Returns: nothing
print_new_line:
	addi $sp, $sp, -4
	sw $ra, 0($sp)  					# saving the return address in the stack
	
	la $a0, new_line_char
	lb $a0, 0($a0)
	li $v0, 11
	syscall
	
	lw $ra, 0($sp)  					# recovering the return address from the stack
	addi $sp, $sp, 4
	jr $ra
	
	
# Prints a space character.
# 
# Params: none
# Returns: nothing
print_space:
	addi $sp, $sp, -4
	sw $ra, 0($sp)  					# saving the return address in the stack
	
	la $a0, space_char
	lb $a0, 0($a0)
	li $v0, 11
	syscall
	
	lw $ra, 0($sp)  					# recovering the return address from the stack
	addi $sp, $sp, 4
	jr $ra
	
