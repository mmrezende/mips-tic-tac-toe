.data
	board: .ascii "\0\0\0\0\0\0\0\0\0\0" # 3x3 board, storing the current game state as characters
	turn: .byte 1 # Who's turn is to play (1 for 'X' and 0 for 'O')
.text
	jal main # Call the main procedure (start the program)
	
	# Store the value 17 in the $v0 register (exit2 syscall)
	# set $a0 to 0
	# and issue a system call
	# (exit the program successfully)
	li $v0, 17
	li $a0, 0
	syscall
	# Procedure to verify if the game has finished (either someone won or it's a draw)
	# Args: NONE
	# Return value: $v0
	# 0 - Game is still running
	# 1 - 'X' won
	# 2 - 'O' won
	# 3 - Draw
	evaluate_board:
		li $v0, 0
		
		jr $ra
	
	print_board:
		for_1:
	
		jr $ra
	
	print_turn:
		jal print_board
		jr $ra
	# Prints a message according to how the game ended
	# Args: $a0
	# Return value: NONE
	print_result:
		# TODO
		# should be a switch-case using $a0
		
		jr $ra
	
	# Main procedure
	# Stack:
	# 0 - 4 | $ra
	# Args: NONE
	# Result Value: NONE
	main:
	# Prologue
		# Increase stack by 4 bytes
		addiu $sp, $sp, -4
		# Store $ra at $sp
		sw $ra, ($sp)
	
	# Body
		# Main Game Loop
		main_loop:
			jal evaluate_board
			bnez $v0, end_main_loop
		end_main_loop:
		
		move $a0, $v0
		jal print_result
		
	# Epilogue
		# Restore $ra value
		lw $ra, ($sp)
		# Reduce stack by 4 bytes
		addiu $sp, $sp, 4
		
		jr $ra