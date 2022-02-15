# frozen_string_literal: true
require 'yaml'

class Piece
  INITIAL_PIECES = YAML.load(YAML.load_file('lib/pieces/initial_pieces.yaml'))

  def initialize
    
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
end
