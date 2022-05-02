# frozen_string_literal: true

require './lib/pieces/piece'

# Knight Class
class Knight < Piece
  MOVEMENT = {
    infinite: false,
    top_right: { column: 1, row: 2 },
    right_top: { column: 2, row: 1 },
    right_bot: { column: 2, row: -1 },
    bot_right: { column: 1, row: -2 },
    bot_left:  { column: -1, row: -2 },
    left_bot:  { column: -2, row: -1 },
    left_top:  { column: -2, row: 1 },
    top_left:  { column: -1, row: 2 }
  }.freeze
end
