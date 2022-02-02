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
  include GameTextable
  
  def initialize
    puts tutorial_message
    puts game_mode_message
  end

  def create_players
  end

  def select_color(player)
    puts "#{player}, would you like to play as [B] Black or [W] White?"
    input = gets.chomp.upcase
    return input if ['B', 'W'].include?(input)
    
    puts 'Please enter [B] for Black or [W] for White!'
    select_color(player)
  end
end