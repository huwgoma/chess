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