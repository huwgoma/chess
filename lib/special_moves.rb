# frozen_string_literal: true

# Namespace for Methods concerning Pawn Promotion
module PawnPromotion
  def promotion_possible?(last_move)
    return false unless last_move.piece.is_a?(Pawn)

    minmax_rows = @rows.minmax.flatten.filter(&Integer.method(:===))
    end_row = last_move.piece.color.white? ? minmax_rows.max : minmax_rows.min
    last_move.end.row == end_row
  end

  PROMOTION_OPTIONS = {
    'Q' => :Queen,
    'R' => :Rook,
    'B' => :Bishop,
    'KN' => :Knight
  }

  def promote_pawn(last_move)
    # type = choose_promotion_type
    #   "[name], your Pawn is being promoted! Select what you want to promote it to"
    #   input = verify_promotion_choice(gets.chomp) (returns InputWarning or input)
    #   case input
    #   when InputWarning 
    #     puts input.to_s; choose_promotion
    #   when String
    #     return PROMOTION_TYPES[input] #=> :Queen
    #   end
    # pawn = last_move.piece
    # coords = last_move.end.column + last_move.end.row.to_s
    # piece_hash = { coords => { color: pawn.color, type: type }}
    # kill_piece(pawn)
    # place_pieces(piece_hash)
  end

  def verify_promotion_input(input)
    input = input.upcase
    return InvalidPromotionInput.new unless promotion_input_valid?(input)
    input
  end

  def promotion_input_valid?(input)
    PROMOTION_OPTIONS.keys.include?(input)
  end
end




















module SpecialMoves
  include PawnPromotion
end

