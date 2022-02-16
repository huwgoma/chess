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
    context '#place_piece is called on an instance of a PieceFactory subclass' do
      describe RookFactory do
        subject(:rook_factory) { RookFactory.new }
        before do  
          allow(rook_factory).to receive(:create_piece).and_return(@rook)
        end

        it 'sends #update_position to the Piece subclass object' do
          color = :W
          cell = @cell_a1
          expect(@rook).to receive(:update_position)
          rook_factory.place_piece(color, cell)
        end
      end
    end
  end
end