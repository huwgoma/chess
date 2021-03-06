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
    @move_1 = described_class.new(piece: 'WPawn', start_cell: 'd2', dir: :forward, end_cell: 'd3')
    @move_2 = described_class.new(piece: 'BRook',  start_cell: 'd7', end_cell: 'd3', dir: :bot, kill: 'WPawn')
    @stack = [@move_1, @move_2]
  end

  # Contains an array of Move objects - First in, Last out
  describe '::stack' do
    it "returns Move's @@stack class variable" do
      expect(Move.stack).to eq(@stack)
    end

    it 'does not add Moves to @@stack if the Move has the secondary: true flag' do
      move_3 = described_class.new(piece: 'WRook', start_cell: 'h1', end_cell: 'f1', dir: :castle_king, secondary: true)
      expect(Move.stack).to eq(@stack)
    end
  end

  # Set Move's @@stack to the given array of moves (when a game is loaded)
  describe '::load_stack' do
    before do
      alt_move_1 = described_class.new(piece: 'WPawn', start_cell: 'd2', dir: :forward, end_cell: 'd3')
      alt_move_2 = described_class.new(piece: 'BRook',  start_cell: 'd7', end_cell: 'd3', dir: :bot, kill: 'WPawn')
      @load_stack = [alt_move_1, alt_move_2]
    end

    it "updates Move's @@stack to the given array" do
      expect{ Move.load_stack(@load_stack) }.to change { Move.stack }.to(@load_stack)
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
    subject(:move_undo) { described_class.new(piece: @piece, start_cell: @start, end_cell: @end, dir: :forward, kill: @kill) }

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
      @kill = instance_double(Piece, 'killed', position: @end)
      allow(@kill).to receive(:update_position)
    end

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

    # Vacate the End Cell
    it 'sends #update_piece with nil to @end_cell' do
      expect(@end).to receive(:update_piece).with(nil)
      move_undo.undo
    end
    
    # If there was a Kill, place the Killed Piece back on its Cell
    context 'if there is a killed piece' do
      # Place the Killed Piece back on End Cell
      it 'sends #update_piece with @kill to @end cell' do
        expect(@end).to receive(:update_piece).with(@kill)
        move_undo.undo
      end
    end

    # En Passant - The killed piece's cell is different from the 
    # moving Pawn's end cell (eg. D5 -> E6; Kill at E5)
    context 'if the killed Piece is NOT the same as the end cell' do
      before do
        # Different cell from end cell
        @enemy_pawn_cell = instance_double(Cell)
        allow(@kill).to receive(:position).and_return(@enemy_pawn_cell)
      end

      it "sends #update_piece with @kill to @kill's cell" do
        expect(@enemy_pawn_cell).to receive(:update_piece).with(@kill)
        move_undo.undo
      end
    end

    context 'if there is a secondary Rook move' do
      before do
        @rook_start = instance_double(Cell, update_piece: nil)
        @rook = instance_double(Piece, 'rook', update_position: @rook_start)
        @rook_end = instance_double(Cell, update_piece: nil)
        rook_move = described_class.new(piece: @rook, start_cell: @rook_start, end_cell: @rook_end, dir: :castle_king, secondary: true)

        # Give our primary Move a secondary @rook_move
        move_undo.instance_variable_set(:@rook_move, rook_move)
      end
      # it undoes that move as well
      it "sends #update_position to the Rook with Rook's @start" do
        expect(@rook).to receive(:update_position).with(@rook_start)
        move_undo.undo
      end

      it "sends #update_piece to the Rook's @start cell with the Rook" do
        expect(@rook_start).to receive(:update_piece).with(@rook)
        move_undo.undo
      end

      it "sends #update_piece to the Rook's @end cell with nil" do
        expect(@rook_end).to receive(:update_piece).with(nil)
        move_undo.undo
      end
    end
  end
end