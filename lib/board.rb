# frozen_string_literal: true
require './lib/pieces/piece'
require './lib/display'

class Board
  include Displayable

  attr_reader :columns, :rows, :active_piece

  def setup_board
    initialize_cells
    set_columns_rows
    place_pieces(Piece::INITIAL_PIECES)
    @active_piece = nil
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

  def set_columns_rows
    @columns = Cell.sort_cells(:@column)
    @rows = Cell.sort_cells(:@row)
  end

  def place_pieces(pieces)
    pieces.each do | coords, piece |
      cell = find_cell(coords)
      piece_factory = Piece.select_factory(piece[:type])
      piece_factory.place_piece(piece[:color], cell)
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