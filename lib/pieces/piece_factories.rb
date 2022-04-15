# frozen_string_literal: true
require './lib/pieces/piece'
require 'pry'

# Creator Class
class PieceFactory
  # Factory Method
  def create_piece; end

  # Create and place a Piece
  def place_piece(color, cell)
    piece = create_piece(color, cell)
    
    #piece.update_position(cell)
    cell.update_piece(piece)
  end
end

# Creator Subclasses
class PawnFactory < PieceFactory
  def create_piece(color, cell)
    Pawn.new(color, cell)
  end
end

class RookFactory < PieceFactory
  def create_piece(color, cell)
    Rook.new(color, cell)
  end
end

class KnightFactory < PieceFactory
  def create_piece(color, cell)
    Knight.new(color, cell)
  end
end

class BishopFactory < PieceFactory
  def create_piece(color, cell)
    Bishop.new(color, cell)
  end
end

class QueenFactory < PieceFactory
  def create_piece(color, cell)
    Queen.new(color, cell)
  end
end

class KingFactory < PieceFactory
  def create_piece(color, cell)
    King.new(color, cell)
  end
end