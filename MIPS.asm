#PROGRAM: CONVERT A STRING WITH MULTIPLE HEXADECIMAL VALUES

.data  
	output2: .asciiz ","
	invalid: .asciiz "NaN"
	toolarge: .asciiz "too large"
	buffer:  .space 1001
	substring: .space 15
.text
#GETS USER INPUT AND CALLS THE SUBPROGRAMS 
main: 
	 			li $v0, 8                  #system call code for reading string = 8
				la $a0, buffer             #load byte space into address
				li $a1, 1001               #allot the byte space for hexadecimal
				syscall
				
				addiu $a1, $a0, 0          #move address of hexadecimal into $a1
				la $s6, substring          #load byte space into address for substring
				j ILOOP                    #jumps to inner loop
				
	OLOOP:		la $s6, substring          
			    li $t2, 0                  #set $t2's value to 0
			    addi $a1, $a1, 1           #increment address pointer
	ILOOP:		lb $s0, ($a1)              #get first byte of string and store in $s0
	            beq $s0, 10, STOP          #if the character is the DLE character stop the inner loop
				beq $s0, 44, STOP          #stop the inner loop if the character is a comma
	            sb $s0, ($s6)              #add the character to the substring
	            addi $t2, $t2, 1           #increment the loop counter
		        addi $a1, $a1, 1           #increment the address pointer
		        addi $s6, $s6, 1           #increment the substring's addres pointer
		        j ILOOP                    #jump to top of inner loop
				
	STOP:	    sub $s6, $s6, $t2          #reinitalize the substring's address pointer
	            addi $sp, $sp, -12         #reserve space in stack 
				sw $s6, 0($sp)			   #store substring in stack
				sw $t2, 4($sp)             #store the length in stack 
				jal subprogram_1           #jump to subprogram to convert the string
				jal subprogram_3           #jumpt to subprogram to print results of conversion
				addi $sp, $sp, 12          #cancel space in stack
				beq $s0, 10, END           #if the last character was the DLE character end the program
				
				la $a0, output2            #address of string to print
				li $v0, 4		           #system call code for printing string = 4
				syscall
				j OLOOP                    #jump to top of outer loop
				
	END:        li $v0, 10                 #terminate program 
			    syscall                    #and exit
				
#SUBPROGRAM TO CONVERT HEXADECIMAL STRING TO DECIMAL INTEGERS		
subprogram_1:	
				lw $a2, 0($sp)               #read substring from stack
				lw $t7, 4($sp)               #read subtstring length from stack
				li $s2, 1				     #initialize count to 0
				li $s1, 0		             #initialize decimal to 0
				li $t0, 0                    #set $t0's value to 0
				beq $t7, 0, NOTVALID         #if the substring's length is 0 jumpt to INVALID procedure
				sub $t9, $t7, 1              #set $t9's value to 1 less than the substring's length
				add $a2, $a2, $t9            #increment the substring's address pointer by the value of $t9
		
    #REMOVES SPACES AT THE END OF THE STRING		
    CHECK:	    lb $s4, ($a2)				#load the last character of the string into $s4
				bne $s4, 32, ENDCHECK       #if the character in $t4 is not a space jump to ENDCHECK
				sub $t7, $t7, 1             #and decrement string length count
				sub $t9, $t9, 1             #as well as $t9's value
				beq $t7, 0, NOTVALID        #if the length of string is equal to 0 jump to NOTVALID
				sub $a2, $a2, 1             #decrement the string pointer
				j CHECK                     #jump to top of CHECK procedure
	ENDCHECK:	sub $a2, $a2, $t9           #decrement the pointer to the beginning of the string
				li $t9, 1                   #set $t9's value to 1
				li $s4, 0                   #set $s4's value to 0
				
    WHILELOOP:  move $t0, $s4               #move last read character into $t0 register
				lb $s4, ($a2)               #load the next character into $t4
				bgt $s2, 9, LARGE           #if the string length without spaces is greater than 9 jump to LARGE 
				bgt $t9, $t7, EXIT          #exit loop if $t9 is equal to the length of the substring
				beq $t0, 32, DO             #if the character in $t0(previous character) is a space
				bne $s2, 1, NOSPACE         #and it is not the first character jump to NOSPACE 
		DO:     beq $s4, 32, SKIP           #or if $t0 and $s4 (current character) are spaces jump to SKIP
    NOSPACE:    addi $sp, $sp, -4           #reserve space in stack 
                sw $ra, 12($sp)				#store return address in stack
				add $a0, $zero, $s4         #store the character in $a0
				jal subprogram_2            #jump to subprogram 2
				lw $ra, 12($sp)             #move the old return address from stack and back into $ra
				addi $sp, $sp, 4            #cancel space in stack
				add $v1, $v0, $zero         #move the results into $v1
				beq $v1, -3, NOTVALID       #if the returned value is -3 then the character is invalid
				beq $t7, $t9, DONE          #if the last loaded character was the last in the string jump to DONE
				
				sub $t2, $t7, $t9           #set loop counter to the value of $t7-$t9
				ble $t7, 8, LESS            #if $t7 is less than 8 jump to LESS
				sub $t2, $t7, $s2			#store the difference of $t7 and $s2 in $t2
				sub $t4, $t7, 8				#subtract 8 from $t7 and store in $t4
				sub $t2, $t2, $t4           #subtract $t4 from $t2 and store value in register $t2
    LESS:       li $t8, 16                 #load 16 into register $t8 
                li $t3, 16                 #load 16 into register $v0  
	LOOP:	    ble $t2, 1, DECIMAL        #if counter equals 1 end loop
                multu $t3, $t8             #16 *= 16
                mflo $t8 		           #store result in $t8 register
                sub $t2, $t2, 1            #increment counter
                j LOOP                     #return to top of loop
                
   DECIMAL:     multu $v1, $t8             #multiply the integer by the results to get its value in the decimal
                mflo $v1                   #put the results into the $v1 register
				
	DONE:	    add $s1, $s1, $v1          #increase the decimal's value by the results
				addi $s2, $s2, 1           #increment the count
				
	SKIP:		addi $t9, $t9, 1           #increment $t9
				addi $a2, $a2, 1           #increment the string pointer
				j WHILELOOP                #return to the top of the loop
	
	NOTVALID:   li $s1, -3                 #if the string is NaN set the decimal's value to -3
				j EXIT                     #jump to EXIT
	
	LARGE:      li $s1, -2                 #if the string is too large set the decimal's value to -2
				
	EXIT:	    sw $s1, 8($sp)             #put return value in the stack
	            jr $ra					   #exit subprogram

