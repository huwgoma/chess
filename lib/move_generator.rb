# frozen_string_literal: true

# Move Generator Module - Hold methods responsible for generating/validating moves
module MoveGenerator
  # Generate Legal Moves - Generate the given Piece's legal moves
  def generate_legal_moves(piece)
    generate_moves(piece)
    verify_moves(piece)
  end

  # Generate Moves - Given a Piece, generate its possible moves
  # - Does not account for the King's safety
  def generate_moves(piece)
    movement = piece.class::MOVEMENT
    piece.moves.each do |dir, cells|
      cells.clear
      forward = piece.is_a?(Pawn) ? piece.forward : 1

      (1).upto(movement[:infinite] ? 7 : 1) do |i|
        column = piece.position.column.shift(i * movement[dir][:column])
        row = piece.position.row + (i * movement[dir][:row] * forward)
        cell = find_cell(column + row.to_s)
        break if cell.nil?

        keep_cell = keep_piece_move?(cell, dir, piece)
        cells << cell if keep_cell
        break if cell.piece
      end
    end
  end

  # Verify Moves - Given a Piece, verify its @moves Hash by checking whether
  # each move can be made without putting the allied King into check
  def verify_moves(piece, moves = piece.moves)
    clone_board = Marshal.load(Marshal.dump(self))
    clone_piece = clone_board.find_cell(piece.position.coords).piece

    moves.each do |dir, cells|
      cells.reject! do |cell|
        clone_board.move_piece(piece: clone_piece, start_cell: clone_piece.position,
                               end_cell: clone_board.find_cell(cell.coords), dir: dir)
        reject_cell = clone_board.king_in_check?(piece.color)
        clone_board.undo_last_move
        reject_cell
      end
    end
  end

  # Given a Piece's possible end Cell, decide whether to keep it or not
  def keep_piece_move?(cell, dir, piece)
    case piece
    when Pawn
      keep_pawn_move?(cell, dir, piece)
    when King
      keep_king_move?(cell, dir, piece)
    else
      keep_normal_move?(cell, piece)
    end
  end

  # Given a normal Piece's end cell, decide whether that move is possible or not
  def keep_normal_move?(cell, piece)
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
    when :en_passant_left, :en_passant_right
      en_passant_legal?(cell, pawn)
    end
  end

  # Given a King's possible end Cell, decide whether that move is possible or not
  def keep_king_move?(cell, direction, king)
    if direction.match?(/castle/)
      castling_possible?(king, direction)
    else
      keep_normal_move?(cell, king)
    end
  end
end
