# frozen_string_literal: true

class Move
  @@stack = []

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

  # Revert the changes made to Cell/Piece states by the move
  def undo

  end
end