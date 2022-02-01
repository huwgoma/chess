# frozen_string_literal: true

module GameText
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
  include GameText
  
  def initialize
    puts tutorial_message
    puts game_mode_message
  end
end