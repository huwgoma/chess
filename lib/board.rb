# frozen_string_literal: true

class Board
  attr_reader :columns, :rows

  def initialize
    @columns = { }
    @rows = { }
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

  #move to Cell?
  def set_columns_rows
    Cell.list.each do | cell |
      column = cell.column
      row = cell.row
      
      @columns.has_key?(column) ? @columns[column] << cell : @columns[column] = [cell]
      @rows.has_key?(row) ? @rows[row] << cell : @rows[row] = [cell]
    end
  end

  def find_cell(coords)
    column, row = coords.split('')
    column_cells = @columns[column]
    row_cells = @rows[row.to_i]
    
    # If both column and row cells exist 
    [column_cells, row_cells].all? ? (column_cells & row_cells)[0] : nil
  end
end