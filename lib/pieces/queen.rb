# frozen_string_literal: true
require './lib/pieces/piece'

class Queen < Piece
  MOVEMENT = {
    infinite: true,
    top:        { column: 0, row: 1 },
    top_right:  { column: 1, row: 1 },
    right:      { column: 1, row: 0 },
    bot_right:  { column: 1, row: -1 },
    bot:        { column: 0, row: -1 },
    bot_left:   { column: -1, row: -1 },
    left:       { column: -1, row: 0 },
    top_left:   { column: -1, row: 1 }
  }
end