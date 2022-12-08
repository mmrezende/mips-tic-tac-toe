.data
	board: .word 0 # 4 bytes storing the positions marked either as X or O
	
	drawMask: .word 0x1FF
	winMasks: .word 0x7, 0x38, 0x1C0, 0x49, 0x92, 0x124, 0x111, 0x54

	emptyRow:   .asciiz "      |     |     \n"
	contentRowBegin: .asciiz "   "
	contentRowSeparator: .asciiz "  |  "
	contentRowEnd: .asciiz "  \n"
	divRow:     .asciiz " _____|_____|_____\n"
	inputSpaceMessage: .asciiz "\nDigite a posição desejada [1-9]: "
	invalidSpaceMessage: .asciiz "\nA casa selecionada é inválida, pois deve estar no intervalo [1,9].\n"
	takenSpaceMessage: .asciiz "\nA casa selecionada já foi preenchida. Selecione uma casa vazia.\n"
	xWonMessage: .asciiz "\nX venceu!\n"
	oWonMessage: .asciiz "\nO venceu!\n"
	drawMessage: .asciiz "\nDeu velha! :/\n"
.text	
	jal main # Call the main procedure (start the program)
	
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
	# Return value: $v0 - boolean
	# Stack: 
	# 0 - 4 | $ra
	validate_input:
	# Prologue
		subi $sp, $sp, 4
		sw $ra, ($sp)
	# Body
		# $t1 = input < 1
		li $t0, 1
		slt $t1, $a0, $t0
		# $t2 = input > 9
		li $t0, 9
		sgt $t2, $a0, $t0
		
		# $t0 = inputIsInvalid
		# that is, input < 1 || input > 9 (out of allowed range)
		or $t0, $t1, $t2
		
		beqz $t0, else_1
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
			sllv $t3, $t1, $t2
		
			# Is there a common bit between the board and the selected space?
			and $t4, $t0, $t3
			
			li $v0, 1
			beqz $t4, end_if_2
			if_2: # yes, so the space is taken ($t4 = 1)
				# print takenSpaceMessage
				li $v0, 4
				la $a0, takenSpaceMessage
				syscall
				
				li $v0, 0
			end_if_2: # no
		end_if_1:
	# Epilogue
		lw $ra, ($sp)
		addi $sp, $sp, 4
		
		jr $ra
	
	# User interaction to get the player's move
	# Accepted positions are 1-9
	# Args: NONE
	# Return value: $v0 - player input
	# Stack:
	# 4 - 8 | input
	# 0 - 4 | $ra
	get_user_move:
	# Prologue
		subi $sp, $sp, 8
		sw $ra, ($sp)
	# Body
		do_while_1: # Gets an input until it's valid		
			# print inputSpaceMessage
			li $v0, 4
			la $a0, inputSpaceMessage
			syscall
		
			# Read integer syscall
			li $v0, 5
			syscall
			
			# Save input in the stack
			sw $v0, 4($sp)
			
			# validateInput(input)
			move $a0, $v0
			jal validate_input
			
			# if $v0 == 0, continue
			beqz $v0, do_while_1
		end_do_while_1:
		# last input was valid
		# return input
		lw $v0, 4($sp)
		
	# Epilogue
		lw $ra, ($sp)
		addi $sp, $sp, 8
		jr $ra
	
	# AI Logic to choose it's move
	# Args: $a0 - isBotX
	# Return value: $v0 - bot's move
	# Stack
	# 0 - 4
	get_bot_move:
	# Prologue
		subi $sp, $sp, 4
		sw $ra, ($sp)
	# Body
		jal boardX
		move $t0, $v0
		jal boardO
		or $t0, $t0, $v0
		
		get_bot_move_while_1:
			li $v0, 30
			syscall
			
			li $a0, 1
			li $a1, 9
			li $v0, 42
			syscall
			move $v0, $a0
			
			subi $a0, $a0, 1
			srlv $t1, $t0, $a0
			and $t1, $t1, 1
			
			bnez $t1, get_bot_move_while_1
		end_get_bot_move_while_1:
		
	# Epilogue
		lw $ra, ($sp)
		addi $sp, $sp, 4
	
		jr $ra
	
	# Procedure that modifies the board according to who's turn is to play
	# Args: 
	# $a0 - isXTurn (Who's turn is to play)
	# $a1 - isBotX (if bot plays as X)
	# Return value: NONE
	# Stack:
	# 8 - 12 | $a1 - isBotX
	# 4 - 8 | $a0 - isXTurn
	# 0 - 4 | $ra
	play:
	# Prologue
		subi $sp, $sp, 12
		sw $ra, ($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
	# Body
		xor $t0, $a0, $a1 # $t0 = isUserTurn
		
		beqz $t0 play_else_1
		play_if_1: # isUserTurn
			jal get_user_move
			# $t0 = user_move
			move $t0, $v0
			j end_play_if_1
		play_else_1: # isBotTurn
			lw $a0, 8($sp)
			jal get_bot_move
			# $t0 = bot_move
			move $t0, $v0
		end_play_if_1:
		# $t1 = isBotX
		lw $t1, 8($sp)
		
		# $t2 = 0x00000001
		li $t2, 1
		
		lw $t4, board
		
		beqz $t1, play_else_2
		play_if_2: # Player is O
			# $t0 += 9-1 = 8 (boardO is stored in the 19th-10th bits)
			# and humans count beginning from 1
			addi $t0, $t0, 8
			
			j play_end_if_2
		play_else_2: # Player is X
			# $t0-- (humans count beginning from 1)
			subi $t0, $t0, 1
		play_end_if_2:
		
		# shifts the bit 1 to the desired position:
		# move -1 times if X
		# move -1 + 9 times if O
		# and stores the resulting byte in $t3
		sllv $t3, $t2, $t0
		
		# saves the board intersection with the new move
		or $t4, $t4, $t3
		sw $t4, board
	
	# Epilogue
		lw $ra, ($sp)
		addi $sp, $sp, 12
		
		jr $ra
		
	# Returns true if the provided board has won
	# Args: $a0 (board)
	# Return value: $v0 (bool)
	# Stack: NONE
	has_board_won:		
		la $t0, winMasks
		li $t1, 0
		li $t3, 0 # accumulator
		has_board_won_for_1: # i = 1,9
			bgt $t1, 9, end_has_board_won_for_1
			
			# $t2 = mask[i]
			sll $t2, $t1, 2
			addu $t2, $t2, $t0
			lw $t2, ($t2)
			
			# and between mask and board
			and $t4, $t2, $a0
			# is the result equal to the mask?
			seq $t4, $t4, $t2
			# accumulator |= $t4
			or $t3, $t3, $t4
			
			addi $t1, $t1, 1
			j has_board_won_for_1
		end_has_board_won_for_1:
		
		# board has won if accumulator is not zero
		sne $v0, $t3, $zero
		
		jr $ra
	
	# Logic to verify if the game has finished (either someone won or it's a draw)
	# Args: NONE
	# Return value: $v0
	# 0 - Game is still running
	# 1 - 'X' won
	# 2 - 'O' won
	# 3 - Draw
	# Stack:
	# 8 - 12 | boardO
	# 4 - 8 | boardX
	# 0 - 4 | $ra
	evaluate_board:
	# Prologue
		subi $sp, $sp, 12
		sw $ra, ($sp)
	# Body
		jal boardX
		sw $v0, 4($sp)
		jal boardO
		sw $v0, 8($sp)
		
		lw $a0, 4($sp) # $a0 = boardX
		jal has_board_won
		
		beqz $v0, evaluate_board_else_1
		evaluate_board_if_1: # X has won
			li $v0, 1
			
			j end_evaluate_board_if_1
		evaluate_board_else_1: # X has not won
			lw $a0, 8($sp) # $a0 = boardO
			jal has_board_won
			
			beqz $v0, evaluate_board_else_2
			evaluate_board_if_2: # O has won
				li $v0, 2
				j end_evaluate_board_if_2
			evaluate_board_else_2: # Nobody won yet
				lw $t0, 4($sp) # $t0 = boardX
				lw $t1, 8($sp) # $t1 = boardO
				
				or $t0, $t0, $t1 # $t0 |= $t1
				lw $t1, drawMask
				bne $t0, $t1, evaluate_board_else_3
				evaluate_board_if_3: # Draw
					li $v0, 3
					
					j end_evaluate_board_if_3
				evaluate_board_else_3: # Game is still running
					li $v0, 0	
				end_evaluate_board_if_3:
			end_evaluate_board_if_2:
		end_evaluate_board_if_1:
		
	# Epilogue
		lw $ra, ($sp)
		addi $sp, $sp, 12
	
		jr $ra
	
	# Prints the current char at the desired board position
	# Args: $a0 (x), $a1 (y) (both between 0-2)
	# Return: NONE
	# Stack:
	# 12 - 16 | boardX
	# 8 - 12 | $a1
	# 4 - 8 | $a0
	# 0 - 4 | $ra
	print_house:
	# Prologue
		subi $sp, $sp, 16
		sw $ra, ($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
	# Body
		jal boardX
		sw $v0, 12($sp)
	
		jal boardO
		# $t0 = boardX
		lw $t0, 12($sp)
		# $t1 = boardO
		move $t1, $v0
		
		# $t2 = x
		lw $t2, 4($sp)
		# $t3 = y
		lw $t3, 8($sp)
		
		# $t3 *= 3 (row size)
		mulu $t3, $t3, 3
		# $t2 = 3*y + x
		addu $t2, $t2, $t3
		
		get_house_switch:
			srlv $t4, $t0, $t2
			and $t4, $t4, 0x00000001
			beq $t4, 1, get_house_case_X # There is a X at the selected position
			
			srlv $t4, $t1, $t2
			and $t4, $t4, 0x00000001
			beq $t4, 1, get_house_case_O # There is a O at the selected position
			
			j get_house_case_empty # It's empty
			get_house_case_X:
				li $t5, 'X'
			
				j get_house_end_switch
			get_house_case_O:
				li $t5, 'O'
				
				j get_house_end_switch
			get_house_case_empty:
				li $t5, ' '
		get_house_end_switch:
		
		move $a0, $t5
		li $v0, 11
		syscall
	# Epilogue
		lw $ra, ($sp)
		addi $sp, $sp, 16
	
		jr $ra
	
	# Prints a row of the board
	# Args: $a0 - rowNumber
	# Return value: NONE
	# Stack:
	# 4 - 8 | $a0
	# 0 - 4 | $ra
	print_content_row:
	# Prologue
		subi $sp, $sp, 8
		sw $ra, ($sp)
		sw $a0, 4($sp)
	# Body		
		# print string syscall
		li $v0, 4
		la $a0, contentRowBegin
		syscall
		
		# print char syscall
		# print first entry
		li $a0, 0
		lw $a1, 4($sp)
		jal print_house
		
		li $v0, 4
		la $a0, contentRowSeparator
		syscall
		
		# print second entry
		li $a0, 1
		lw $a1, 4($sp)
		jal print_house
		
		li $v0, 4
		la $a0, contentRowSeparator
		syscall
		
		# print third entry
		li $a0, 2
		lw $a1, 4($sp)
		jal print_house
		
		li $v0, 4
		la $a0, contentRowEnd
		syscall
		
	# Epilogue
		lw $ra, ($sp)
		addi $sp, $sp, 8
	
		jr $ra
	
	# Prints the current state of the board
	# Stack:
	# 0 - 4 | $ra
	print_board:
	# Prologue
		subi $sp, $sp, 4
		sw $ra, ($sp)
	# Body
		# print syscall
		li $v0, 4
		la $a0, emptyRow
		syscall
		
		# print the first contentRow
		li $a0, 0
		jal print_content_row
		
		li $v0, 4
		la $a0, divRow
		syscall
		
		la $a0, emptyRow
		syscall
		
		# print the second contentRow
		li $a0, 1
		jal print_content_row
		
		li $v0, 4
		la $a0, divRow
		syscall
		
		la $a0, emptyRow
		syscall
		
		# print the third contentRow
		li $a0, 2
		jal print_content_row
		
		li $v0, 4
		la $a0, emptyRow
		syscall
	# Epilogue
		lw $ra, ($sp)
		addi $sp, $sp, 4
		
		jr $ra
	
	# Prints a message according to the game state
	# Args: $a0 - boardState
	# 0 - Game is still running
	# 1 - 'X' won
	# 2 - 'O' won
	# 3 - Draw
	# Return value: NONE
	# Stack:
	# 4 - 8 | $a0
	# 0 - 4 | $ra
	print_turn:
	# Prologue
		subi $sp, $sp, 8
		sw $ra, ($sp)
		sw $a0, 4($sp)
	# Body
		jal print_board
		
		print_turn_switch:
			lw $t0, 4($sp)
			li $v0, 4
			
			beq, $t0, 0, print_turn_case_0
			beq, $t0, 1, print_turn_case_1
			beq, $t0, 2, print_turn_case_2
			beq, $t0, 3, print_turn_case_3
			
			print_turn_case_0: # TODO?
				j end_print_turn_switch
			print_turn_case_1:
				la $a0, xWonMessage
				syscall
				j end_print_turn_switch
			print_turn_case_2:
				la $a0, oWonMessage
				syscall
				j end_print_turn_switch
			print_turn_case_3:
				la $a0, drawMessage
				syscall
				j end_print_turn_switch
		end_print_turn_switch:
	
	# Epilogue
		lw $ra, ($sp)
		addi $sp, $sp, 8
	
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
		subi $sp, $sp, 16
		# Store $ra at $sp
		sw $ra, ($sp)
	
	# Body
		# TODO: generates a pseudo-random boolean to decide who plays as X
		# defaults to user as X and bot as O
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
			
			# switch turns
			lw $t1, 8($sp)
			seq $t1, $t1, $zero # $t1 != $t1
			sw $t1, 8($sp)
			
			j main_loop
		end_main_loop:
		
	# Epilogue
		# Restore $ra value
		lw $ra, ($sp)
		# Reduce the stack
		addi $sp, $sp, 16
		
		jr $ra
