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
    # 2-Space Leap is allowed 
    @initial_position = cell
    @initial = true
  end

  def update_position(cell)
    super
    # If the Pawn is being moved (back) to its @initial_position, set @initial to true; 
    # otherwise, @initial = false
    @initial = cell == @initial_position
  end
end