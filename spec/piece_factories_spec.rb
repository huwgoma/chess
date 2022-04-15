# frozen_string_literal: true
require './lib/pieces/piece_factories'
require './lib/pieces/piece'
require './lib/pieces/rook'
require './lib/cell'

describe PieceFactory do
  before do
    @rook = instance_double(Rook)
    allow(@rook).to receive(:update_position)
    @cell_a1 = instance_double(Cell, column: 'a', row: 1)
    allow(@cell_a1).to receive(:update_piece)
  end

  describe '#place_piece' do
    context '#place_piece is called on an instance of a PieceFactory subclass' do
      describe RookFactory do
        subject(:rook_factory) { RookFactory.new }
        before do  
          allow(rook_factory).to receive(:create_piece).and_return(@rook)
        end

        it 'sends #update_piece to the Cell object' do
          color = :W
          cell = @cell_a1
          expect(cell).to receive(:update_piece).with(@rook)
          rook_factory.place_piece(color, cell)
        end
      end
    end
  end
end