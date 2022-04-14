# frozen_string_literal: true

class Move
  @@stack = []

  attr_reader :start, :end, :piece, :killed

  def initialize(end_cell, start_cell, piece, killed)
    @end = end_cell
    @start = start_cell
    @piece = piece
    @killed = killed
    @@stack << self
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
    @end.update_piece(@killed)
    # If there was a Killed Piece, place it back on @end Cell
    @killed.update_position(@end) if @killed
  end
end