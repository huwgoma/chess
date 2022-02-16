# frozen_string_literal: true
require './lib/pieces/piece'
require 'pry'
class PieceFactory
  # Factory Method
  def create_piece; end

  # Create and place a Piece
  def place_piece(color, cell)
    piece = create_piece(color, cell)
    
    piece.update_position(cell)
    cell.update_piece(piece)
  end
end

class PawnFactory < PieceFactory
  def create_piece(color, cell)

  end
end

class RookFactory < PieceFactory
  def create_piece(color, cell)
    Rook.new(color, cell)
  end
end