# frozen_string_literal: true

class Move
  def initialize(start_cell, end_cell, piece, killed_piece)
    @start = start_cell
    @end = end_cell
    @piece = piece
    @killed = killed_piece
  end
end