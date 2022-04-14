# frozen_string_literal: true

# Namespace for Methods concerning Pawn Promotion
module PawnPromotion
  def promotion_possible?
    return false unless @active_piece.is_a?(Pawn)
    
    minmax_rows = @rows.minmax.flatten.filter(&Integer.method(:===))
    end_row = @active_piece.color.white? ? minmax_rows.max : minmax_rows.min
    @active_piece.position.row == end_row
  end
end




















module SpecialMoves
  include PawnPromotion
end

