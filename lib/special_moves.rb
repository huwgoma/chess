# frozen_string_literal: true

require './lib/game_prompts'

# Namespace for Methods concerning Pawn Promotion
module PawnPromotion
  include GamePrompts

  def promotion_possible?(last_move)
    return false unless last_move.piece.is_a?(Pawn)

    minmax_rows = @board.rows.minmax.flatten.select(&Integer.method(:===))
    end_row = last_move.piece.color.white? ? minmax_rows.max : minmax_rows.min
    last_move.end.row == end_row
  end

  PROMOTION_OPTIONS = {
    'Q' => :Queen,
    'R' => :Rook,
    'B' => :Bishop,
    'KN' => :Knight
  }.freeze

  def promote_pawn(last_move)
    type = choose_promotion_type
    pawn = last_move.piece
    coords = last_move.end.column + last_move.end.row.to_s
    piece_hash = { coords => { color: pawn.color, type: type } }
    @board.kill_piece(pawn)
    @board.place_pieces(piece_hash)
  end

  def choose_promotion_type
    input = verify_promotion_input(gets.chomp)
    case input
    when InputWarning
      puts input.to_s
      choose_promotion_type
    when String
      PROMOTION_OPTIONS[input]
    end
  end

  def verify_promotion_input(input)
    input = input.upcase
    return InvalidPromotionInput.new unless promotion_input_valid?(input)

    input
  end

  def promotion_input_valid?(input)
    PROMOTION_OPTIONS.keys.include?(input)
  end
end

# Namespace for Methods concerning Castling
module Castling
  def move_castling_rook(king, dir)
    rook_cells = find_rook_cells(king, dir)
    rook_start = rook_cells[:start]
    rook_end = rook_cells[:end]
    rook = rook_start.piece

    move_piece(piece: rook, start_cell: rook_start, end_cell: rook_end, dir: dir)
  end

  def castling_possible?(king, dir)
    # King Moved?
    return false if king.moved

    # Rook Moved?
    rook = find_castling_rook(king, dir)
    return false if rook&.moved || rook.nil?

    # Lane Clear?
    lane_dir = rook.position.coords <=> king.position.coords
    return false unless castle_lane_clear?(king.position, rook.position, lane_dir)

    # King in Check?
    return false if king_in_check?(king.color)

    # Middle Cell Attacked?
    middle_cell = find_cell(king.position.column.shift(lane_dir) + king.position.row.to_s)
    return false if middle_cell_attacked?(king, middle_cell)

    true
  end

  # Helper methods for Castling
  # Find and return the castling Rook Piece
  def find_castling_rook(king, dir)
    rook = find_rook_cells(king, dir)[:start].piece
    return rook if rook.is_a?(Rook)
  end

  # Find and return a Hash of castling Rook's start/end cells
  def find_rook_cells(king, dir)
    row = king.color.white? ? 1 : 8
    start_col, end_col = dir.match?(/king/) ? ['h', 'f'] : ['a', 'd']
    rook_start = find_cell(start_col + row.to_s)
    rook_end = find_cell(end_col + row.to_s)
    { start: rook_start, end: rook_end }
  end

  # Check if the lane between the King and castling Rook is clear
  def castle_lane_clear?(cell, rook_cell, lane_dir)
    cell = find_cell(cell.column.shift(lane_dir) + cell.row.to_s)
    # Base case: If we make it to the rook cell
    return true if cell == rook_cell

    if cell.empty?
      castle_lane_clear?(cell, rook_cell, lane_dir)
    else
      false
    end
  end

  # Check if the middle cell (D1/F1 or D8/F8) is threatened
  def middle_cell_attacked?(king, middle_cell)
    intermediate_move = verify_moves(king, { middle: [middle_cell] })
    intermediate_move[:middle].empty?
  end
end

# Namespace for Methods concerning En Passant
module EnPassant
  # Does the given Piece have an En Passant available?
  def en_passant_available?(piece)
    return false unless piece.is_a?(Pawn)

    piece.moves.select { |dir, _cells| dir.match?(/en_passant/) }.values.flatten.any?
  end

  # Find and return the Pawn to be captured by the En Passant
  def find_en_passant_kill(pawn_end, pawn)
    kill_cell = find_cell(pawn_end.column + (pawn_end.row - pawn.forward).to_s)
    kill_pawn = kill_cell.piece

    return kill_pawn if kill_cell.has_enemy?(pawn.color) && kill_pawn.is_a?(Pawn)
  end

  # Is an En Passant possible?
  def en_passant_legal?(pawn_end, pawn)
    kill_pawn = find_en_passant_kill(pawn_end, pawn)
    return false unless kill_pawn

    return false unless last_move_initial?(kill_pawn)

    true
  end

  # Did the Pawn (to be captured) move 2 spaces on the last move?
  def last_move_initial?(kill_pawn)
    last_move = Move.last
    last_move&.piece == kill_pawn && last_move.dir == :initial
  end
end

module SpecialMoves
  include PawnPromotion
  include Castling
  include EnPassant
end
