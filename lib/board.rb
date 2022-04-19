# frozen_string_literal: true

require './lib/display'
require './lib/special_moves'


class Board
  include Displayable
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

  # Place the 32 Pieces on their initial positions, add Pieces to @living_pieces
  def place_pieces(pieces)
    pieces.each do | coords, piece |
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

  # Generate Legal Moves - Generate the given Piece's legal moves
  def generate_legal_moves(piece)
    generate_moves(piece)
    clone_board = Marshal.load(Marshal.dump(self))
    clone_piece = clone_board.find_cell(piece.position.coords).piece
    clone_moves = clone_board.verify_moves(clone_piece)
    # Transfer the clone piece's moves to the real piece's moves
    transfer_clone_moves(piece.moves, clone_moves)
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
        break if cell.piece
      end
    end
  end

  # Verify Moves - Given a Piece, verify its @moves Hash by checking whether 
  # each move can be made without putting the allied King into check
  def verify_moves(piece)
    piece.moves.each do | dir, cells |
      cells.reject! do | cell |
        move_piece(piece: piece, start_cell: piece.position, end_cell: cell, dir: dir)
        reject_cell = king_in_check?(piece.color)
        undo_last_move
        reject_cell
      end
    end
  end

  # Keep each of the real Piece's @moves only if its clone equivalent also
  # includes that move
  def transfer_clone_moves(real_moves, clone_moves)
    real_moves.each do | dir, cells |
      cells.keep_if do | cell |
        clone_moves[dir].find { |clone_cell| clone_cell.coords == cell.coords }
      end
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

  # King in Check? - Check if the given color's King is in danger (Check)
  def king_in_check?(king_color)
    king_cell = find_king_cell(king_color)
    enemy_color = king_color.opposite
    # Does ANY living enemy Piece...
    @living_pieces[enemy_color].any? do | enemy_piece |
      # Have ANY move...
      enemy_moves = generate_moves(enemy_piece)
      enemy_moves.values.flatten.any? do | enemy_move | 
        # That lands on the same Cell as the King Cell?
        enemy_move == king_cell
      end
    end
  end

  # King in Checkmate? - Check if the given color's King is in Checkmate
  # True if none of the [color]'s Pieces have any legal moves
  def king_in_checkmate?(king_color)
    @living_pieces[king_color].none? do | piece |
      moves = generate_legal_moves(piece)
      moves.values.flatten.any?
    end
  end

  # Given a Color, find and return that color's King's cell
  def find_king_cell(king_color)
    @living_pieces[king_color].find { | piece | piece.is_a?(King) }.position
  end

  # Given Piece, Start, and End, move the Piece from Start to End
  # and create a Move object
  def move_piece(piece: @active_piece, start_cell: @active_piece.position, end_cell:, dir:)
    start_cell.update_piece(nil)
    piece.update_position(end_cell)
    kill = end_cell.has_enemy?(piece.color) ? kill_piece(end_cell.piece) : nil
    end_cell.update_piece(piece)

    if dir.match?(/castle/)
      case piece
      when King
        castle_move = move_castling_rook(piece, dir)
        Move.new(piece: piece, start_cell: start_cell, end_cell: end_cell, rook_move: castle_move)
      when Rook
        Move.new(piece: piece, start_cell: start_cell, end_cell: end_cell, secondary: true)
      end
    else
      Move.new(piece: piece, start_cell: start_cell, end_cell: end_cell, kill: kill)
    end
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
    revive_piece(last_move.kill) if last_move.kill
  end
  
  # Revive the given Piece and add it back to @living_pieces
  def revive_piece(piece)
    piece.is_revived
    @living_pieces[piece.color] << piece
  end 
end