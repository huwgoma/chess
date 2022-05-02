# frozen_string_literal: true

require './lib/game_prompts'
require './lib/special_moves'
require './lib/serializable'

# Game Class - Represents/oversees individual Chess Games
class Game
  include GamePrompts
  include SpecialMoves
  include Serializable

  def initialize(board = Board.new)
    @board = board
    @current_color = :W
    @resigned = false
  end

  def play(new_game: true)
    new_game ? prepare_new_game : load_game_environment

    set_current_player(@current_color)
    @board.print_board
    game_loop
    game_end
  end

  ## Game Setup
  def prepare_new_game
    create_players
    @players = Player.list
    @moves = Move.stack
    @board.prepare_board
  end

  # In the event of a loaded game being played, point Move.stack and Player.list
  # to the game's @moves/@players
  def load_game_environment
    Move.load_stack(@moves)
    Player.load_list(@players)
  end

  def create_players
    2.times do |player_count|
      puts "Player #{player_count + 1}, please enter your name."
      name = gets.chomp
      color = player_count.zero? ? select_color(name) : Player.list[0].white? ? :B : :W
      Player.new(name, color)
    end
  end

  def set_current_player(color = @current_color)
    @current_player = Player.find(color)
  end

  def switch_current_color(next_color)
    @current_color = next_color
  end

  ## Core Game Loop
  def game_loop
    loop do
      piece = select_active_piece
      # Return out of game_loop early if piece is a Symbol ('Q' or 'S' entered)
      return send(piece) if piece.is_a?(Symbol)

      @board.print_board(piece_selected: true)

      # En Passant Prompt
      puts en_passant_message if en_passant_available?(piece)

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

  def verify_piece_input(input)
    # Quit
    return :resign if input.upcase == 'Q'
    return :save_game if input.upcase == 'S'

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
    # If input cell is nil, return nil => nil == true ? => false
    input_cell&.has_ally?(@current_color) == true
  end

  def input_piece_valid?(input)
    input_piece = @board.find_cell(input).piece
    @board.generate_legal_moves(input_piece)
    input_piece.has_moves?
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
end
