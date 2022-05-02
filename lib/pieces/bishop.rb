# frozen_string_literal: true

require './lib/pieces/piece'

# Bishop Class
class Bishop < Piece
  MOVEMENT = {
    infinite: true,
    top_right: { column: 1, row: 1 },
    bot_right: { column: 1, row: -1 },
    bot_left:  { column: -1, row: -1 },
    top_left:  { column: -1, row: 1 }
  }.freeze
end
