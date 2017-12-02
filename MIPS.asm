#PROGRAM: CONVERT A STRING WITH MULTIPLE HEXADECIMAL VALUES TO THEIR DECIMAL VALUES

.data  
	newline: .asciiz "\n"
	invalid: .asciiz "NaN"
	toolarge: .asciiz "too large"
	buffer:  .space 1001
	substring: .space 1001    #assuming that the user input can be 1 hexadecimal with 1000 characters(including spaces)
.text
###########################################################main
#GETS USER INPUT AND CALLS SUBPROGRAM_2 AND SUBPROGRAM_3
#
# Arg registers used: $a0, $a1
# Sve registers used: $s0, $s6, $s7
# Tmp registers used: $t2
# Pointers used: $sp
#
# Pre: none
# Post: none
# Returns: none
#
# Called by: none
# Calls: subprogram_2, subprogram_3  
main: 
	 			li $v0, 8                  #system call code for reading string = 8
				la $a0, buffer             #load byte space into address
				li $a1, 1001               #allot the byte space for hexadecimal
				syscall
				
				addi $a1, $a0, 0           #move address of hexadecimal into $a1 then into $s5
				addi $s7, $a1, 0
				la $s6, substring          #load byte space into address for substring
				j ILOOP                    #jumps to inner loop
				
	OLOOP:		la $s6, substring          
			    li $t2, 0                  #set $t2's value to 0
			    addi $s7, $s7, 1           #increment address pointer
	ILOOP:		lb $s0, ($s7)              #get first byte of string and store in $s0
	            beq $s0, 10, STOP          #if the character is the DLE character stop the inner loop
				beq $s0, 44, STOP          #stops the inner loop if the character is a comma
	            sb $s0, ($s6)              #add the character to the substring
	            addi $t2, $t2, 1           #increment the loop counter
		        addi $s7, $s7, 1           #increment the address pointer
		        addi $s6, $s6, 1           #increment the substring's address pointer
		        j ILOOP                    #jump to top of inner loop
				
	STOP:	    sub $s6, $s6, $t2          #reinitalize the substring's address pointer
	            addi $sp, $sp, -4          #reserve space in stack for decimal 
				add $a0, $s6, $zero		   #pass substring as a parameter
				add $a1, $t2, $zero        #pass substring's length as a parameter
				jal subprogram_2           #jump to subprogram_2 to convert the string
				jal subprogram_3           #jump to subprogram_3 to print results of conversion
				addi $sp, $sp, 4           #cancel space in stack
				beq $s0, 10, END           #if the last character was the DLE character end the program
				
				la $a0, 44            	   #load character to print
				li $v0, 11		           #system call code for printing character = 11
				syscall
				j OLOOP                    #jump to top of outer loop
				
	END:        la $a0, newline            #address of string to print
				li $v0, 4		           #system call code for printing string = 4
				syscall
				li $v0, 10                 #terminate program 
			    syscall                    #and exit

####################################################################subprogram_1				
#SUBPROGRAM TO CONVERT A HEXADECIMAL CHARACTER TO ITS DECIMAL VALUE 
#
# Arg registers used: $a0
# Tmp registers used: $t0, $t1, $t2, $t3, $t4, $t5, $t6
#
# Pre: $a0 contains character to convert
# Post: $v0 contains the return value
# Returns: the value of $a0 as a decimal
#
# Called by: subprogram_2
# Calls: none   
subprogram_1:
				li $t1, '0'                #holds character '0'
				li $t2, '9' 		       #holds character '9'
				li $t3, 'a' 		       #holds character 'a'
				li $t4, 'f'		           #holds character 'f'
				li $t5, 'A'		           #holds character 'A'
				li $t6, 'F'		           #holds character 'F'	
				add $t0, $a0, $zero        #copy parameter from $a0 to $t0
				
				ble $t0, $t2, AND          #if the character is less than or equal to 9
				ble $t0, $t6, AND2         #if the character is less than or equal to 'F'
				ble $t0, $t4, AND3         #if the character is less than or equal to 'f'
				j INVALID				   #else jump to INVALID procedure
								  
	AND:        bge $t0, $t1, THEN         #and greater than or equal to 0 branch to LABEL1
	AND2:		bge $t0, $t5, THEN2        #and greater than or equal to 'A' branch to LABEL2
	AND3:       bge $t0, $t3, THEN3        #and greater than or equal to 'a' branch to LABEL3
				j INVALID                  #else jump to INVALID procedure
	
	THEN:		subu $v0, $t0, $t1         #put the character's decimal value in $v0 register
				jr $ra   	               #return to caller
	THEN2:	    subu $v0, $t0, $t5         
				addi $v0, $v0, 10          #increase the value by 10 for letter characters
				jr $ra 
	THEN3:		subu $v0, $t0, $t3
				addi $v0, $v0, 10		   #increase the value by 10 for letter characters
				jr $ra 
	INVALID:    addi $v0, $zero, -3        #return -3 if the character is invalid
				jr $ra  				

