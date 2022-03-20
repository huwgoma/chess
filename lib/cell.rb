# frozen_string_literal: true

class Cell
  attr_reader :column, :row, :piece

  def initialize(column, row, piece = nil)
    @column = column
    @row = row
    @piece = piece
  end

  def update_piece(piece)
    @piece = piece
  end

  def empty?
    @piece.nil?
  end

  # Does this cell have an enemy piece?
  def has_enemy?(foreign_color)
    return false if empty?
    @piece.color != foreign_color
  end

  def has_ally?(foreign_color)
    return false if empty?
    @piece.color == foreign_color
  end
end