#SUBPROGRAM TO CONVERT CHARACTERS TO THEIR DECIMAL VALUES	   
subprogram_2:
				li $t1, '0'                #holds character '0'
				li $t2, '9' 		       #holds character '9'
				li $t3, 'a' 		       #holds character 'a'
				li $t4, 'f'		           #holds character 'f'
				li $t5, 'A'		           #holds character 'A'
				li $t6, 'F'		           #holds character 'F'	
				add $t0, $a0, $zero        #copy paramter from $a0 to $t0
				
				ble $t0, $t2, AND          #if the character is less than or equal to 9
				ble $t0, $t6, AND2         #if the character is less than or equal to 'F'
				ble $t0, $t4, AND3         #if the character is less than or equal to 'f'
				j INVALID
								  
	AND:        bge $t0, $t1, THEN         #and greater than or equal to 0 branch to LABEL1
	AND2:		bge $t0, $t5, THEN2        #and greater than or equal to 'A' branch to LABEL2
	AND3:       bge $t0, $t3, THEN3        #and greater than or equal to 'a' branch to LABEL3
				j INVALID                  #jump to INVALID procedure
	
    THEN:		subu $v0, $t0, $t1         #put the characters decimal value in $v0 register
				jr $ra   	               #return to caller
	THEN2:	    subu $v0, $t0, $t5         
				addi $v0, $v0, 10          #increase the value by 10 for letter characters
				jr $ra 
	THEN3:		subu $v0, $t0, $t3
				addi $v0, $v0, 10
				jr $ra 
	INVALID:    addi $v0, $zero, -3       #return -3 if the character is invalid
				jr $ra                   
 
#SUBPROGRAM TO PRINT THE CONVERTED HEXADECIMAL STRINGS
subprogram_3:   lw $s1, 8($sp)               #get decimal from stack
				bge $s1, $zero, POSITIVE     #if the decimal value is positive jump to POSITIVE label 
                beq $s1, -3, NAN             #if the value is -3 jump to output for invalid strings
				beq $s1, -2, TOOLARGE        #if the value is -2 jump hexadecimals that are too large
		        li $t0, 100000               #load 100000 into register $t0
				divu $s1, $t0                #divide the decimal value by 100000 to split 
			    mflo $v1                     #store the quotient in $v1 register
				mfhi $s1                     #store the remainder in the $s1 register     
				
				move $a0, $v1                #move contents of $v1 register into $a0
				li $v0, 1                    #system call code for printing integer = 1
				syscall  
				                              
    POSITIVE:   move $a0, $s1                #move contents of $s1 register into $a0
				li $v0, 1                    #system call code for printing integer = 1
				syscall
				j RETURN                     #jump to RETURN

   NAN:         la $a0, invalid              #address of string to print
				li $v0, 4		             #system call code for printing string = 4
				syscall 
				j RETURN
				
  TOOLARGE:     la $a0, toolarge             #address of string to print
				li $v0, 4		             #system call code for printing string = 4
				syscall 
				
     RETURN:	jr $ra                      #return to main
    