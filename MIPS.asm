#PROGRAM: CONVERT A STRING WITH MULTIPLE HEXADECIMAL VALUES

.data  
    string: .asciiz ".space 8"
	output1: .asciiz "\n" 
	invalid: .asciiz "NaN\n"
	buffer:  .space 1001
	
.text
main: 
	 			li $v0, 8                  #system call code for reading string = 8
				la $a0, buffer             #load byte space into address
				li $a1, 1001               #allot the byte space for hexadecimal
				syscall
				
				addiu $a1, $a0, 0          #move address of hexadecimal into $a1
				li $t8, 9
			    li $t2, 0
	ILOOP:		lb $t9, (a1)
	            beq $t9, 44, STOP   
	            sw $t9, string($s0)          #store char in string
		        addi $s0, $s0, 1             #next char in string
		        addi $a1, $a1, 1
		        j LOOP
				
	STOP:	    addi $sp, $sp, -16
				sw $s0, 0($sp)
				jal convertstring
				lw $s1, 8($sp)
				jal printResults
				addi $sp, $sp, 16
				
				
convertchar:
				li $t1, '0'                #holds character '0'
				li $t2, '9' 		       #holds character '9'
				li $t3, 'a' 		       #holds character 'a'
				li $t4, 'f'		           #holds character 'f'
				li $t5, 'A'		           #holds character 'A'
				li $t6, 'F'		           #holds character 'F'	
				addu $t0, $a0, $zero
				
				ble $t0, $t2, AND          #if the character is less than or equal to 9
				ble $t0, $t6, AND2         #if the character is less than or equal to 'F'
				ble $t0, $t4, AND3         #if the character is less than or equal to 'f'
				j INVALID
								  
    AND:        bge $t0, $t1, THEN         #and greater than or equal to 0 branch to LABEL1
	AND2:		bge $t0, $t4, THEN2        #and greater than or equal to 'A' branch to LABEL2
	AND3:       bge $t0, $s6, THEN3        #and greater than or equal to 'a' branch to LABEL3
				j INVALID                  #jump to INVALID procedure
	
	THEN:		subu $v0, $t0, $t1
				jr $ra   	
	THEN2:	    subu $v0, $t0, $t5
				jr $ra 
	THEN3:		subu $v0, $t0, $t3
				jr $ra 
	INVALID:    addi $v0, $zero, -3
	            jr $ra

convertstring:	
				lw $a1, 0($sp)
				li $t2, 0		             #initialize count to 0
				
				li $t0, 0
				
    WHILELOOP:  move $t0, $t4
				lb $t4, ($a1)                #load the next character into $t4
				beq $t4, 44, STOP            #exit loop if character is null
				beq $t0, 32, DO            #if the character in $t0(previous character) is a space
				bne $t2, 1, NOSPACE        #and it is not the first character jump to NOSPACE 
		DO:     beq $t4, 32, SKIP          #or if $t0 and $t3 (current character) are spaces jump
    NOSPACE:    add $a0, $zero, $t4
                addi $sp, $sp, -4
                sw $ra, 16($sp)
				jal convertchar
				add $s1, $v0, $zero
				beq $s1, -3, STOP
				addi $t2, $t2, 1             #increment the count
	SKIP:		addi $a0, $a0, 1             #increment the string pointer
				j WHILELOOP                  #return to the top of the loop
	
	STOP:		lw $ra, 16($sp)
				addi $sp, $sp, 4
				sw $t7, 8($sp)
	            jr $ra
   
printresults:   
				bgt $s1, $zero, POSITIVE    #if the decimal value is negative jump to NEGATIVE label 
                beq $s1, -3, INVALID
		        li $t0, 100000               #load 100000 into register $t0
				divu $s1, $t0                #divide the decimal value by 100000 to split 
			    mflo $v1                     #store the quotient in $s1 register
				mfhi $s1                     #store the remainder in the $v1 register     
			    bne $t9, 0, NOTEIGHT         #if length of the input was not 8 output a newline character
				la $a0, output1              #address of string to print
				li $v0, 4		             #system call code for printing string = 4
				syscall
				
				move $a0, $v1                #primary address = s1 address (load pointer)
				li $v0, 1                    #system call code for printing integer = 1
				syscall  
				                              
    POSITIVE:   move $a0, $s1                #move contents of $v1 register into $a0
				li $v0, 1                    #system call code for printing integer = 1
				syscall
				j RETURN

     INVALID:   la $a0, invalid              #address of string to print
				li $v0, 4		     #system call code for printing string = 4
				syscall 
				
     RETURN:	jr $ra

				
				

    