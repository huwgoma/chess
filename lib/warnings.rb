# frozen_string_literal: true

# Parent InputWarning Class - Abstract; Child Classes will override #to_s to return their unique Warning messages
class InputWarning
  include GamePrompts
  def to_s; end
end

# Invalid Input Format - When the input is not alphanumeric 2-digit
class InvalidInputFormat < InputWarning
  def to_s
    invalid_input_format_message
  end
end

# Invalid Input Cell - When the input's Cell is invalid (Cell does not exist or does not have an ally piece)
class InvalidInputCell < InputWarning
  def initialize(current_color)
    @current_color = current_color.to_string
  end

  def to_s
    invalid_input_cell_message(@current_color)
  end
end

# Invalid Input Piece - When the input's cell's piece does not have any legal moves
class InvalidInputPiece < InputWarning
  def to_s
    invalid_input_piece_message
  end
end

# Invalid Input Move - When the input's cell is not within the selected piece's moves
class InvalidInputMove < InputWarning
  def to_s
    invalid_input_move_message
  end
end

# Invalid Promotion Input - When the inputted letter does not correspond to a valid promotion type (pawn promotion)
class InvalidPromotionInput < InputWarning
  def to_s
    invalid_promotion_message
  end
end
