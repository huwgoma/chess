# frozen_string_literal: true

class Cell
  attr_reader :column, :row, :piece

  def initialize(column, row)
    @column = column
    @row = row
    @piece = nil
  end

  def update_piece(piece)
    @piece = piece
  end
end