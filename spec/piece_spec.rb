# frozen_string_literal: true
require './lib/pieces/piece'
require './lib/pieces/piece_factories'
require './lib/cell'


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

  describe '#update_position' do
    before do
      @color = :W
      @start_cell = instance_double(Cell, column: 'a', row: 1)
      @end_cell = instance_double(Cell, column: 'a', row: 5)
    end
    
    subject(:piece_position) { described_class.new(@color, @start_cell) }
    
    it "changes the Piece's @position to the given Cell" do
      expect { piece_position.update_position(@end_cell) }.to change { piece_position.position }.to(@end_cell)
    end
  end

  describe '#is_killed' do
    subject(:piece_killed) { described_class.new(:W, 'CellA1') }
    it "changes piece's @killed to true" do
      expect { piece_killed.is_killed }.to change { piece_killed.killed }.to true
    end

    it "changes piece's @position to nil" do
      expect { piece_killed.is_killed }.to change { piece_killed.position }.to nil
    end
  end

  describe '#is_revived' do
    subject(:piece_revive) { described_class.new(:W, 'CellA1') }
    it "sets piece's @killed to false" do
      piece_revive.instance_variable_set(:@killed, true)
      expect { piece_revive.is_revived }.to change { piece_revive.killed }.to false
    end
  end

  describe '#has_moves?' do
    subject(:piece_moves) { described_class.new(:W, 'CellA2') }
    
    context 'when the Piece has at least one move' do
      before do
        @moves = { forward: ['CellA3'], initial: ['CellA4'], forward_left: [], forward_right: [] }
        piece_moves.instance_variable_set(:@moves, @moves)
      end
      it 'returns true' do
        expect(piece_moves.has_moves?).to be true
      end  
    end
    
    context "when the Piece has no moves" do
      before do
        @moves = { forward: [], initial: [], forward_left: [], forward_right: [] }
        piece_moves.instance_variable_set(:@moves, @moves)
      end

      it 'returns false' do
        expect(piece_moves.has_moves?).to be false
      end
    end
  end
end