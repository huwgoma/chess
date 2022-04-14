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
    @move_1 = described_class.new('d3', 'd2', 'WPawn', nil)
    @move_2 = described_class.new('d3', 'd7', 'BRook', 'WPawn')
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

  # Last - Returns the last Move (without removing it)
  describe '::last' do
    it 'returns the last move in the @@stack' do
      expect(Move.last).to eq(@move_2)
    end  
  end

  # Undo - Revert the changes made to Cell@piece and Piece@position
  describe '#undo' do
    before do
      # Start Cell
      @start = instance_double(Cell, 'start', piece: nil)
      allow(@start).to receive(:update_piece)
      # Moving Piece
      @piece = instance_double(Piece, 'piece')
      allow(@piece).to receive(:update_position)
      # End Cell
      @end = instance_double(Cell, 'end', piece: @piece)
      allow(@end).to receive(:update_piece)
      # Piece's @position = @end cell
      allow(@piece).to receive(:position).and_return(@end)
      # Killed Piece
      @killed = instance_double(Piece, 'killed', position: nil)
      allow(@killed).to receive(:update_position)
    end

    subject(:move_undo) { described_class.new(@end, @start, @piece, @killed) }
    
    # Move the Moving Piece back to Start Cell
    it 'sends #update_position with @start Cell to the moving @piece' do
      expect(@piece).to receive(:update_position).with(@start)
      move_undo.undo
    end

    # Place the Moving Piece back on Start Cell
    it 'sends #update_piece with moving @piece to the @start cell' do
      expect(@start).to receive(:update_piece).with(@piece)
      move_undo.undo
    end

    context "if there is no killed piece" do
      before do
        # Set Move's @kill to nil
        move_undo.instance_variable_set(:@killed, nil)
      end
      # Vacate the End Cell
      it 'sends #update_piece with nil to @end cell' do
        expect(@end).to receive(:update_piece).with(nil)
        move_undo.undo
      end
    end
    
    context 'if there is a killed piece in this Move' do
      # Move the Killed Piece back to the End Cell
      it 'sends #update_position with @end to @killed piece' do
        expect(@killed).to receive(:update_position).with(@end)
        move_undo.undo
      end

      # Place the Killed Piece back on End Cell
      it 'sends #update_piece with @killed to @end cell' do
        expect(@end).to receive(:update_piece).with(@killed)
        move_undo.undo
      end
    end
  end
end