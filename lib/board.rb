# frozen_string_literal: true

require './lib/display'
require './lib/move_generator'
require './lib/special_moves'

# Board Class - Represents the Chess Board
class Board
  include Displayable
  include MoveGenerator
  include SpecialMoves

  attr_reader :columns, :rows, :active_piece, :cells, :living_pieces

  def initialize
    @cells = []
    @active_piece = nil
    @living_pieces = { W: [], B: [] }
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
    x.times do |x|
      column = (x + 97).chr
      y.times do |y|
        row = (y + 1)
        @cells << Cell.new(column, row)
      end
    end
  end

  # Sort the Cells into their columns and rows
  def sort_cells(axis_type)
    @cells.each_with_object({}) do |cell, hash|
      # eg. axis_type: column; axis: a
      axis = cell.send(axis_type)
      hash.key?(axis) ? hash[axis] << cell : hash[axis] = [cell]
    end
  end

  # Place the 32 Pieces on their initial positions, add Pieces to @living_pieces
  def place_pieces(pieces)
    pieces.each do |coords, piece|
      cell = find_cell(coords)
      piece_factory = Piece.select_factory(piece[:type])
      piece = piece_factory.place_piece(piece[:color], cell)
      @living_pieces[piece.color] << piece
    end
  end

  # Utility function for finding any cell on the board given a set of coordinates
  def find_cell(coords)
    @cells.find { |cell| cell.coords == coords }
  end

  # Update @active_piece to the given Piece
  def set_active_piece(piece)
    @active_piece = piece
  end

  # King in Check? - Check if the given color's King is in danger (Check)
  def king_in_check?(king_color)
    king_cell = find_king_cell(king_color)
    enemy_color = king_color.opposite
    # Does ANY living enemy Piece...
    @living_pieces[enemy_color].any? do |enemy_piece|
      # Have ANY move...
      enemy_moves = generate_moves(enemy_piece)
      enemy_moves.values.flatten.any? do |enemy_move|
        # That lands on the same Cell as the King Cell?
        enemy_move == king_cell
      end
    end
  end

  # King in Checkmate? - Check if the given color's King is in Checkmate
  # True if none of the [color]'s Pieces have any legal moves
  def king_in_checkmate?(king_color)
    @living_pieces[king_color].none? do |piece|
      moves = generate_legal_moves(piece)
      moves.values.flatten.any?
    end
  end

  # Given a Color, find and return that color's King's cell
  def find_king_cell(king_color)
    @living_pieces[king_color].find { |piece| piece.is_a?(King) }.position
  end

  # Given Piece, Start, and End, move the Piece from Start to End
  # and create a Move object
  def move_piece(piece: @active_piece, start_cell: @active_piece.position, end_cell:, dir:)
    start_cell.update_piece(nil)
    piece.update_position(end_cell)

    kill = dir.match?(/en_passant/) ? find_en_passant_kill(end_cell, piece) : end_cell.piece
    kill_piece(kill) if kill

    end_cell.update_piece(piece)

    if dir.match?(/castle/)
      case piece
      when King
        castle_move = move_castling_rook(piece, dir)
        Move.new(piece: piece, start_cell: start_cell, end_cell: end_cell, dir: dir, rook_move: castle_move)
      when Rook
        Move.new(piece: piece, start_cell: start_cell, end_cell: end_cell, dir: dir, secondary: true)
      end
    else
      Move.new(piece: piece, start_cell: start_cell, end_cell: end_cell, dir: dir, kill: kill)
    end
  end

  # Kill the given Piece, remove it from its Cell, and remove it from @living_pieces
  def kill_piece(piece)
    piece.is_killed
    piece.position.update_piece(nil)
    @living_pieces[piece.color].delete(piece)
  end

  # Undo the last Move - Revert Cell/Piece @piece/@position changes
  # Also revive the killed Piece if any and re-add it to @living_pieces
  def undo_last_move
    last_move = Move.pop
    last_move.undo
    revive_piece(last_move.kill) if last_move.kill
  end

  # Revive the given Piece and add it back to @living_pieces
  def revive_piece(piece)
    piece.is_revived
    @living_pieces[piece.color] << piece
  end
end
