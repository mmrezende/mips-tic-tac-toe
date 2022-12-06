.data
	boardX: .byte 0 # byte storing the positions marked as X
	boardO: .byte 0 # byte storing the positions marked as O
.text
	jal main # Call the main procedure (start the program)
	
	# Set $a0 to the return value of main
	# set $v0 register to 17 (exit2 syscall)
	# and issue a system call
	move $a0, $v0
	li $v0, 17
	syscall
	
	# User interaction to get the player's move
	# Args: NONE
	# Return value: NONE
	player_input:
	
		jr $ra
	
	# AI Logic to choose it's move
	# Args: NONE
	# Return value: NONE
	bot_play:
	
		jr $ra
	
	# Procedure that modifies the board according to who's turn is to play
	# Args: 
	# $a0 - isXTurn (Who's turn is to play)
	# $a1 - isBotX (if bot plays as X)
	# Return value: NONE
	# Stack:
	#
	play:
	
		jr $ra
	
	# Logic to verify if the game has finished (either someone won or it's a draw)
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
	
		end_for_1:
		jr $ra
	
	# Prints a message according to the game state
	# Args: $a0 - boardState
	# Return value: NONE
	print_turn:
		# TODO
		# should be a switch-case using $a0
		jal print_board
		
		jr $ra
	
	# Main procedure
	# Args: NONE
	# Return value: $v0 - exit2 status
	# Stack:
	# 12 - 16 | isXTurn (Who's turn is to play)
	# 8 - 12  | isBotX (if bot plays as X)
	# 4 - 8   | boardState (return value of evaluate_board)
	# 0 - 4   | $ra (return address)
	main:
	# Prologue
		# Increase stack
		addiu $sp, $sp, -16
		# Store $ra at $sp
		sw $ra, ($sp)
	
	# Body
		# TODO: generates a pseudo-random boolean to decide who starts the game
		# defaults to player first
		sw $zero, 8($sp)
		
		# isXTurn = TRUE (X starts the game)
		li $t0, 1
		sw $t0, 12($sp)
	
		# Main Game Loop
		main_loop:
			jal evaluate_board
			sw $v0, 4($sp)
			move $a0, $v0
			jal print_result
			
			# Break loop if game has ended (boardState=0)
			lw $t0, 4($sp)
			bnez $t0, end_main_loop
			
			# Otherwise, play
			# play(isXTurn, isBotX)
			lw $a0, 12($sp)
			lw $a1, 8($sp)
			jal play
			
			j main_loop
		end_main_loop:
		
	# Epilogue
		# Restore $ra value
		lw $ra, ($sp)
		# Reduce the stack
		addiu $sp, $sp, 16
		
		jr $ra
