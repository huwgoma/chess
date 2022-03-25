# frozen_string_literal: true
require 'yaml'

class Piece
  INITIAL_PIECES = YAML.load(YAML.load_file('lib/pieces/initial_pieces.yaml'))

  MOVEMENT = { }

  attr_reader :color, :position, :moves, :killed

  def initialize(color, cell)
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
    self.class::MOVEMENT.keys.reduce({}) do | hash, direction |
      next hash if direction == :infinite
      hash[direction] = Array.new
      hash
    end
  end
end
