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

  # Merge Generate + Prune Moves
  def generate_moves(piece)

  end

  # Given a Piece's possible end Cell, decide whether to keep it or not
  def keep_piece_move?(cell, piece)
    cell.empty? || cell.has_enemy?(piece.color)
  end

  # Given a Pawn's possible end Cell, decide whether to keep it or not
  def keep_pawn_move?(cell, direction, pawn)
    case direction
    when :forward
      cell.empty?
    end
  end


  # Generate all possible cells that a given Piece can move to 
  # Isolated; does not take other pieces into account
  # def generate_moves(piece)
  #   movement = piece.class::MOVEMENT
    
  #   piece.moves.each do | dir, cells |
  #     cells.clear
  #     # If piece is Pawn, forward = +/- 1 (W/B); otherwise, it's just 1
  #     forward = piece.is_a?(Pawn) ? piece.forward : 1

  #     (1).upto(movement[:infinite] ? 7 : 1) do | i |
  #       column = piece.position.column.shift(i * movement[dir][:column])
  #       row = piece.position.row + (i * movement[dir][:row] * forward)
  #       cell = find_cell(column + row.to_s)
        
  #       break if cell.nil?
  #       cells << cell
  #     end
  #     piece.moves.delete(dir) if cells.empty?
  #   end
  # end

  # # Given a Hash of moves, prune the moves based on the position of other Pieces;
  # # Remove moves if they are blocked by the presence of other Pieces
  # def prune_moves(piece, moves)
  #   moves.each do | dir, cells |
  #     cells.keep_if.with_index do | cell, index |
  #       # If cell has no piece, keep the cell
  #       next true if cell.piece.nil?
  #       # Otherwise, remove all cells AFTER the current one, then decide 
  #       # whether to keep the current cell or not
  #       cells.pop(cells.length-1 - index)
  #       # Cell has enemy => Keep cell (true); Cell has ally => Discard cell(false)
        
  #       cell.has_enemy?(piece.color)
  #     end
  #   end
  # end
end