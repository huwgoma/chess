# frozen_string_literal: true
require 'pry'

class String
  # Default Black BG
  def bg_black; "\u001b[100;1m#{self}\u001b[0m" end

  # Default White BG
  def bg_white; "\u001b[47;1m#{self}\u001b[0m" end

  # Possible Piece Capture BG
  def bg_red; "\u001b[41;1m#{self}\u001b[0m" end

  # Selected Piece BG
  def bg_cyan; "\u001b[46;1m#{self}\u001b[0m" end

  # Previous Move Piece BG
  def bg_blue; "\u001b[44;1m#{self}\u001b[0m" end
end

module Displayable
  def print_board
    print_order = set_print_order
    
    print_order.each do | cell |
      #binding.pry
      string = set_string(cell.piece)
      # background = set_background(cell)
      
    end
  end

  def set_print_order
    Hash[@rows.to_a.reverse].values.flatten
  end

  def set_string(piece)
    #binding.pry
    # is piece a Pawn (Pawn === piece)
    case piece.class.to_s
    when 'Pawn'
      piece.color == :W ? '♙' : '♟'
    end
  end

  def set_background(cell)

  end
end