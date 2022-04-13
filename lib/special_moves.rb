# frozen_string_literal: true

module PawnPromotion
  def some_method
    puts 'hi'
  end
end

module SpecialMoves
  include PawnPromotion
end

