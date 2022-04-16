# frozen_string_literal: true
require './lib/pieces/piece'

class Rook < Piece
  MOVEMENT = { 
    infinite: true,
    top:    { column: 0, row: 1 },
    right:  { column: 1, row: 0 },
    bot:    { column: 0, row: -1 },
    left:   { column: -1, row: 0 }
  }

  def initialize(color, cell)
    super
    @moved = false
  end

  def update_position(cell)
    super
    @moved = true
  end
end