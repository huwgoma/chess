# frozen_string_literal: true
Dir.glob('./lib/*.rb').each { |file| require file unless file.include?('main') }
Dir.glob(('./lib/pieces/*.rb'), &method(:require))
require 'pry'

RSpec.configure do
  include SpecialMoves
end

describe SpecialMoves do
  # Board Class Setup
  before do
    # Create a Board of Instance Doubles for Cells
    @cell_doubles = []
    8.times do | x |
      column = (x + 97).chr
      8.times do | y |
        row = (y + 1)
        @cell_doubles << instance_double(Cell, "#{column+row.to_s}", 
          column: column, row: row, 
          piece: nil, empty?: true, has_enemy?: false, has_ally?: false,
          update_piece: nil)
      end
    end

    # Set each Board (subject)'s @cells to @cell_doubles
    subject.instance_variable_set(:@cells, @cell_doubles)
    # Sort @cell_doubles for each Board into column/row Hashes
    @columns = subject.sort_cells(:column)
    @rows = subject.sort_cells(:row)
    # Then set each Board's @columns/@rows to the sorted @cell_double Hashes
    subject.instance_variable_set(:@columns, @columns)
    subject.instance_variable_set(:@rows, @rows)    
  end

  # PawnPromotion
  describe '#promotion_possible?' do
    subject(:board_pawn_promotion) { Board.new }

    context "when the @active_piece is a Pawn" do
      context "when the last Move's end_cell is at the END of the board" do
        it 'returns true' do
          
        end
      end

      context "when the last Move's end_cell is not at the end of the board" do
        it 'returns false' do
          
        end
      end
    end

    context 'when the @active_piece is not a Pawn' do
      it 'returns false' do
        
      end
    end
  end
end
