# frozen_string_literal: true

require './lib/pieces/piece'

# King Class
class King < Piece
  attr_reader :moved

  MOVEMENT = {
    infinite: false,
    top:          { column: 0, row: 1 },
    top_right:    { column: 1, row: 1 },
    right:        { column: 1, row: 0 },
    bot_right:    { column: 1, row: -1 },
    bot:          { column: 0, row: -1 },
    bot_left:     { column: -1, row: -1 },
    left:         { column: -1, row: 0 },
    top_left:     { column: -1, row: 1 },
    castle_king:  { column: 2, row: 0 },
    castle_queen: { column: -2, row: 0 }
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
