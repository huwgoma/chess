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

  # Does this cell have an enemy piece?
  def has_enemy?(foreign_color)
    return false if @piece.nil?
    @piece.color != foreign_color
  end

  def has_ally?(foreign_color)
    return false if @piece.nil?
    @piece.color == foreign_color
  end
end