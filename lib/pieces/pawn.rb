# frozen_string_literal: true
require './lib/pieces/piece'

class Pawn < Piece
  attr_reader :forward, :initial

  MOVEMENT = {
    infinite: false,
    forward:       { column: 0, row: 1 },
    initial:       { column: 0, row: 2 },
    forward_left:  { column: -1, row: 1 },
    forward_right: { column: 1, row: 1 }
  }

  def initialize(color, cell)
    super
    @forward = @color.white? ? 1 : -1 
    # Initial advance is allowed
    @initial = true
  end
end