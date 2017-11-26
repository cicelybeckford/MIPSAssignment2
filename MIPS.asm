#PROGRAM: CONVERT A STRING WITH MULTIPLE HEXADECIMAL VALUES

.data  
    string: .asciiz ".space 8"
	output1: .asciiz "\n" 
	output2: .asciiz ","
	invalid: .asciiz "NaN"
	toolarge: .asciiz "too large"
	buffer:  .space 1001
	substring: .space 15
.text
main: 
	 			li $v0, 8                  #system call code for reading string = 8
				la $a0, buffer             #load byte space into address
				li $a1, 1001               #allot the byte space for hexadecimal
				syscall
				
				addiu $a1, $a0, 0          #move address of hexadecimal into $a1
				la $s6, substring
				j ILOOP
				
	OLOOP:		la $s6, substring
			    li $t2, 0
			    addi $a1, $a1, 1
	ILOOP:		lb $s0, ($a1)  
	            beq $s0, 10, STOP
				beq $s0, 44, STOP
	            sb $s0, ($s6)               #store char in string 
	            addi $t2, $t2, 1
		        addi $a1, $a1, 1
		        addi $s6, $s6, 1
		        j ILOOP
				
	STOP:	    sub $s6, $s6, $t2
	            addi $sp, $sp, -12
				sw $s6, 0($sp)
				sw $t2, 4($sp)
				jal subprogram_1
				jal subprogram_3
				addi $sp, $sp, 12
				beq $s0, 10, END
				
				la $a0, output2            #address of string to print
				li $v0, 4		           #system call code for printing string = 4
				syscall
				j OLOOP
				
	END:        li $v0, 10                 #terminate program 
			    syscall                    #and exit
				
subprogram_1:	
				lw $a2, 0($sp)
				lw $t7, 4($sp)
				li $s2, 1				   #initialize count to 0
				li $s1, 0		             #initialize count to 0
				li $t0, 0
				beq $t7, 0, NOTVALID
				sub $t9, $t7, 1
				add $a2, $a2, $t9
				
    CHECK:	    lb $s4, ($a2)
				bne $s4, 32, ENDCHECK            #if the character in $t4 is not a space jump to EXIT
				sub $t7, $t7, 1              #and decrement string length count
				sub $t9, $t9, 1
				beq $t7, 0, NOTVALID          #if the length of string is equal to 0 jump to INVALID
				sub $a2, $a2, 1
				j CHECK
	ENDCHECK:	sub $a2, $a2, $t9
				li $t9, 1
				li $s4, 0
				
    WHILELOOP:  move $t0, $s4
				lb $s4, ($a2)                #load the next character into $t4
				bgt $s2, 9, LARGE
				bgt $t9, $t7, EXIT            #exit loop if character is null
				beq $t0, 32, DO            #if the character in $t0(previous character) is a space
				bne $s2, 1, NOSPACE        #and it is not the first character jump to NOSPACE 
		DO:     beq $s4, 32, SKIP          #or if $t0 and $t3 (current character) are spaces jump
    NOSPACE:    addi $sp, $sp, -4
                sw $ra, 12($sp)
				add $a0, $zero, $s4
				jal subprogram_2
				lw $ra, 12($sp)
				addi $sp, $sp, 4
				add $v1, $v0, $zero
				beq $v1, -3, NOTVALID
				beq $t7, $t9, DONE
				
				sub $t2, $t7, $s2
				ble $t7, 8, LESS
				sub $t4, $t7, 8
				sub $t2, $t2, $t4
    LESS:       li $t8, 16                 #load 16 into register $t8 
                li $t3, 16                 #load 16 into register $v0  
	LOOP:	    beq $t2, 1, DECIMAL      #if counter equals $t6 end loop
                multu $t3, $t8             #16 *= 16
                mflo $t8 		           #store result in $v0 register
                sub $t2, $t2, 1          #increment counter
                j LOOP                     #return to top of loop
                
   DECIMAL:     multu $v1, $t8             #multiply the integer by the results to get its value in the decimal
                mflo $v1 
				
	DONE:	    add $s1, $s1, $v1
				addi $s2, $s2, 1             #increment the count
				
	SKIP:		addi $t9, $t9, 1
				addi $a2, $a2, 1             #increment the string pointer
				j WHILELOOP                  #return to the top of the loop
	
	NOTVALID:   li $s1, -3
				j EXIT
	
	LARGE:      li $s1, -2
				
	EXIT:	    sw $s1, 8($sp)
	            jr $ra
   
subprogram_2:
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
	AND2:		bge $t0, $t5, THEN2        #and greater than or equal to 'A' branch to LABEL2
	AND3:       bge $t0, $t6, THEN3        #and greater than or equal to 'a' branch to LABEL3
				j INVALID                  #jump to INVALID procedure
	
    THEN:		subu $v0, $t0, $t1
				jr $ra   	
	THEN2:	    subu $v0, $t0, $t5
				addi $v0, $v0, 10
				jr $ra 
	THEN3:		subu $v0, $t0, $t3
				addi $v0, $v0, 10
				jr $ra 
	INVALID:    addi $v0, $zero, -3
				jr $ra
   
subprogram_3:   lw $s1, 8($sp)
				bge $s1, $zero, POSITIVE    #if the decimal value is negative jump to NEGATIVE label 
                beq $s1, -3, NAN
				beq $s1, -2, TOOLARGE
		        li $t0, 100000               #load 100000 into register $t0
				divu $s1, $t0                #divide the decimal value by 100000 to split 
			    mflo $v1                     #store the quotient in $s1 register
				mfhi $s1                     #store the remainder in the $v1 register     
				
				move $a0, $v1                #primary address = s1 address (load pointer)
				li $v0, 1                    #system call code for printing integer = 1
				syscall  
				                              
    POSITIVE:   move $a0, $s1                #move contents of $v1 register into $a0
				li $v0, 1                    #system call code for printing integer = 1
				syscall
				j RETURN

   NAN:         la $a0, invalid              #address of string to print
				li $v0, 4		     #system call code for printing string = 4
				syscall 
				j RETURN
				
  TOOLARGE:     la $a0, toolarge             #address of string to print
				li $v0, 4		     #system call code for printing string = 4
				syscall 
				
     RETURN:	jr $ra
    