#########################################################subprogram_2				
#SUBPROGRAM TO CONVERT HEXADECIMAL STRINGS TO DECIMAL INTEGERS	
#
# Arg registers used: $a0, $a1
# Tmp registers used: $t0, $t2, $t3, $t4, $t7, $t8, $t9
# Sve registers used: $s1, $s2, $s4, $s5
# Pointers used: $sp
#
# Pre: $a0 contains substring and $a1 contains substring length
# Post: 0($sp) contains decimal value
# Returns: the decimal value of the subtring passed in $a0
#
# Called by: main
# Calls: subprogram_1	
subprogram_2:	
				add $s5, $a0, $zero			 #copy substring from $a0
				add $t7, $a1, $zero          #copy string length from $a1
				li $s2, 1				     #initialize count to 0
				li $s1, 0		             #initialize decimal to 0
				li $t0, 0                    #set $t0's value to 0
				beq $t7, 0, NOTVALID         #if the substring's length is 0 jump to INVALID procedure
				sub $t9, $t7, 1              #set $t9's value to 1 less than the substring's length
				add $s5, $s5, $t9            #increment the substring's address pointer by the value of $t9
		
    #if there are spaces at the end of the string decrement the string length value		
    CHECK:	    lb $s4, ($s5)				#load character into $s4
				beq $s4, 32, SKIPTAB       	#if the character is a space jump to SKIPTAB
				bne $s4, 9, ENDCHECK        #if the character is not a space or tab exit CHECK procedure
	SKIPTAB:	sub $t7, $t7, 1             #decrement string length count
				sub $t9, $t9, 1             #as well as $t9's value
				beq $t7, 0, NOTVALID        #if the length of string is equal to 0 jump to NOTVALID
				sub $s5, $s5, 1             #decrement the string pointer
				j CHECK                     #jump to top of CHECK procedure
	ENDCHECK:	sub $s5, $s5, $t9           #decrement the pointer to the beginning of the string
				li $t9, 1                   #set $t9's value to 1
				li $s4, 0                   #set $s4's value to 0
				
    WHILELOOP:  move $t0, $s4               #move last read character into $t0 register
				lb $s4, ($s5)               #load the next character into $s4
				bgt $t9, $t7, LARGE         #exit loop if $t9 is equal to the length of the substring
				beq $t0, 32, DO             #if the character in $t0(previous character) is a space
				beq $t0, 9, DO              #or if the character is a tab
				bne $s2, 1, NOSPACE         #and $s2 is not 1 jump to NOSPACE 
	DO:         beq $s4, 32, SKIP           #or if $t0 and $s4 (current character) are spaces 
				beq $s4, 9, SKIP			#or tabs jump to SKIP
    NOSPACE:    addi $sp, $sp, -4           #reserve space in stack 
                sw $ra, 4($sp)				#store return address in stack
				add $a0, $zero, $s4         #store the character in $a0 as a parameter
				jal subprogram_1            #jump to subprogram 1
				lw $ra, 4($sp)              #move the old return address from stack back into $ra
				addi $sp, $sp, 4            #cancel space in stack
				add $v1, $v0, $zero         #move the results into $v1
				beq $v1, -3, NOTVALID       #if the returned value is -3 then the character is invalid
				beq $t7, $t9, DONE          #if the last loaded character was the last in the string jump to DONE
				
				sub $t2, $t7, $t9           #set loop counter to the value of $t7-$t9
				ble $t7, 8, LESS            #if $t7 is less than 8 
				bne $s2, $t9, LESS			#or if there were no spaces in front jump to LESS
				sub $t2, $t7, $s2			#this section automatically sets the length of
				sub $t4, $t7, 8				#the string to 8 if it is larger than 8 and has no spaces
				sub $t2, $t2, $t4           #to determine if the overall string is NaN
    LESS:       li $t8, 16                 #load 16 into register $t8 
                li $t3, 16                 #load 16 into register $v0  
	LOOP:	    ble $t2, 1, DECIMAL        #if counter equals 1 end loop
                multu $t3, $t8             #16 *= 16
                mflo $t8 		           #store result in $t8 register
                sub $t2, $t2, 1            #increment counter
                j LOOP                     #return to top of loop
                
    DECIMAL:    multu $v1, $t8             #multiply the integer by the results to get its value in the decimal
                mflo $v1                   #put the results into the $v1 register
				
	DONE:	    add $s1, $s1, $v1          #increase the decimal's value by the results
				addi $s2, $s2, 1           #increment the count
				
	SKIP:		addi $t9, $t9, 1           #increment $t9
				addi $s5, $s5, 1           #increment the string pointer
				j WHILELOOP                #return to the top of the loop
	
	NOTVALID:   li $s1, -3                 #if the string is NaN set the decimal's value to -3
				j EXIT                     #jump to EXIT
	
	LARGE:      ble $s2, 9, EXIT           #if the string length without spaces is greater than 9  
				li $s1, -2                 #set the decimal's value to -2
				
	EXIT:	    sw $s1, 0($sp)             #put return value in the stack
	            jr $ra					   #exit subprogram
				                 

##############################################subprogram_3 
#SUBPROGRAM TO PRINT THE CONVERTED DECIMAL VALUES
#
# Arg registers used: $a0 
# Tmp registers used: $t0
# Sve registers used: $s1
# Pointers used: $sp
#
# Pre: 0($sp)contains decimal value to be outputted
# Post: decimal value is outputted
# Returns: none
#
# Called by: main
# Calls: none   
subprogram_3:   lw $s1, 0($sp)               #get decimal from stack
				bge $s1, $zero, POSITIVE     #if the decimal value is positive jump to POSITIVE label 
                beq $s1, -3, NAN             #if the value is -3 jump to output for invalid strings
				beq $s1, -2, TOOLARGE        #if the value is -2 jump to output for hexadecimals that are too large
		        li $t0, 100000               #load 100000 into register $t0
				divu $s1, $t0                #divide the decimal value by 100000 to split the decimal 
			    mflo $v1                     #store the quotient in $v1 register
				mfhi $s1                     #store the remainder in the $s1 register     
				
				move $a0, $v1                #move contents of $v1 register into $a0
				li $v0, 1                    #system call code for printing integer = 1
				syscall  
				                              
   POSITIVE:    move $a0, $s1                #move contents of $s1 register into $a0
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
				
  RETURN:	    jr $ra                      #return to main
    