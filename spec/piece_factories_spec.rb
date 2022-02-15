# frozen_string_literal: true
require './lib/pieces/piece_factories'
require './lib/pieces/piece'
require './lib/cell'


describe PieceFactory do
  before do
    @rook = instance_double(Rook)
    @cell_a1 = instance_double(Cell, column: 'a', row: 1)
  end

  describe '#place_piece' do
    subject(:piece_factory_place) { described_class.new }

    it 'sends #update_position to the Piece subclass object' do
      expect(@rook).to receive(:update_position)
      color = :W
      cell = @cell_a1
      piece_factory_place.place_piece(color, cell)
    end
  end
end