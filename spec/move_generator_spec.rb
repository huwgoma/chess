# frozen_string_literal: true
Dir.glob('./lib/*.rb').each { |file| require file unless file.include?('main') }
Dir.glob(('./lib/pieces/*.rb'), &method(:require))

RSpec.configure do
  include MoveGenerator
end

describe MoveGenerator do
  before do
    # Create a Board of Instance Doubles for Cells
    @cell_doubles = []
    8.times do | x |
      column = (x + 97).chr
      8.times do | y |
        row = (y + 1)
        @cell_doubles << instance_double(Cell, 
          column: column, row: row, coords: "#{column+row.to_s}",
          piece: nil, empty?: true, has_enemy?: false, has_ally?: false,
          update_piece: nil)
      end
    end

    # Set each Board (subject)'s @cells to @cell_doubles
    subject.instance_variable_set(:@cells, @cell_doubles)
  end
  # Generate Moves - Given a Piece, generate its possible moves
  # - Does not account for the King's safety
  describe '#generate_moves' do
    subject(:board_moves) { Board.new }

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
        
        # Pawn Class Double
        @pawn = class_double(Pawn).as_stubbed_const
        allow(@pawn).to receive(:===).with(@w_pawn_d2).and_return(true)
        allow(@pawn).to receive(:===).with(@w_pawn_d4).and_return(true)
        allow(@pawn).to receive(:===).with(@b_pawn_d7).and_return(true)
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

        # Rook Class Double
        rook = class_double(Rook).as_stubbed_const
        allow(rook).to receive(:===).with(@w_rook_b4).and_return(true)
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

  # Verify Moves - Given a Piece and a @moves Hash, verify each move by 
  # checking whether the piece can be moved without putting the ally King in check 
  describe '#verify_moves' do
    subject(:board_verify) { Board.new }
    before do
      # Mock a White Pawn at E2
      @cell_e2 = board_verify.find_cell('e2')
      pawn_moves = { forward: [], initial: [], forward_left: [], forward_right: [] }
      @w_pawn = instance_double(Pawn, 'wpawne2', class: Pawn, 
        moves: pawn_moves, initial: true, update_position: nil,
        position: @cell_e2, color: :W, forward: 1)
      allow(@w_pawn).to receive(:is_a?)
      allow(@w_pawn).to receive(:is_a?).with(Pawn).and_return(true)
      allow(@cell_e2).to receive(:piece).and_return(@w_pawn)

      # Pawn Class Double
      pawn = class_double(Pawn).as_stubbed_const
      allow(pawn).to receive(:===)
      allow(pawn).to receive(:===).with(@w_pawn).and_return(true)

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

      # Clone Board
      @clone_board = Board.new 
      @clone_board.instance_variable_set(:@cells, @cell_doubles)
      @clone_board.instance_variable_set(:@living_pieces, living_pieces)
      #allow(@clone_board).to receive(:find_king_cell).with(:B).and_return(@cell_b8, @cell_b7, @cell_a7)

      marshal = class_double(Marshal).as_stubbed_const
      allow(marshal).to receive(:dump)
      allow(marshal).to receive(:load).and_return(@clone_board)
    end

    # Verify Moves - Test Cases
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

    # Imminent threat - When the King is 1 move away from being in Check;
    # only being protected by the moving Piece
    context "when the King is under imminent threat" do
      before do
        # Move Rook 1 to E5
        cell_e5 = board_verify.find_cell('e5')
        allow(@b_rook_1).to receive(:position).and_return(cell_e5)

        # Place Enemy Pawn on F3
        allow(@cell_f3).to receive(:has_enemy?).and_return(true)
        enemy_pawn = instance_double(Pawn, 'bpawnf3', color: :B, position: @cell_f3)
        allow(enemy_pawn).to receive_messages(is_killed: nil, is_revived: nil)
        allow(@cell_f3).to receive(:piece).and_return(enemy_pawn)
        
        # Pawn Moves
        board_verify.generate_moves(@w_pawn)
        
        # Rook Moves to each Cell; empty? -> enemy? -> piece?
        allow(@cell_e4).to receive(:empty?).and_return(true, false, true)
        allow(@cell_e4).to receive(:has_enemy?).with(:B).and_return(true)
        allow(@cell_e4).to receive(:piece).and_return(nil, nil, @w_pawn, nil)

        allow(@cell_e3).to receive(:empty?).and_return(false, true)
        allow(@cell_e3).to receive(:has_enemy?).with(:B).and_return(true)
        allow(@cell_e3).to receive(:piece).and_return(nil, @w_pawn, nil)

        allow(@cell_e2).to receive(:empty?).and_return(true)
        allow(@cell_e2).to receive(:piece).and_return(@w_pawn, nil)
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
          allow(@cell_e3).to receive(:piece).and_return(nil, @w_pawn, nil)
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
          allow(@cell_e2).to receive(:piece).and_return(@w_pawn, nil)
          allow(cell_f2).to receive_messages(empty?: false, has_enemy?: true)      
        end
        it 'does not allow the Piece to move' do
          pawn_moves = { forward: [], initial: [], forward_left: [], forward_right: [] }
          expect(board_verify.verify_moves(@w_pawn)).to eq(pawn_moves)
        end
      end
    end
  end

  # Given a Piece's possible end Cell, decide whether to keep it or not - 
  # Is the Cell a valid Cell for the Piece to move to? (empty or has enemy)
  describe '#keep_normal_move?' do
    subject(:board_keep_normal) { Board.new }
    before do
      @piece = instance_double(Piece, color: :W)
    end
    it 'returns true if the given cell is empty' do
      empty_cell = instance_double(Cell, empty?: true)
      expect(board_keep_normal.keep_normal_move?(empty_cell, @piece)).to be true
    end

    it 'returns true if the given cell has an enemy piece on it' do
      enemy_cell = instance_double(Cell, empty?: false, has_enemy?: true)
      expect(board_keep_normal.keep_normal_move?(enemy_cell, @piece)).to be true
    end

    it 'returns false if the given cell has an ally piece on it' do
      ally_cell = instance_double(Cell, empty?: false, has_enemy?: false)
      expect(board_keep_normal.keep_normal_move?(ally_cell, @piece)).to be false
    end
  end

  # Pawns and Kings have special movement rules:
  # Keep Pawn Move?
  describe '#keep_pawn_move?' do
    subject (:board_keep_pawn) { Board.new }
    before do
      @pawn = instance_double(Pawn, color: :W, forward: 1)
    end

    context "when the given direction is :forward" do
      before do
        @direction = :forward
      end
      it 'returns true if the given cell is empty' do
        cell = instance_double(Cell, empty?: true)
        expect(board_keep_pawn.keep_pawn_move?(cell, @direction, @pawn)).to be true
      end

      it 'returns false if the given cell is not empty' do
        cell = instance_double(Cell, empty?: false)
        expect(board_keep_pawn.keep_pawn_move?(cell, @direction, @pawn)).to be false
      end
    end

    context "when the given direction is :initial" do
      before do
        @direction = :initial
        @initial_cell = board_keep_pawn.find_cell('a4')
        @forward_cell = board_keep_pawn.find_cell('a3')
      end
      
      # Initial only returns true under the following circumstances:
      # The pawn has not moved (@initial = true)
      # The initial cell (+2) and forward cell (+1) are both unoccupied
      it 'returns true if the Pawn has not moved, the forward cell is empty, AND the given cell is empty' do
        allow(@pawn).to receive(:initial).and_return(true)
        expect(board_keep_pawn.keep_pawn_move?(@initial_cell, @direction, @pawn)).to be true
      end

      it 'returns false otherwise' do
        allow(@pawn).to receive(:initial).and_return(false)
        expect(board_keep_pawn.keep_pawn_move?(@initial_cell, @direction, @pawn)).to be false
      end
    end

    context "when the given direction is :forward left/right" do
      before do
        @direction = :forward_left
      end

      it 'returns true if the Cell has an enemy on it' do
        enemy_cell = instance_double(Cell, has_enemy?: true)
        expect(board_keep_pawn.keep_pawn_move?(enemy_cell, @direction, @pawn)).to be true
      end

      it 'returns false if the Cell is empty or has an ally on it' do
        cell = instance_double(Cell, has_enemy?: false)
        expect(board_keep_pawn.keep_pawn_move?(cell, @direction, @pawn)).to be false
      end
    end
  end

  # Keep King Move - If the move direction is castling, check if castling_possible?;
  # otherwise, run the default keep_piece_move? check
  describe '#keep_king_move?' do
    subject(:board_keep_king) { Board.new }
    before do
      @king = instance_double(King, color: :W)
    end
    context 'when the given direction is NOT castle' do
      before do
        @dir = :top
      end

      it 'returns true if the given cell is empty' do
        empty_cell = instance_double(Cell, empty?: true)
        expect(board_keep_king.keep_king_move?(empty_cell, @dir, @king)).to be true
      end

      it 'returns true if the given cell has an enemy piece on it' do
        enemy_cell = instance_double(Cell, empty?: false, has_enemy?: true)
        expect(board_keep_king.keep_king_move?(enemy_cell, @dir, @king)).to be true
      end

      it 'returns false if the given cell has an ally piece on it' do
        ally_cell = instance_double(Cell, empty?: false, has_enemy?: false)
        expect(board_keep_king.keep_king_move?(ally_cell, @dir, @king)).to be false
      end
    end
  end
end