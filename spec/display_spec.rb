# frozen_string_literal: true
require './lib/board'
require './lib/cell'
require './lib/display'
require './lib/pieces/piece'
require './lib/pieces/pawn'

# Board
RSpec.configure do
  include Displayable
end

# Display/Print the Chess Board
describe '#print_board' do
  before do
    @cell_a1 = instance_double(Cell, 'a1', column: 'a', row: 1)
    @cell_a2 = instance_double(Cell, 'a2', column: 'a', row: 2)
    @cell_b1 = instance_double(Cell, 'b1', column: 'b', row: 1)
    @cell_b2 = instance_double(Cell, 'b2', column: 'b', row: 2)

    @rows = { 1 => [@cell_a1, @cell_b1], 2 => [@cell_a2, @cell_b2] }
  end

  # Rearrange the Cells into the print order (a8->h8, ..., a1->h1)
  describe '#set_print_order' do
    it 'returns a new array filled with the values of @rows in reverse order' do
      print_order = [@cell_a2, @cell_b2, @cell_a1, @cell_b1]
      expect(set_print_order).to eq(print_order)
    end
  end

  # Calculate and return the string for the current cell (Piece or Blank)
  describe '#set_string' do
    context 'for the default Piece icons' do
      it "returns ♟ (Black Pawn) when the cell's @piece is a Black Pawn" do
        pawn_a2 = instance_double(Pawn, class: Pawn, position: @cell_a2, color: :B)
        allow(@cell_a2).to receive(:piece).and_return(pawn_a2)
  
        expect(set_string(@cell_a2)).to eq('♙')
      end
  
      it "returns ♙.white (White Pawn) when the @piece is a White Pawn" do
        pawn_b2 = instance_double(Pawn, class: Pawn, position: @cell_b2, color: :W)
        allow(@cell_b2).to receive(:piece).and_return(pawn_b2)
        expect(set_string(@cell_b2)).to eq('♟')
      end
    end
  
    context "when the cell's @piece is nil (no piece)" do
      it "returns an empty string ('')" do
        allow(@cell_a2).to receive(:piece).and_return(nil)
        expect(set_string(@cell_a2)).to eq(' ')
      end
    end
  end
  
  # Calculate and return the BG Color for the current Cell
  describe '#set_background' do
    context 'for the default Black or White backgrounds' do
      it "returns 40 (Black) when the cell's @row + @column = EVEN" do
        expect(set_background(@cell_a1)).to eq(40)
      end

      it "returns 47(White) when the cell @row+@column is ODD" do
        expect(set_background(@cell_a2)).to eq(47)
      end
    end
  end
end


