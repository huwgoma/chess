# frozen_string_literal: true

class Board
  def initialize
    @columns = { }
    @rows = { }
    #initialize_pieces
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

  def set_columns(x = 8, y = 8)
    
    
  end

  def set_rows

  end
end