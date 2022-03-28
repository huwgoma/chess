# frozen_string_literal: true
require './lib/move'
require './lib/cell'
require './lib/pieces/piece'
require 'pry'

describe Move do
  before(:each) do
    Move.stack.clear 
  end

  before do
    @move_1 = described_class.new('d2', 'd3', 'WPawn', nil)
    @move_2 = described_class.new('d7', 'd3', 'BRook', 'WPawn')
    @stack = [@move_1, @move_2]
  end
  # Contains an array of Move objects - First in, Last out
  describe '::stack' do
    it "returns Move's @@stack class variable" do
      expect(Move.stack).to eq(@stack)
    end
  end

  # Pop - Removes and returns the last Move object in @@stack
  describe '::pop' do
    it "removes the LAST Move from Move@@stack" do
      stack = [@move_1]
      expect { Move.pop }.to change { Move.stack }.to(stack)
    end

    it 'returns the popped move' do
      expect(Move.pop).to eq(@move_2)
    end
  end

  # Undo - Revert the changes made to Cell@piece and Piece@position
  describe '#undo' do
    before do
      @start = instance_double(Cell, 'start', piece: nil)
      @piece = instance_double(Piece, 'piece')
      @end = instance_double(Cell, 'end', piece: @piece)
      allow(@piece).to receive(:position).and_return(@end)
      @killed = instance_double(Piece, 'killed', position: nil)
    end

    subject(:move_undo) { described_class.new }
    
    it 'sends #update_position with @start Cell to the moving @piece' do
      
    end

    it 'sends #update_piece with moving @piece to the @start cell' do
      
    end

    it 'sends #update_piece with nil to @end cell' do
      
    end

    context 'if there is a killed piece in this Move' do
      it 'sends #update_position with @end to @killed piece' do
        
      end

      it 'sends #update_piece with @killed to @end cell' do
        
      end
    end
  end
end