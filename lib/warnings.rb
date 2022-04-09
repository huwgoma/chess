# frozen_string_literal: true

class InputWarning
  include GameTextable
  def to_s; end
end

class InvalidInputFormat < InputWarning
  def to_s
    invalid_input_format_message
  end
end

class InvalidInputCell < InputWarning
  def initialize(current_color)
    @current_color = current_color == :W ? 'White' : 'Black'
  end

  def to_s
    invalid_input_cell_message(@current_color)
  end
end

class InvalidInputPiece < InputWarning
  def to_s
    invalid_input_piece_message
  end
end

class InvalidInputMove < InputWarning
  def to_s
    invalid_input_move_message
  end
end