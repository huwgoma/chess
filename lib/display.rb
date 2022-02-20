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
      string = set_string(cell.piece)
      background = set_background(cell)
      
    end
  end

  def set_print_order
    Hash[@rows.to_a.reverse].values.flatten
  end

  def set_string(piece)
    case piece.class.to_s
    when 'Pawn'
      piece.color == :W ? '♙' : '♟'
    when 'Rook'
      piece.color == :W ? '♖' : '♜'
    when 'Knight'
      piece.color == :W ? '♘' : '♞'
    when 'Bishop'
      piece.color == :W ? '♗' : '♝'
    when 'Queen'
      piece.color == :W ? '♕' : '♛'
    when 'King'
      piece.color == :W ? '♔' : '♚'
    else
      # piece.cell is in @active_piece's legal moves AND piece is nil? #=> ●
      ''
    end
  end

  def set_background(cell)

    # Default Backgrounds 
    # Even cells - Black (100); Odd cells - White (47)
    (cell.row + cell.column.ord).even? ? 100 : 47
  end
end