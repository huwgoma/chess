# frozen_string_literal: true
require './lib/pieces/piece'
require './lib/display'


class String 
  # Utility Function for shifting a Cell's column string up or down (eg. b->a)
  def shift(increment = 1)
    (self.ord + increment).chr
  end
end

class Board
  include Displayable

  attr_reader :columns, :rows, :active_piece, :cells

  def initialize
    @cells = []
  end

  # Create Cells, set columns/rows for easier access, place Pieces on cells
  def prepare_board
    initialize_cells
    @columns = sort_cells(:column)
    @rows = sort_cells(:row)
    place_pieces(Piece::INITIAL_PIECES)
  end

  # Create the 64 Cells of the Board
  def initialize_cells(x = 8, y = 8)
    x.times do | x |
      column = (x + 97).chr
      y.times do | y |
        row = (y + 1)
        @cells << Cell.new(column, row)
      end
    end
  end

  # Sort the Cells into their columns and rows
  def sort_cells(axis_type)
    @cells.reduce({}) do | hash, cell |
      # eg. axis_type: column; axis: a
      axis = cell.send(axis_type)
#      binding.pry
      hash.has_key?(axis) ? hash[axis] << cell : hash[axis] = [cell]
      hash
    end
  end

  # Place the 32 Pieces on their initial positions
  def place_pieces(pieces)
    pieces.each do | coords, piece |
      cell = find_cell(coords)
      piece_factory = Piece.select_factory(piece[:type])
      piece_factory.place_piece(piece[:color], cell)
    end
  end

  # Utility function for finding any cell on the board given a set of coordinates
  def find_cell(coords)
    column, row = coords.split('')
    column_cells = @columns[column]
    row_cells = @rows[row.to_i]
    
    # If both column and row cells exist 
    [column_cells, row_cells].all? ? (column_cells & row_cells)[0] : nil
  end

  def generate_moves(piece)
    movement = piece.class::MOVEMENT
    
    piece.moves.each do | dir, cells |
      cells.clear
      
      1.times do | i |
        column = piece.position.column.shift(1 * movement[dir][:column])
        row = piece.position.row + (1 * movement[dir][:row])
        #binding.pry
        cell = find_cell(column + row.to_s)
        

        cells << cell
      end
      
    end
    
  end

  
end