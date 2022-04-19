# frozen_string_literal: true

class Move
  @@stack = []

  attr_reader :start, :end, :piece, :kill, :rook_move

  def initialize(piece:, start_cell:, end_cell:, kill: nil, **castle)
    @piece = piece
    @start = start_cell
    @end = end_cell
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
    @piece.update_position(@start)
    @start.update_piece(@piece)
    
    # @killed = nil if no Piece was killed; @killed = Killed piece (if Piece was killed)
    @end.update_piece(@kill)
    # If there was a Killed Piece, place it back on @end Cell
    @kill.update_position(@end) if @kill
  end
end