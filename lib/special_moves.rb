# frozen_string_literal: true

# Namespace for Methods concerning Pawn Promotion
module PawnPromotion
  def promotion_possible?(last_move)
    return false unless last_move.piece.is_a?(Pawn)

    minmax_rows = @rows.minmax.flatten.filter(&Integer.method(:===))
    end_row = last_move.piece.color.white? ? minmax_rows.max : minmax_rows.min
    last_move.end.row == end_row
  end
end




















module SpecialMoves
  include PawnPromotion
end

