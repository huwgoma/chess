# frozen_string_literal: true

class Move
  @@stack = []

  attr_reader :start, :end, :piece, :kill, :dir, :rook_move

  def initialize(piece:, start_cell:, end_cell:, dir:, kill: nil, **castle)
    @piece = piece
    @start = start_cell
    @end = end_cell
    @dir = dir
    @kill = kill
    
    @rook_move = castle[:rook_move] if castle[:rook_move]

    @@stack << self unless castle[:secondary]
  end

  def self.stack
    @@stack
  end

  def self.pop
    @@stack.pop
  end

  def self.last
    @@stack[@@stack.length - 1]
  end

  # Revert the changes made to Cell/Piece states by the move
  def undo
    # Move Piece back to Start Cell
    @piece.update_position(@start)
    @start.update_piece(@piece)
    
    # Vacate End Cell
    @end.update_piece(nil)

    # If there was a kill, place that Piece back on its Cell
    @kill.position.update_piece(@kill) if kill
    
    # If the Move has a secondary @rook_move (ie. Castling), undo that as well
    @rook_move.undo if @rook_move
  end
end