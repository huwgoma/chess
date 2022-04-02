# frozen_string_literal: true
require './lib/board'
require './lib/cell'
require './lib/pieces/piece'
require './lib/pieces/pawn'
require './lib/pieces/rook'
require './lib/pieces/king'
require './lib/pieces/piece_factories'
require './lib/move'
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
  
      context 'when given a valid alphanumeric coordinate' do
        it 'returns the corresponding Cell object' do
          #cell_a1 = instance_double(Cell, 'a1', column: 'a', row: 1)
          coords = 'a1'
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

    # Set Living Pieces - Iterate through @rows and create a Hash of Pieces
    # that are alive, sorted by their color
    describe '#set_living_pieces' do
      subject(:board_living_pieces) { described_class.new }
      before do
        # Place Pieces on custom 2x2 Board - White on A1/B1, Black on A2/B2 
        @w_pawn_a1 = instance_double(Pawn, 'a1', killed: false, color: :W)
        @w_pawn_b1 = instance_double(Pawn, 'b1', killed: false, color: :W)
        @b_pawn_a2 = instance_double(Pawn, 'a2', killed: false, color: :B)
        @b_pawn_b2 = instance_double(Pawn, 'b2', killed: false, color: :B)
        # Update Cell Info
        allow(@cell_a1).to receive_messages(empty?: false, piece: @w_pawn_a1)
        allow(@cell_b1).to receive_messages(empty?: false, piece:@w_pawn_b1)
        allow(@cell_a2).to receive_messages(empty?: false, piece:@b_pawn_a2)
        allow(@cell_b2).to receive_messages(empty?: false, piece:@b_pawn_b2)

        board_living_pieces.instance_variable_set(:@rows, @row_hash)
      end

      it 'returns a hash of living pieces, sorted by color' do
        living_pieces = { W: [@w_pawn_a1, @w_pawn_b1], B: [@b_pawn_a2, @b_pawn_b2] }
        expect(board_living_pieces.set_living_pieces).to eq(living_pieces)
      end
      
      it 'skips empty cells' do
        # Remove Black Pawn from Cell B2
        allow(@cell_b2).to receive_messages(empty?: true)

        living_pieces = { W: [@w_pawn_a1, @w_pawn_b1], B: [@b_pawn_a2]}
        expect(board_living_pieces.set_living_pieces).to eq(living_pieces)
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
          piece: nil, empty?: true, has_enemy?: false, has_ally?: false,
          update_piece: nil)
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
          moves = { forward: [@cell_d5], initial: [], forward_left: [], forward_right: [] }
          expect(board_moves.generate_moves(@w_pawn_d4)).to eq(moves)
        end
      end
    
      # Initial - Move 2 cells forward (D2->D4)
      context "when the 2 Cells in front of the Pawn are empty, and the Pawn has not moved yet" do
        it 'moves forward 2 cells' do
          moves = { forward: [@cell_d3], initial: [@cell_d4], forward_left:[], forward_right:[] }
          expect(board_moves.generate_moves(@w_pawn_d2)).to eq(moves)
        end
      end
      
      # Forward - Cannot move if the Cell is occupied (D4->D5 blocked)
      # Initial - Cannot move if forward Cell is occupied (D2->D4 blocked by D3)
      context "when the first Cell in front of the Pawn is occupied" do
        it 'cannot move forward' do
          allow(@cell_d5).to receive(:empty?).and_return(false)
          moves = { forward:[], initial:[], forward_left:[], forward_right:[] }
          expect(board_moves.generate_moves(@w_pawn_d4)).to eq(moves)
        end

        it 'cannot move forward 2 cells, even if initial move is allowed and empty' do
          allow(@cell_d3).to receive(:empty?).and_return(false)
          moves = { forward:[], initial:[], forward_left:[], forward_right:[] }
          expect(board_moves.generate_moves(@w_pawn_d2)).to eq(moves)
        end
      end
      
      # Initial - Cannot move if the Initial Cell is blocked
      # (but CAN move to the Forward Cell if that's empty) (D2->D3->D4 blocked)
      context "when the initial Cell is occupied" do
        it 'cannot move forward 2 cells, but CAN move to the first Cell if empty' do
          allow(@cell_d4).to receive(:empty?).and_return(false)
          moves = { forward: [@cell_d3], initial:[], forward_left:[], forward_right:[] }
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
  
          moves = { forward: [], initial: [], forward_left: [cell_c3], forward_right:[] }
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
  
          moves = { forward: [cell_d6], initial: [cell_d5], forward_left: [cell_c6], forward_right: [] }
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
          allow(@cell_b7).to receive(:piece).and_return(instance_double(Piece))

          top_moves = [@cell_b5, @cell_b6, @cell_b7]
          expect(board_moves.generate_moves(@w_rook_b4)[:top]).to eq(top_moves)
        end
      end

      context "when there is an ally Piece in its path" do
        it "iterates until that Cell is reached, then stops - Exclusive" do
          # Ally Piece at B7 ; has_enemy? #=> false
          allow(@cell_b7).to receive(:empty?).and_return(false)
          allow(@cell_b7).to receive(:piece).and_return(instance_double(Piece))

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
    before do
      # Mock a White Pawn at E2
      @cell_e2 = board_verify.find_cell('e2')
      pawn_moves = { forward: [], initial: [], forward_left: [], forward_right: [] }
      @w_pawn = instance_double(Pawn, class:Pawn, 
        moves: pawn_moves, initial: true, update_position: nil,
        position: @cell_e2, color: :W, forward: 1)
      allow(@w_pawn).to receive(:is_a?)
      allow(@w_pawn).to receive(:is_a?).with(Pawn).and_return(true)

      # Mock Pawn Cells
      @cell_e3 = board_verify.find_cell('e3')
      @cell_e4 = board_verify.find_cell('e4')
      @cell_d3 = board_verify.find_cell('d3')
      @cell_f3 = board_verify.find_cell('f3')
      
      # Mock a White King at E1
      @cell_e1 = board_verify.find_cell('e1')
      @w_king = instance_double(King, class:King, position: @cell_e1)
      allow(@w_king).to receive(:is_a?)
      allow(@w_king).to receive(:is_a?).with(King).and_return(true)

      # Mock two Black Rooks (default at A8 and B8)
      rook_moves = { top: [], right: [], bot: [], left: [] }

      cell_a8 = board_verify.find_cell('a8')
      @b_rook_1 = instance_double(Rook, class: Rook, is_a?: true,
        moves: rook_moves, position: cell_a8, color: :B)
      allow(@b_rook_1).to receive(:is_a?).with(Pawn).and_return(false)
      allow(@b_rook_1).to receive(:is_a?).with(King).and_return(false)
      
      cell_b8 = board_verify.find_cell('b8')
      @b_rook_2 = instance_double(Rook, class: Rook, is_a?: true,
        moves: rook_moves, position: cell_b8, color: :B)
      allow(@b_rook_2).to receive(:is_a?).with(Pawn).and_return(false)
      allow(@b_rook_2).to receive(:is_a?).with(King).and_return(false)
      # Mock Living Pieces
      living_pieces = { W: [@w_pawn, @w_king], B: [@b_rook_1, @b_rook_2] }
      board_verify.instance_variable_set(:@living_pieces, living_pieces)
    end

    # Verify Moves - Test Cases
    # Imminent threat - When the King is 1 move away from being in Check;
    # only being protected by the moving Piece
    context "when the King is under no imminent threat" do
      # ie. All generated moves are legal 
      before do
        board_verify.generate_moves(@w_pawn)
      end
      it "does not modify the Piece's @moves Hash" do
        pawn_moves = { forward: [@cell_e3], initial: [@cell_e4], forward_left: [], forward_right: [] }
        expect(board_verify.verify_moves(@w_pawn)).to eq(pawn_moves)
      end
    end

    context "when the King is under imminent threat" do
      before do
        # Move Rook 1 to E5
        cell_e5 = board_verify.find_cell('e5')
        allow(@b_rook_1).to receive(:position).and_return(cell_e5)

        # Place Enemy Pawn on F3
        allow(@cell_f3).to receive(:has_enemy?).and_return(true)
        enemy_pawn = instance_double(Pawn, color: :B)
        allow(enemy_pawn).to receive(:is_killed)
        allow(@cell_f3).to receive(:piece).and_return(enemy_pawn)
        
        # Pawn Moves to each Cell of @moves
        board_verify.generate_moves(@w_pawn)
        
        allow(@cell_e3).to receive(:has_enemy?).with(:W).and_return(false)
        allow(@cell_e4).to receive(:has_enemy?).with(:W).and_return(false)
        allow(@cell_f3).to receive(:has_enemy?).with(:W).and_return(true)
        
        # Rook Moves to each Cell; empty? -> enemy? -> piece?
        allow(@cell_e4).to receive(:empty?).and_return(true, false, true)
        allow(@cell_e4).to receive(:has_enemy?).with(:B).and_return(true)
        allow(@cell_e4).to receive(:piece).and_return(nil, @w_pawn, nil)

        allow(@cell_e3).to receive(:empty?).and_return(false, true)
        allow(@cell_e3).to receive(:has_enemy?).with(:B).and_return(true)
        allow(@cell_e3).to receive(:piece).and_return(@w_pawn, nil)

        allow(@cell_e2).to receive_messages(empty?: true, piece: nil)
        allow(@cell_e1).to receive_messages(empty?: false, has_enemy?: true, piece: @w_king)
      end
      it 'does not allow the Piece to make a move that would put the King into check' do
        pawn_moves = { forward: [@cell_e3], initial: [@cell_e4], forward_left: [], forward_right: [] }
        expect(board_verify.verify_moves(@w_pawn)).to eq(pawn_moves)
      end
    end

    context "when the King is in Check" do
      context "when the King is not also under imminent threat" do
        before do
          # Move Rook 1 to Cell D3
          allow(@b_rook_1).to receive(:position).and_return(@cell_d3)
          allow(@cell_d3).to receive_messages(piece: @b_rook_1, has_enemy?: true)

          # Move W King to Cell F3
          allow(@w_king).to receive(:position).and_return(@cell_f3)

          # Pawn Moves to each @moves Cell
          board_verify.generate_moves(@w_pawn)

          # Rook Moves to each possible Cell
          allow(@b_rook_1).to receive_messages(is_killed: nil, update_position: nil, is_revived: nil)
          
          allow(@cell_e3).to receive(:empty?).and_return(false, true)
          allow(@cell_e3).to receive(:has_enemy?).with(:B).and_return(true)
          allow(@cell_e3).to receive(:piece).and_return(@w_pawn, nil)
        end
        it 'allows the Piece to capture OR block the Checking enemy piece' do
          pawn_moves = { forward: [@cell_e3], initial: [], forward_left: [@cell_d3], forward_right: [] }
          expect(board_verify.verify_moves(@w_pawn)).to eq(pawn_moves)
        end
      end

      context "when the King is also under imminent threat (from another enemy piece)" do
        # If moving the piece would expose the King to Check from another piece
        before do
          # Move Rook 1 to Cell A2; Rook 2 to Cell F3
          cell_a2 = board_verify.find_cell('a2')
          allow(@b_rook_1).to receive(:position).and_return(cell_a2)
          allow(cell_a2).to receive(:piece).and_return(@b_rook_1)

          allow(@b_rook_2).to receive(:position).and_return(@cell_f3)
          allow(@cell_f3).to receive_messages(piece: @b_rook_2, has_enemy?: true)

          # Move the King to Cell F2
          cell_f2 = board_verify.find_cell('f2')
          allow(@w_king).to receive(:position).and_return(cell_f2)

          # Pawn Moves
          board_verify.generate_moves(@w_pawn)
          allow(@cell_f3).to receive(:has_enemy?).with(:W).and_return(true)

          # Rook Moves 
          allow(@b_rook_2).to receive_messages(is_killed: nil, update_position: nil, is_revived: nil)

          allow(@cell_e2).to receive(:empty?).and_return(true)
          allow(cell_f2).to receive_messages(empty?: false, has_enemy?: true)      
        end
        it 'does not allow the Piece to move' do
          pawn_moves = { forward: [], initial: [], forward_left: [], forward_right: [] }
          expect(board_verify.verify_moves(@w_pawn)).to eq(pawn_moves)
        end
      end
    end
  end

  # Move Piece - Given a Piece, Start, and End, move the Piece from Start to End Cell
  describe '#move_piece' do
    subject(:board_move) { described_class.new }
    before do
      # Start Cell
      @start = instance_double(Cell, 'start')
      allow(@start).to receive(:update_piece)
      # Moving Piece
      @piece = instance_double(Piece, 'moved', color: :W)
      allow(@piece).to receive(:update_position)
      # Killed Piece
      @killed = instance_double(Piece, 'killed', color: :B)
      allow(@killed).to receive(:is_killed)

      @end = instance_double(Cell, 'end', piece: @killed, has_enemy?: false)
      allow(@end).to receive(:update_piece)

      # Set Living Pieces
      @living_pieces = { W: [@piece], B: [@killed] }
      board_move.instance_variable_set(:@living_pieces, @living_pieces)
    end

    it 'sends #update_piece with nil to the start cell' do
      expect(@start).to receive(:update_piece).with(nil)
      board_move.move_piece(@end, @piece, @start)
    end

    it 'sends #update_position with the end cell to the moving piece' do
      expect(@piece).to receive(:update_position).with(@end)
      board_move.move_piece(@end, @piece, @start)
    end

    context "if the end cell already has an enemy piece occupying it" do
      before do
        allow(@end).to receive(:has_enemy?).and_return(true)
      end

      it 'kills the enemy piece' do
        expect(board_move).to receive(:kill_piece).with(@killed)
        board_move.move_piece(@end, @piece, @start)
      end

      # If a Killed Piece exists, send that Piece to Move#new
      it 'creates a new Move object with the Killed Piece' do
        move = class_double(Move).as_stubbed_const
        expect(move).to receive(:new).with(@start, @end, @piece, @killed)
        board_move.move_piece(@end, @piece, @start)
      end
    end

    it 'sends #update_piece with the moving piece to the end cell' do
      expect(@end).to receive(:update_piece).with(@piece)
      board_move.move_piece(@end, @piece, @start)
    end

    # If no Piece was killed, killed = nil is passed to Move#new
    it 'creates a new Move object' do
      move = class_double(Move).as_stubbed_const
      expect(move).to receive(:new).with(@start, @end, @piece, nil)
      board_move.move_piece(@end, @piece, @start)
    end
  end

  # King in Check? - Given a Color, check if that Color's King is in danger
  describe '#king_in_check?' do
    subject(:board_check) { described_class.new }
    before do      
      # Mock White King at E2
      cell_e2 = board_check.find_cell('e2')
      @w_king_e2 = instance_double(King, color: :W, position: cell_e2)
      allow(@w_king_e2).to receive(:is_a?)
      allow(@w_king_e2).to receive(:is_a?).with(King).and_return(true)
        
      # Mock Black King at E8 
      cell_e8 = board_check.find_cell('e8')
      @b_king_e8 = instance_double(King, color: :B, position: cell_e8)
      allow(@b_king_e8).to receive(:is_a?)
      allow(@b_king_e8).to receive(:is_a?).with(King).and_return(true)

      # Mock a Black Rook 
      @rook_moves = { top:[], right:[], bot:[], left:[] }
      @b_rook = instance_double(Rook, class: Rook,
        moves: @rook_moves, color: :B)
      allow(@b_rook).to receive(:is_a?)
      allow(@b_rook).to receive(:is_a?).with(Pawn).and_return(false)

      # Living Pieces - Black Rook E7
      living_pieces = { W:[@w_king_e2], B:[@b_rook] }
      board_check.instance_variable_set(:@living_pieces, living_pieces)
    end

    context "if the King is in check" do
      before do
        # Move the Black Rook to E7 ====> White King at E2
        cell_e7 = board_check.find_cell('e7')
        allow(@b_rook).to receive(:position).and_return(cell_e7)
      end

      it 'returns true' do
        expect(board_check.king_in_check?(:W)).to be true
      end
    end

    context "if the King is not in check" do
      before do 
        # Move the Black Rook to D7 =========> (no King)
        cell_d7 = board_check.find_cell('d7')
        allow(@b_rook).to receive(:position).and_return(cell_d7)
      end

      it 'returns false if the King is not in check' do
        expect(board_check.king_in_check?(:W)).to be false
      end
    end
  end

  # Find King Cell - Given a Color, find+return that Color's King's Cell
  describe '#find_king_cell' do
    subject(:board_find_king) { described_class.new }
    before do
      # White King at E2 - #is_a?(King)
      @cell_e2 = board_find_king.find_cell('e2')
      @w_king = instance_double(King, position: @cell_e2, color: :W)
      allow(@w_king).to receive(:is_a?).with(King).and_return(true)
      # White Rook - Verify it only finds the King Piece
      @w_rook = instance_double(Rook, is_a?: false)
      # Black King at E8
      @cell_e8 = board_find_king.find_cell('e8')
      @b_king = instance_double(King, position: @cell_e8, color: :B)
      allow(@b_king).to receive(:is_a?).with(King).and_return(true)

      # Set Living Pieces
      @living_pieces = { W: [@w_rook, @w_king], B: [@b_king] }
      board_find_king.instance_variable_set(:@living_pieces, @living_pieces)
    end

    context 'when :W (White) is the given color' do
      it "returns the White King's cell" do
        expect(board_find_king.find_king_cell(:W)).to eq(@cell_e2)
      end
    end

    context 'when :B (Black) is the given color' do
      it "returns the Black King's cell" do
        expect(board_find_king.find_king_cell(:B)).to eq(@cell_e8)
      end
    end

  end

  # Kill Piece - Kill the given Piece and remove it from Board@living_pieces
  describe '#kill_piece' do
    subject(:board_kill) { described_class.new }
    before do
      # Place a White Piece on A1 and a Black Piece on A2 
      @w_a1_piece = instance_double(Piece, 'w_a1', color: :W, killed: false)
      allow(@w_a1_piece).to receive(:is_killed)
      #@cell_a1 = board_kill.find_cell('a1')
      #allow(@cell_a1).to receive_messages(empty?: false, piece: @w_a1_piece)

      @b_a2_piece = instance_double(Piece, 'b_a2', color: :B, killed: false)
      allow(@b_a2_piece).to receive(:is_killed)
      # Create the Living Pieces Hash (with just 2 pieces on the board)
      @living_pieces = { W: [@w_a1_piece], B: [@b_a2_piece] }
      board_kill.instance_variable_set(:@living_pieces, @living_pieces)
    end

    it 'sends #is_killed to the given piece' do
      expect(@w_a1_piece).to receive(:is_killed)
      board_kill.kill_piece(@w_a1_piece)
    end
    
    it 'deletes the killed piece from @living_pieces' do
      after_kill = { W: [], B: [@b_a2_piece] }
      expect { board_kill.kill_piece(@w_a1_piece) }.to change { board_kill.living_pieces }.to(after_kill) 
    end

    it 'returns the killed piece after deletion' do
      expect(board_kill.kill_piece(@b_a2_piece)).to eq(@b_a2_piece)
    end
  end

  # Undo Last Move - Remove the last Move from Move@@stack, then call 
  # #undo on that Move object - Will revert the changes made by that Move
  # Also #revive the killed Piece (if any) and add it back to @living_pieces
  describe '#undo_last_move' do
    subject(:board_undo) { described_class.new }
    before do
      # Mock the killed Piece
      @killed_piece = instance_double(Piece, killed: true, color: :W)
      allow(@killed_piece).to receive(:is_revived)
      # Set Board's Living Pieces
      @living_pieces = { W:[], B:[] }
      board_undo.instance_variable_set(:@living_pieces, @living_pieces)
      # Mock the last Move Object
      @last_move = instance_double(Move, killed: nil)
      allow(@last_move).to receive(:undo)
      # Mock the Move Class
      @move = class_double(Move).as_stubbed_const
      allow(@move).to receive(:pop).and_return(@last_move)
    end
    
    it "asks the Move class to ::pop the last move from its @@stack" do
      expect(@move).to receive(:pop)
      board_undo.undo_last_move
    end

    it "asks the popped Move object to #undo the effects of its move" do
      expect(@last_move).to receive(:undo)
      board_undo.undo_last_move
    end

    context "if there was a Killed Piece" do
      before do
        allow(@last_move).to receive(:killed).and_return(@killed_piece)
      end
      it 'calls Board#revive_piece to revive the Piece' do
        expect(board_undo).to receive(:revive_piece).with(@killed_piece)
        board_undo.undo_last_move
      end
    end
  end

  # Revive Piece - Revive the given Piece and add it back to @living_pieces
  describe '#revive_piece' do
    subject(:board_revive) { described_class.new }
    before do
      @w_piece = instance_double(Piece, color: :W)
      allow(@w_piece).to receive(:is_revived)

      @living_pieces = { W:[], B:[] }
      board_revive.instance_variable_set(:@living_pieces, @living_pieces)
    end

    it 'sends #is_revived to the Piece' do
      expect(@w_piece).to receive(:is_revived)
      board_revive.revive_piece(@w_piece)
    end

    it 'adds the Piece to @living_pieces' do
      updated_living_pieces = { W:[@w_piece], B:[] }
      expect { board_revive.revive_piece(@w_piece) }.to change { board_revive.living_pieces }.to(updated_living_pieces)
    end
  end
end