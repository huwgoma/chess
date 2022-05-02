# frozen_string_literal: true

require './lib/pieces/piece'

# Creator Class
class PieceFactory
  # Factory Method
  def create_piece; end

  # Create and place a Piece
  def place_piece(color, cell)
    piece = create_piece(color, cell)

    cell.update_piece(piece)
  end
end

# Creator Subclasses
# Create and return a new Pawn
class PawnFactory < PieceFactory
  def create_piece(color, cell)
    Pawn.new(color, cell)
  end
end

# Create and return a new Rook
class RookFactory < PieceFactory
  def create_piece(color, cell)
    Rook.new(color, cell)
  end
end

# Create and return a new Knight
class KnightFactory < PieceFactory
  def create_piece(color, cell)
    Knight.new(color, cell)
  end
end

# Create and return a new Bishop
class BishopFactory < PieceFactory
  def create_piece(color, cell)
    Bishop.new(color, cell)
  end
end

# Create and return a new Queen
class QueenFactory < PieceFactory
  def create_piece(color, cell)
    Queen.new(color, cell)
  end
end

# Create and return a new King
class KingFactory < PieceFactory
  def create_piece(color, cell)
    King.new(color, cell)
  end
end
