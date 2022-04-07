# frozen_string_literal: true

class Move
  @@stack = []

  attr_reader :killed, :start, :end

  def initialize(start_cell, end_cell, piece, killed_piece)
    @start = start_cell
    @end = end_cell
    @piece = piece
    @killed = killed_piece
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