# frozen_string_literal: true
require './lib/pieces/piece'
require './lib/pieces/piece_factories'


describe Piece do
  describe '::select_factory' do
    context 'when it is given a type parameter of :Pawn' do
      before do
        @pawn_factory = class_double(PawnFactory).as_stubbed_const
      end
      it 'sends a #new message to PawnFactory' do
        expect(@pawn_factory).to receive(:new)
        described_class.select_factory(:Pawn)
      end

      it 'returns the corresponding Factory object(PawnFactory)' do
        pawn_factory_instance = instance_double(PawnFactory)
        allow(@pawn_factory).to receive(:new).and_return(pawn_factory_instance)
        expect(described_class.select_factory(:Pawn)).to eq(pawn_factory_instance)
      end
    end
  end
end