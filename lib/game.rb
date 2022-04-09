# frozen_string_literal: true
require './lib/game_text.rb'

class Game
  include GameTextable

  def initialize(board = Board.new, current_color = :W)
    @board = board
    @current_color = current_color
  end

  def play_game
    create_players
    set_current_player(@current_color)
    @board.prepare_board
    @board.print_board
    binding.pry
    game_loop
    # game end
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
      select_active_piece
      # piece_selected? => true (or...) active_piece => @board.active_piece
      @board.print_board(true)
      end_cell = select_active_move
      @board.move_piece(end_cell)
      @board.print_board(false)

      enemy_color = @current_color == :W ? :B : :W
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
    input = verify_piece_input(gets.chomp)
    if input.is_a?(InputWarning)
      puts input.to_s
      select_active_piece
    else
      piece = @board.find_cell(input).piece
      @board.set_active_piece(piece)
    end
  end

  def verify_piece_input(input)
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
      @board.find_cell(input)
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
end