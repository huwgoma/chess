# frozen_string_literal: true

class Cell
  attr_reader :column, :row, :piece

  @@list = []

  def initialize(column, row)
    @column = column
    @row = row
    @piece = nil
    @@list << self
  end

  def self.list
    @@list
  end

  def self.clear_list
    @@list = []
  end

  def self.sort_cells(cell_axis)
    return unless [:@column, :@row].include?(cell_axis)
    @@list.reduce(Hash.new) do | cell_hash, cell |
      axis = cell.instance_variable_get(cell_axis)
      cell_hash.has_key?(axis) ? cell_hash[axis] << cell : cell_hash[axis] = [cell]
      cell_hash
    end
  end

  def update_piece(piece)
    @piece = piece
  end
end