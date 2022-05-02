# frozen_string_literal: true

require 'yaml'

# Piece Class - Parent class for Chess Pieces
class Piece
  INITIAL_PIECES = YAML.load(YAML.load_file('lib/pieces/initial_pieces.yaml'))

  MOVEMENT = {}.freeze

  attr_reader :color, :position, :moves, :killed

  def initialize(color = :W, cell = nil)
    @color = color
    @killed = false
    @position = cell
    @moves = initialize_moves
  end

  def self.select_factory(type)
    case type
    when :Pawn
      PawnFactory.new
    when :Rook
      RookFactory.new
    when :Knight
      KnightFactory.new
    when :Bishop
      BishopFactory.new
    when :Queen
      QueenFactory.new
    when :King
      KingFactory.new
    else
      raise 'unexpected_piece_type_error'
    end
  end

  def update_position(cell)
    @position = cell
  end

  def initialize_moves
    self.class::MOVEMENT.keys.each_with_object({}) do |direction, hash|
      next if direction == :infinite

      hash[direction] = []
    end
  end

  def is_killed
    @killed = true
  end

  def is_revived
    @killed = false
  end

  def has_moves?
    @moves.values.flatten.any?
  end
end
