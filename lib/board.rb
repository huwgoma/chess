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

  attr_reader :columns, :rows, :active_piece, :cells, :living_pieces

  def initialize
    @cells = []
    @active_piece = nil
  end

  # Create Cells, set columns/rows for easier access, place Pieces on cells
  def prepare_board
    initialize_cells
    @columns = sort_cells(:column)
    @rows = sort_cells(:row)
    place_pieces(Piece::INITIAL_PIECES)
    @living_pieces = set_living_pieces
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

  # Iterate through @rows and create a Hash of Pieces that are alive (sorted by color)
  def set_living_pieces
    @rows.values.flatten.reduce({}) do | hash, cell |
      next hash if cell.empty?
      color = cell.piece.color
      hash.has_key?(color) ? hash[color] << cell.piece : hash[color] = [cell.piece]
      hash
    end
  end


  # Generate Moves - Given a Piece, generate its possible moves
  # - Does not account for the King's safety
  def generate_moves(piece)
    movement = piece.class::MOVEMENT
    piece.moves.each do | dir, cells |
      cells.clear
      forward = piece.is_a?(Pawn) ? piece.forward : 1

      (1).upto(movement[:infinite] ? 7 : 1) do | i |
        column = piece.position.column.shift(i * movement[dir][:column])
        row = piece.position.row + (i * movement[dir][:row] * forward)
        cell = find_cell(column + row.to_s)
        break if cell.nil?

        keep_cell = piece.is_a?(Pawn) ? keep_pawn_move?(cell, dir, piece) : keep_piece_move?(cell, piece)
        
        cells << cell if keep_cell
        break unless cell.empty?
      end
      piece.moves.delete(dir) if cells.empty?
    end
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
    when :initial
      forward_cell = find_cell(cell.column + (cell.row - pawn.forward).to_s)
      pawn.initial && forward_cell.empty? && cell.empty?
    when :forward_left, :forward_right
      cell.has_enemy?(pawn.color)
    end
  end

  # Verify Moves - Given a Piece, verify its @moves Hash by checking whether 
  # each move can be made without putting the allied King into check
  def verify_moves(piece)
    binding.pry
  end

  # Given a Piece, a Start Cell, and an End Cell, move the Piece from Start to End
  def move_piece(piece = @active_piece, start_cell, end_cell)
    start_cell.update_piece(nil)
    piece.update_position(end_cell)
    kill = end_cell.has_enemy?(piece.color) ? kill_piece(end_cell.piece) : nil
    end_cell.update_piece(piece)
    Move.new(start_cell, end_cell, piece, kill)
  end

  # Kill the given Piece and remove it from @living_pieces
  def kill_piece(piece)
    piece.is_killed
    @living_pieces[piece.color].delete(piece)
  end

  # Undo the last Move - Revert Cell/Piece @piece/@position changes
  # Also revive the killed Piece if any and re-add it to @living_pieces
  def undo_last_move
    last_move = Move.pop
    last_move.undo
    revive_piece(last_move.killed) if last_move.killed
  end
  
  # Revive the given Piece and add it back to @living_pieces
  def revive_piece(piece)
    piece.is_revived
    @living_pieces[piece.color] << piece
  end
end