# frozen_string_literal: true

class Board
  def initialize
    @columns = { }
    @rows = { }
    initialize_cells
  end

  def initialize_cells(x = 8, y = 8)
    x.times do | x |
      column = (x + 97).chr
      y.times do | y |
        row = (y + 1)
        Cell.new(column, row)
      end
    end
  end
end