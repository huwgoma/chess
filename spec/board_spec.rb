# frozen_string_literal: true
require './lib/board'
require './lib/cell'
require './lib/pieces/piece'
require './lib/pieces/pawn'
require './lib/pieces/rook'
require './lib/pieces/piece_factories'
require 'pry'

describe Board do
  # Test the Board Preparation/Utility Methods first
  context "Board Preparation/Utility Methods" do
    before do
      @cell = class_double(Cell).as_stubbed_const
  
      @cell_a1 = instance_double(Cell, 'a1', column: 'a', row: 1)
      @cell_a2 = instance_double(Cell, 'a2', column: 'a', row: 2)
      @cell_b1 = instance_double(Cell, 'b1', column: 'b', row: 1)
      @cell_b2 = instance_double(Cell, 'b2', column: 'b', row: 2)
  
      @cell_list = [@cell_a1, @cell_a2, @cell_b1, @cell_b2]
  
      @column_hash = {'a' => [@cell_a1, @cell_a2], 'b' => [@cell_b1, @cell_b2]}
      @row_hash = {1 => [@cell_a1, @cell_b1], 2 => [@cell_a2, @cell_b2]}
    end  
    
    describe '#prepare_board' do
      subject(:board_prepare) { described_class.new }
      # Initialize the 64 Cells
      describe '#initialize_cells' do
        it 'sends ::new to Cell class 64 times' do
          expect(@cell).to receive(:new).exactly(64).times
          board_prepare.initialize_cells
        end
      end
  
      # Sort @cells into columns/rows
      describe '#sort_cells' do
        before do
          board_prepare.instance_variable_set(:@cells, @cell_list)
        end
  
        context "when given :column as the axis parameter" do
          it 'sorts @cells into a Hash of cells organized by columns' do
            expect(board_prepare.sort_cells(:column)).to eq(@column_hash) 
          end
        end
  
        context "when given :row as the axis parameter" do   
          it 'sorts @cells into a Hash of cells organized by rows' do
            expect(board_prepare.sort_cells(:row)).to eq(@row_hash) 
          end
        end
      end
  
      # Iterate through the 32 Pieces and place them onto their initial Cells
      describe '#place_pieces' do
        before do
          @piece = class_double(Piece).as_stubbed_const
          @pieces = { 'a1' => { color: :W, type: :Rook } } 
  
          board_prepare.instance_variable_set(:@columns, @column_hash)
          board_prepare.instance_variable_set(:@rows, @row_hash)
  
          @rook_factory = instance_double(RookFactory)
          allow(@piece).to receive(:select_factory).and_return(@rook_factory)
          allow(@rook_factory).to receive(:place_piece)
        end
        
        it "calls ::select_factory on Piece using the current piece's type" do
          cell_a1_type = :Rook
  
          expect(@piece).to receive(:select_factory).with(cell_a1_type)
          board_prepare.place_pieces(@pieces)
        end
  
        it "sends #place_piece to the PieceFactory subclass object" do
          expect(@rook_factory).to receive(:place_piece)
          board_prepare.place_pieces(@pieces)
        end
      end
    end
  
    # Find and return the corresponding Cell given a coordinate input
    describe '#find_cell' do
      subject(:board_find) { described_class.new }
  
      before do
        
        board_find.instance_variable_set(:@columns, @column_hash)
        board_find.instance_variable_set(:@rows, @row_hash)
      end
  
      context 'when given a valid inbound alphanumeric coordinate' do
        it 'returns the corresponding Cell object' do
          #cell_a1 = instance_double(Cell, 'a1', column: 'a', row: 1)
          coords = 'a1'
          #binding.pry
          expect(board_find.find_cell(coords)).to eq(@cell_a1)
        end
      end
  
      context 'when given an invalid out of bounds coordinate' do
        it 'returns nil' do
          coords = 'h9'
          expect(board_find.find_cell(coords)).to be nil
        end
      end
    end
  end

  before do
    # Create a Board of Instance Doubles for Cells
    @cell_doubles = []
    8.times do | x |
      column = (x + 97).chr
      8.times do | y |
        row = (y + 1)
        @cell_doubles << instance_double(Cell, "#{column+row.to_s}", 
          column: column, row: row, 
          piece: nil, empty?: true, has_enemy?: false, has_ally?: false)
      end
    end

    # Set each Board (subject)'s @cells to @cell_doubles
    subject.instance_variable_set(:@cells, @cell_doubles)
    # Sort @cell_doubles for each Board into column/row Hashes
    @columns = subject.sort_cells(:column)
    @rows = subject.sort_cells(:row)
    # Then set each Board's @columns/@rows to the sorted @cell_double Hashes
    subject.instance_variable_set(:@columns, @columns)
    subject.instance_variable_set(:@rows, @rows)
  end

  # Generate Moves - Given a Piece, generate its possible moves
  # - Does not account for the King's safety
  describe '#generate_moves' do
    subject(:board_moves) { described_class.new }

    # Generate Moves - Test Cases
    # Test Cases - Pawn
    context "when the given Piece is a Pawn" do
      before do
        pawn_moves = { forward:[], initial:[], forward_left:[], forward_right:[] }
        
        @cell_d2 = board_moves.find_cell('d2')
        # Piece is_a?(Pawn) #=> true
        @w_pawn_d2 = instance_double(Pawn, class: Pawn, is_a?: true,
          moves: pawn_moves, initial: true, 
          position: @cell_d2, color: :W, forward: 1)
        
        @cell_d3 = board_moves.find_cell('d3')

        @cell_d4 = board_moves.find_cell('d4')
        @w_pawn_d4 = instance_double(Pawn, class: Pawn, is_a?: true,
          moves: pawn_moves, initial: false, 
          position: @cell_d4, color: :W, forward: 1)

        @cell_d5 = board_moves.find_cell('d5')

        @cell_d7 = board_moves.find_cell('d7')
        @b_pawn_d7 = instance_double(Pawn, class: Pawn, is_a?: true,
          moves: pawn_moves, initial: true,
          position: @cell_d7, color: :B, forward: -1)
      end
      
      # Forward - Move 1 cell forward (D4->D5)
      context "when the Cell in front of the Pawn is empty" do
        it 'moves forward 1 cell' do
          moves = { forward: [@cell_d5] }
          expect(board_moves.generate_moves(@w_pawn_d4)).to eq(moves)
        end
      end
    
      # Initial - Move 2 cells forward (D2->D4)
      context "when the 2 Cells in front of the Pawn are empty, and the Pawn has not moved yet" do
        it 'moves forward 2 cells' do
          moves = { forward: [@cell_d3], initial: [@cell_d4] }
          expect(board_moves.generate_moves(@w_pawn_d2)).to eq(moves)
        end
      end
      
      # Forward - Cannot move if the Cell is occupied (D4->D5 blocked)
      # Initial - Cannot move if forward Cell is occupied (D2->D4 blocked by D3)
      context "when the first Cell in front of the Pawn is occupied" do
        it 'cannot move forward' do
          allow(@cell_d5).to receive(:empty?).and_return(false)
          moves = {}
          expect(board_moves.generate_moves(@w_pawn_d4)).to eq(moves)
        end

        it 'cannot move forward 2 cells, even if initial move is allowed and empty' do
          allow(@cell_d3).to receive(:empty?).and_return(false)
          moves = {}
          expect(board_moves.generate_moves(@w_pawn_d2)).to eq(moves)
        end
      end
      
      # Initial - Cannot move if the Initial Cell is blocked
      # (but CAN move to the Forward Cell if that's empty) (D2->D3->D4 blocked)
      context "when the initial Cell is occupied" do
        it 'cannot move forward 2 cells, but CAN move to the first Cell if empty' do
          allow(@cell_d4).to receive(:empty?).and_return(false)
          moves = { forward: [@cell_d3] }
          expect(board_moves.generate_moves(@w_pawn_d2)).to eq(moves)
        end
      end
      
      # Diagonal - Can only move if Diagonal Cell has an enemy Piece on it
      # Forward Left - Occupied; Forward Right - Not Occupied
      context "when one of the Diagonal Cells are occupied by an enemy" do
        it 'can only move diagonally if that cell has an enemy' do
          # Block Cell D3
          allow(@cell_d3).to receive(:empty?).and_return(false)
          # Place a juicy enemy Piece on Cell C3 (Diagonal Left)
          cell_c3 = board_moves.find_cell('c3')
          allow(cell_c3).to receive(:has_enemy?).and_return(true)
  
          moves = { forward_left: [cell_c3] }
          expect(board_moves.generate_moves(@w_pawn_d2)).to eq(moves)
        end
      end
      
      # Direction - Black Pawns move in reverse (Forward = -1)
      context "when the Pawn is black" do
        it 'moves DOWN the board instead of up' do
          # Place enemy Piece on C6 to test Diagonal Cell
          cell_c6 = board_moves.find_cell('c6')
          allow(cell_c6).to receive(:has_enemy?).and_return(true)
          # Forward
          cell_d6 = board_moves.find_cell('d6')
          # Initial
          cell_d5 = board_moves.find_cell('d5')
  
          moves = { forward: [cell_d6], initial: [cell_d5], forward_left: [cell_c6] }
          expect(board_moves.generate_moves(@b_pawn_d7)).to eq(moves)
        end
      end
    end

    # For all Pieces other than Pawns, we keep the Cell if it is empty 
    # OR if it has an enemy Piece
    # If the Cell has a Piece, exit the current direction's loop; otherwise, continue
    
    # Test Cases - Rook
    context "when the given Piece is a Rook (Infinite Movement)" do
      before do
        @rook_moves = { top:[], right:[], bot:[], left:[] }
        # Piece is_a?(Pawn) #=> false
        @cell_b4 = board_moves.find_cell('b4')
        @w_rook_b4 = instance_double(Rook, class: Rook, is_a?: false,
          moves: @rook_moves, position: @cell_b4, color: :W)

        @cell_b5 = board_moves.find_cell('b5')
        @cell_b6 = board_moves.find_cell('b6')
        @cell_b7 = board_moves.find_cell('b7')
        @cell_b8 = board_moves.find_cell('b8')
      end

      context "when there are no other Pieces in its path" do
        it 'iterates until the end of the Board is reached' do
          top_moves = [@cell_b5, @cell_b6, @cell_b7, @cell_b8]
          expect(board_moves.generate_moves(@w_rook_b4)[:top]).to eq(top_moves)
        end
      end

      context "when there is an enemy Piece in its path" do
        it "iterates until that Cell is reached, then stops - Inclusive" do
          # Enemy Piece at B7
          allow(@cell_b7).to receive(:empty?).and_return(false)
          allow(@cell_b7).to receive(:has_enemy?).and_return(true)

          top_moves = [@cell_b5, @cell_b6, @cell_b7]
          expect(board_moves.generate_moves(@w_rook_b4)[:top]).to eq(top_moves)
        end
      end

      context "when there is an ally Piece in its path" do
        it "iterates until that Cell is reached, then stops - Exclusive" do
          # Ally Piece at B7 ; has_enemy? #=> false
          allow(@cell_b7).to receive(:empty?).and_return(false)

          top_moves = [@cell_b5, @cell_b6]
          expect(board_moves.generate_moves(@w_rook_b4)[:top]).to eq(top_moves)
        end
      end
      
    end
  end

  # Given a Piece's possible end Cell, decide whether to keep it or not;
  # Is the Cell a valid Cell for the Piece to move to? 
  describe '#keep_piece_move?' do
    subject(:board_piece_move) { described_class.new }
    before do
      @piece = instance_double(Rook, color: :W)
    end
    
    it 'returns true if the given cell is empty' do
      empty_cell = instance_double(Cell, empty?: true)
      expect(board_piece_move.keep_piece_move?(empty_cell, @piece)).to be true
    end

    it 'returns true if the given cell has an enemy piece on it' do
      enemy_cell = instance_double(Cell, empty?: false, has_enemy?: true)
      expect(board_piece_move.keep_piece_move?(enemy_cell, @piece)).to be true
    end

    it 'returns false if the given cell has an ally piece on it' do
      ally_cell = instance_double(Cell, empty?: false, has_enemy?: false)
      expect(board_piece_move.keep_piece_move?(ally_cell, @piece)).to be false
    end
  end

  # Pawns follow a different ruleset from other Pieces - Decide whether to
  # keep the given Cell for the given Pawn
  describe '#keep_pawn_move?' do
    subject (:board_pawn_move) { described_class.new }
    before do
      @pawn = instance_double(Pawn, color: :W, forward: 1)
    end

    context "when the given direction is :forward" do
      before do
        @direction = :forward
      end
      it 'returns true if the given cell is empty' do
        cell = instance_double(Cell, empty?: true)
        expect(board_pawn_move.keep_pawn_move?(cell, @direction, @pawn)).to be true
      end

      it 'returns false if the given cell is not empty' do
        cell = instance_double(Cell, empty?: false)
        expect(board_pawn_move.keep_pawn_move?(cell, @direction, @pawn)).to be false
      end
    end

    context "when the given direction is :initial" do
      before do
        @direction = :initial
        @initial_cell = board_pawn_move.find_cell('a4')
        @forward_cell = board_pawn_move.find_cell('a3')
      end
      
      # Initial only returns true under the following circumstances:
      # The pawn has not moved (@initial = true)
      # The initial cell (+2) and forward cell (+1) are both unoccupied
      it 'returns true if the Pawn has not moved, the forward cell is empty, AND the given cell is empty' do
        allow(@pawn).to receive(:initial).and_return(true)
        expect(board_pawn_move.keep_pawn_move?(@initial_cell, @direction, @pawn)).to be true
      end

      it 'returns false otherwise' do
        allow(@pawn).to receive(:initial).and_return(false)
        expect(board_pawn_move.keep_pawn_move?(@initial_cell, @direction, @pawn)).to be false
      end
    end

    context "when the given direction is :forward left/right" do
      before do
        @direction = :forward_left
      end

      it 'returns true if the Cell has an enemy on it' do
        enemy_cell = instance_double(Cell, has_enemy?: true)
        expect(board_pawn_move.keep_pawn_move?(enemy_cell, @direction, @pawn)).to be true
      end

      it 'returns false if the Cell is empty or has an ally on it' do
        cell = instance_double(Cell, has_enemy?: false)
        expect(board_pawn_move.keep_pawn_move?(cell, @direction, @pawn)).to be false
      end
    end
  end

  # Verify Moves - Given a Piece, verify its @moves Hash by checking whether 
  # each move can be made without putting the allied King into check
  describe '#verify_moves' do
    subject(:board_verify) { described_class.new }    
  end


end