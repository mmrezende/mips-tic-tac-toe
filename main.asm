.data
	board: .ascii "\0\0\0\0\0\0\0\0\0\0" # 3x3 board, storing the current game state as characters
.text
	jal main # Call the main procedure (start the program)
	
	# Store the value 10 in the $v0 register
	# and issue a system call
	# (exit the program successfully)
	li $v0, 10
	syscall
	
	main: # Main procedure
	
		jr $ra # Go back to the instruction where the procedure was called