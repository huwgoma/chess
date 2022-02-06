# frozen_string_literal: true

class Cell

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
end