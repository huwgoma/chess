# frozen_string_literal: true
require './lib/cell'
require './lib/pieces/piece'
require './lib/pieces/rook'

describe Cell do
  before do
    @cell_a1 = described_class.new('a', 1)
    @cell_a2 = described_class.new('a', 2)
    @cell_b1 = described_class.new('b', 1)
    @cell_b2 = described_class.new('b', 2)
  end

  describe '::find' do
    context "when given an alphanumeric coordinate (eg. 'a2')" do
      it 'returns the corresponding Cell object' do
        expect(described_class.find('a2')).to eq(@cell_a2)
      end
    end

    context "when given an out-of-bounds alphanumeric coordinate (eg. 'h9')" do
      it 'returns nil' do
        expect(described_class.find('h9')).to be_nil
      end
    end
  end

  describe '#update_piece' do
    subject(:cell_piece) { described_class.new('a', 1) }

    it "updates the Cell's @piece to the given Piece object" do
      rook_piece = instance_double(Rook)
      expect { cell_piece.update_piece(rook_piece) }.to change { cell_piece.piece }.to(rook_piece)
    end
  end
  
end