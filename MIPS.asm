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
				addi $sp, $sp, 8
				
				
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
	INVALID:    addi $v0, $zero, -1
	            jr $ra

convertstring:	
				lw $a1, 0($sp)
				li $t2, 0		             #initialize count to 0
				
    WHILELOOP:  lb $t4, ($a1)                #load the next character into $t4
			    beq $t4, 44, CHECK        #exit loop if character is null
			    
			    addi $a0, $a0, 1             #increment the string pointer
			    addi $t2, $t2, 1             #increment the count
				j WHILELOOP                  #return to the top of the loop
			


printresults:
				move $a0, $s1                #move decimal value into a0 register
				li $v0, 1                    #system call code for printing integer = 1
				syscall
				
				jr $ra

				
				

    