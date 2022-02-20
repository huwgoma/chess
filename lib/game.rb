# frozen_string_literal: true

class Game
  def initialize(board = Board.new, current_turn = :W)
    @board = board
    @current_turn = current_turn
  end

  def play_game
    create_players
    @board.setup_board
    @board.print_board
    # binding.pry
    # game_loop
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

  def select_color(player)
    puts "#{player}, would you like to play as [B] Black or [W] White?"
    input = gets.chomp.upcase

    return input.to_sym if ['B', 'W'].include?(input)

    puts 'Please enter [B] for Black or [W] for White!'
    select_color(player)
  end
end

