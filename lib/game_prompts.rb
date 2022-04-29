# frozen_string_literal: true

module GamePrompts
  def tutorial_message
    <<-HEREDOC
Welcome to Chess!

The goal of this game is to capture the other player's King ♔. 

Each turn will have 2 steps:
  1) Enter the coordinates of the piece you want to move.
  2) Enter the coordinates of the cell you want the selected piece to move to.

    HEREDOC
  end

  def game_mode_message
    <<-HEREDOC
To begin, please select one of the following game options:
  [1]: Start a new two-player game.
  [2]: Continue playing a saved game.
    HEREDOC
  end

  def select_game_mode
    input = gets.chomp.to_i
    return input if [1, 2].include?(input)
    
    puts "Input error! Please enter 1 (new game) or 2 (load game)."
    select_game_mode
  end

  def select_color(player)
    puts "#{player}, would you like to play as [B] Black or [W] White?"
    input = gets.chomp.upcase
    return input.to_sym if ['B', 'W'].include?(input)
    puts 'Please enter [B] for Black or [W] for White!'
    select_color(player)
  end

  # Select the Active Piece (Piece to be Moved)
  def select_active_piece
    puts "#{@current_player.name}, please enter the coordinates of the piece you want to move:"
    puts "Enter [Q] to quit, or [S] to save the current game."
    input = verify_piece_input(gets.chomp)
    case input 
    when InputWarning # Invalid input 
      puts input.to_s
      select_active_piece
    when Symbol # Quit
      return input 
    when String # Valid input
      piece = @board.find_cell(input).piece
      @board.set_active_piece(piece)
    end
  end

  # Select the Active Move (Cell to be moved to (by the Active Piece))
  def select_active_move
    puts "#{@current_player.name}, please enter the coordinates of the cell you want to move to:"
    input = verify_move_input(gets.chomp)
    if input.is_a?(InputWarning)
      puts input.to_s
      select_active_move
    else
      cell = @board.find_cell(input)
      direction = @board.active_piece.moves.select { |dir, cells| cells.include?(cell) }.keys.first
      { dir: direction, cell: cell }
    end
  end

  private

  def invalid_input_format_message
    "Invalid input! Please enter a valid set of alphanumeric coordinates (eg. d2)"
  end

  def invalid_input_cell_message(current_color)
    "Invalid input! Please enter a pair of coordinates corresponding to a cell that is currently occupied by a #{current_color} Piece"
  end

  def invalid_input_piece_message
    "Invalid input! That piece does not have any legal moves it can make."
  end

  def invalid_input_move_message
    "Invalid input! The selected piece cannot move to that cell."
  end

  def king_check_warning(king_color)
    "Warning! The #{king_color.to_string} King is currently under Check!"
  end

  def king_checkmate_message(king_color)
    "#{king_color.to_string}'s King is in checkmate! #{@current_player.name} wins!"
  end

  def resigned_message
    "#{@current_player.name} resigned! #{Player.find(@current_color.opposite).name} wins!"
  end

  def replay_game_message
    "Would you like to play again [P] or quit [Q]?"
  end

  def invalid_replay_input_warning
    "Invalid input! Please enter P (play again) or Q (quit)."
  end

  def pawn_promotion_message
    <<-HEREDOC
#{@current_player.name}, your Pawn is being promoted! Select one of the following:
    [Q]-Queen   [R]-Rook    [B]-Bishop    [Kn]-Knight
    HEREDOC
  end

  def invalid_promotion_message
    "Invalid input! Please select one of the types above for your Pawn to promote to."
  end

  def en_passant_message
    <<-HEREDOC
#{@current_player.name}, your selected Pawn can capture the Pawn that just moved (#{Move.last.end.coords}) via En Passant!
If you do not capture En Passant now, you will not be able to do so later. 
    HEREDOC
  end

  def game_saved_message(file_path)
    "Game saved! You can find it at #{file_path}."
  end

  def no_saved_games_message
    "You have no saved games! Exiting..."
  end
end

# Utility String Methods
class String 
  # Utility Function for shifting a Cell's column string up or down (eg. b->a)
  def shift(increment = 1)
    (self.ord + increment).chr
  end

  def numeric?
    # '0'.ord => 48; '9'.ord => 57
    self.ord.between?(48, 57)
  end
end

# Utility Symbol Methods for Color Symbols (:W/:B)
class Symbol
  def white?
    self == :W
  end

  def opposite
    self.white? ? :B : :W
  end

  # Convert :W/:B to 'White'/'Black'
  def to_string
    self.white? ? 'White' : 'Black'
  end
end
