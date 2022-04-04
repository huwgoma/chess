# frozen_string_literal: true
require './lib/game_text.rb'

class Game
  def initialize(board = Board.new, current_color = :W)
    @board = board
    @current_color = current_color
  end

  def play_game
    create_players
    set_current_player(@current_color)

    @board.prepare_board
    @board.print_board
    
    game_loop
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

  def set_current_player(color)
    @current_player = Player.find(color)
  end

  def select_color(player)
    puts "#{player}, would you like to play as [B] Black or [W] White?"
    input = gets.chomp.upcase

    return input.to_sym if ['B', 'W'].include?(input)

    puts 'Please enter [B] for Black or [W] for White!'
    select_color(player)
  end

  ## Core Game Loop
  def game_loop
    # select_active_piece
    # pawn = @board.find_cell('e2').piece
    knight = @board.find_cell('b1').piece
    moves = @board.generate_moves(knight)

    @board.verify_moves(knight)
  end

  def select_active_piece

  end

  def verify_piece_input(input)

  end
  
  def input_format_valid?(input)
    input.length == 2 && input.chars[1].numeric?
  end
end

