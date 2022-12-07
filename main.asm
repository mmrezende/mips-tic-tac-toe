.data
	board: .word 0 # 4 bytes storing the positions marked either as X or O
	
	invalidSpaceMessage: .asciiz "A casa selecionada é inválida, pois deve estar no intervalo [1,9]."
	takenSpaceMessage: .asciiz "A casa selecionada já foi preenchida. Selecione uma casa vazia."
.text
	li $a0, 0
	jal player_input
	
	li $a0, 0
	jal player_input
	#jal main # Call the main procedure (start the program)
	
	# Set $a0 to the return value of main
	# set $v0 register to 17 (exit2 syscall)
	# and issue a system call
	move $a0, $v0
	li $v0, 17
	syscall
	
	# Gets the values marked as X (first 9 bits)
	# Args: NONE
	# Return value: $v0 - boardX
	# Stack: NONE
	boardX:
		lw $v0, board
		and $v0, $v0, 0x000001FF
	
		jr $ra
	
	# Gets the values marked as O (10th bit - 19 bit)
	# Args: NONE
	# Return value: $v0 - boardO
	# Stack: NONE
	boardO:
		lw $v0, board
		srl $v0, $v0, 9
		and $v0, $v0, 0x000001FF
		
		jr $ra
	
	# Verifies if the selected position is valid or not
	# and prints the corresponding message, if applicable
	# Args: 
	# $a0 - position
	# $a1 - isBotX
	# Return value: $v0 - boolean
	# Stack: 
	# 0 - 4 | $ra
	validate_input:
	# Prologue
		subi $sp, $sp, 4
		sw $ra, ($sp)
	# Body
		# $t0 = input < 1
		slti $t0, $a0, 1
		# $t1 = input > 10
		slti $t1, $a0, 10
		not $t1, $t1
		# $t2 = input < 1 || input > 10
		or $t2, $t1, $t0
		
		bnez $t2, else_1
		if_1: # Input is invalid
			# print invalidSpaceMessage
			li $v0, 4
			la $a0, invalidSpaceMessage
			syscall
			
			# return false
			li $v0, 0
			
			j end_if_1
		else_1: # Input is valid
			jal boardO
			move $t0, $v0
			
			jal boardX
			move $t1, $v0
			# $t0 &= $t1
			# $t0 contains all the ocuppied spaces on the board
			or $t0, $t0, $t1
			
			# $t2 = 0x0001
			li $t1, 1
		
			# shifts the bit 1 to the desired position (input-1 times)
			# and stores the resulting byte in $t3
			subi $t2, $a0, 1
			sllv $t3, $t2, $t1
		
			# Is there a common bit between the board and the selected space?
			and $t4, $a0, $t0
		
			# $t0 = $t4 != 0
			sne $t0, $t4, $zero
			
			bnez $t0, end_if_2
			if_2:
				# print takenSpaceMessage
				li $v0, 4
				la $a0, takenSpaceMessage
				syscall
			end_if_2:
			
			# return isValid
			move $v0, $t0
		end_if_1:
	# Epilogue
		addi $sp, $sp, 4
		lw $ra, ($sp)
		
		jr $ra
	
	# User interaction to get the player's move
	# Accepted positions are 1-9
	# Args: $a0 - isBotX (if bot plays as X)
	# Return value: NONE
	# Stack:
	# 8 - 12 | input
	# 4 - 8 | $a0
	# 0 - 4 | $ra
	player_input:
	# Prologue
		subi $sp, $sp, 12
		sw $ra, ($sp)
		sw $a0, 4($sp)
	# Body
		do_while_1: # Gets an input until it's valid
			# Read integer syscall
			li $v0, 5
			syscall
			
			# Save input in the stack
			sw $v0, 8($sp)
			
			# validateInput(input, isBotX)
			move $a0, $v0
			lw $a1, 4($sp)
			jal validate_input
			
			# if $v0 == 0, continue
			beqz $v0, do_while_1
		end_do_while_1:
		
		# $t0 = isBotX
		lw $t0, 4($sp)
		
		# $t1 = input
		lw $t1, 8($sp)
		
		# $t2 = 0x0001
		li $t2, 1
		
		# shifts the bit 1 to the desired position ($t1-1 times)
		# and stores the resulting byte in $t3
		subi $t1, $t1, 1
		sllv $t3, $t2, $t1
				
		beqz $t0, else_3
		if_3: # Human plays as O
			# boardO |= $t3 (bitwise OR)
			lw $t4, boardO
			or $t4, $t4, $t3
			sw $t4, boardO
			
			j end_if_3
		else_3: # Human plays as X
			# boardZ |= $t3 (bitwise OR)
			lw $t4, boardX
			or $t4, $t4, $t3
			sw $t4, boardX
		end_if_3:
		
	# Epilogue
		lw $ra, ($sp)
		addi $sp, $sp, 12
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
			jal print_turn
			
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
