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
		  
enter_op_str: .asciiz "Enter 2 numbers.\n"	
invalid_op_str: .asciiz "Invalid operation!\n"
result_str: .asciiz "Result: "
digitar_primeiro_numero_str: .asciiz "Digite um numero: "
digitar_segundo_numero_str: .asciiz "Digite outro numero: "

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
	li $a0, 10
	li $v0, 11
	syscall
	
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
	
	# get operands (1 or 2)
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
	
	# print result and loop back
	AFTER_OP:
	li $v0, 4
	la $a0, result_str
	syscall
	
	#move $a0, $t0
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
	jr $ra
	
	
# to_do: exponentiation
exp_op:
	jr $ra

		
# to_do: multiplication table
tab_op:
	jr $ra

		
# to_do: body mass index
bmi_op:
	jr $ra

		
# to_do: factorial
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

		
# to_do: fibonacci
fib_op:
	jr $ra
