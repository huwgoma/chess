# frozen_string_literal: true

module GameTextable
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
end

class Game
  def initialize(board = Board.new, current_turn = :W)
    @board = board
    @current_turn = current_turn
  end

  def play_game
    create_players
    @board.setup_board
    initialize_pieces
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

  def initialize_pieces(pieces)

  end

end