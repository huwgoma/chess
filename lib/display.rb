# frozen_string_literal: true

require './lib/move'

# Displayable Module - Contains methods related to displaying the Chess Board
module Displayable
  def print_board(piece_selected: false)
    # Clear the terminal every time the board is printed
    system 'clear'

    print_order = set_print_order

    print_order.each_with_index do |cell, index|
      print "\n\t #{cell.row} " if (index % 8).zero?
      string = set_string(cell, piece_selected)
      bg = set_bg(cell, piece_selected)
      print "\u001b[#{bg};1m #{string} \u001b[0m"
    end

    print "\n\t   "
    (' a '..' h ').each(&method(:print))
    print "\n\n"
  end

  def set_print_order
    Hash[@rows.to_a.reverse].values.flatten
  end

  def set_string(cell, piece_selected)
    piece = cell.piece

    case piece
    when Pawn
      piece.color == :W ? '♟' : '♙'
    when Rook
      piece.color == :W ? '♜' : '♖'
    when Knight
      piece.color == :W ? '♞' : '♘'
    when Bishop
      piece.color == :W ? '♝' : '♗'
    when Queen
      piece.color == :W ? '♛' : '♕'
    when King
      piece.color == :W ? '♚' : '♔'
    else # Piece is nil
      if piece_selected && @active_piece.moves.values.flatten.include?(cell)
        '●'
      else
        ' '
      end
    end
  end

  def set_bg(cell, piece_selected, last_cell = Move.last&.end)
    # Selected Piece Cell
    if piece_selected && cell == @active_piece.position
      46 # Cyan
    # Potential Capture Cell
    elsif piece_selected && @active_piece.moves.values.flatten.include?(cell) && cell.piece
      41 # Red
    # Previous Move Cell
    elsif cell == last_cell
      44 # Blue
    else
      # Black or White
      (cell.row + cell.column.ord).even? ? 40 : 100
    end
  end
end
