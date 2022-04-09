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
