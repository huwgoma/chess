# frozen_string_literal: true
require './lib/pieces/piece'

class Pawn < Piece
  MOVEMENT = {
    infinite: false,
    forward:       { column: 0, row: 1 },
    initial:       { column: 0, row: 2 },
    forward_left:  { column: -1, row: 1 },
    forward_right: { column: 1, row: 1 }
  }
end