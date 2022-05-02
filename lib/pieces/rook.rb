# frozen_string_literal: true

require './lib/pieces/piece'

# Rook Class
class Rook < Piece
  attr_reader :moved

  MOVEMENT = {
    infinite: true,
    top:    { column: 0, row: 1 },
    right:  { column: 1, row: 0 },
    bot:    { column: 0, row: -1 },
    left:   { column: -1, row: 0 }
  }.freeze

  def initialize(color, cell)
    super
    @moved = false
  end

  def update_position(cell)
    super
    @moved = true
  end
end
