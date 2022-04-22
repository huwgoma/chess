# frozen_string_literal: true
require './lib/game_text.rb'
require './lib/special_moves'

class Game
  include GameTextable
  include SpecialMoves

  def initialize(board = Board.new, current_color = :W)
    @board = board
    @current_color = current_color
    @resigned = false
  end

  def play
    create_players
    set_current_player(@current_color)
    @board.prepare_board
    @board.print_board
    game_loop
    game_end
  end

  ## Game Setup
  def create_players
    2.times do | player_count |
      puts "Player #{player_count+1}, please enter your name."
      name = gets.chomp
      color = player_count.zero? ? select_color(name) : Player.list[0].white? ? :B : :W
      Player.new(name, color)
    end
  end

  def set_current_player(color = @current_color)
    @current_player = Player.find(color)
  end

  def select_color(player)
    puts "#{player}, would you like to play as [B] Black or [W] White?"
    input = gets.chomp.upcase
    return input.to_sym if ['B', 'W'].include?(input)
    puts 'Please enter [B] for Black or [W] for White!'
    select_color(player)
  end

  def switch_current_color(next_color)
    @current_color = next_color
  end

  ## Core Game Loop
  def game_loop
    loop do
      
      piece = select_active_piece
      # Return out of game_loop early if piece is a Symbol ('Q' entered)
      return send(piece) if piece.is_a?(Symbol)

      # piece_selected? => true
      @board.print_board(piece_selected: true)
      dir_cell = select_active_move
      move = @board.move_piece(end_cell: dir_cell[:cell], dir: dir_cell[:dir])
      
      # Pawn Promotion 
      if promotion_possible?(move)
        puts pawn_promotion_message
        promote_pawn(move) 
      end

      @board.print_board

      enemy_color = @current_color.opposite
      if @board.king_in_check?(enemy_color)
        @board.king_in_checkmate?(enemy_color) ? break : puts(king_check_warning(enemy_color))
      end

      switch_current_color(enemy_color)
      set_current_player(enemy_color)
    end
  end

  # Select the Active Piece (Piece to be Moved)
  def select_active_piece
    puts "#{@current_player.name}, please enter the coordinates of the piece you want to move:"
    puts "Enter [Q] to quit if you wish to resign."
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

  def verify_piece_input(input)
    # Quit
    return :resign if input.upcase == 'Q'

    return InvalidInputFormat.new unless input_format_valid?(input)
    return InvalidInputCell.new(@current_color) unless input_cell_valid?(input)
    return InvalidInputPiece.new unless input_piece_valid?(input)
    input
  end
  
  def input_format_valid?(input)
    input.length == 2 && input.chars[1].numeric?
  end

  def input_cell_valid?(input)
    input_cell = @board.find_cell(input)
    input_cell&.has_ally?(@current_color) == true
  end

  def input_piece_valid?(input)
    input_piece = @board.find_cell(input).piece
    @board.generate_legal_moves(input_piece)
    input_piece.has_moves?
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

  def verify_move_input(input)
    return InvalidInputFormat.new unless input_format_valid?(input)
    return InvalidInputMove.new unless input_move_valid?(input)
    input
  end

  def input_move_valid?(input)
    input_cell = @board.find_cell(input)
    @board.active_piece.moves.values.flatten.include?(input_cell)
  end

  # Resign
  def resign
    @resigned = true
  end

  # End of Game
  def game_end
    puts @resigned ? resigned_message : king_checkmate_message(@current_color.opposite) 
    puts replay_game_message
  end

  def play_again?
    loop do
      input = gets.chomp
      unless ['P', 'Q'].include?(input.upcase)
        puts invalid_replay_input_warning
        next
      end
      break input.upcase == 'P'
    end
  end
end