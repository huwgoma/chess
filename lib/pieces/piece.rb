# frozen_string_literal: true
require 'yaml'
require 'pry'

class Piece
  def initialize
    binding.pry
  end
  INITIAL_PIECES = YAML.load(YAML.load_file('lib/pieces/initial_pieces.yaml'))
  
end
