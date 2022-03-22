# frozen_string_literal: true
require './lib/board'
require './lib/cell'
require './lib/pieces/piece'
require './lib/pieces/pawn'
require './lib/pieces/rook'
require './lib/pieces/piece_factories'
require 'pry'

describe Board do
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





  # Generate Moves - Given a Piece, generate its possible moves
  # - Does not account for the King's safety
  describe '#generate_moves' do
    subject(:board_moves) { described_class.new }

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
      # Set Board's @cells to @cell_doubles Array
      board_moves.instance_variable_set(:@cells, @cell_doubles)

      # Sort Cell Instance Doubles into Hashes sorted by Columns/Rows
      @columns = board_moves.sort_cells(:column)
      @rows = board_moves.sort_cells(:row)
      board_moves.instance_variable_set(:@columns, @columns)
      board_moves.instance_variable_set(:@rows, @rows)
    end

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
      it 'moves forward 1 cell' do
        moves = { forward: [@cell_d5] }
        expect(board_moves.generate_moves(@w_pawn_d4)).to eq(moves)
      end

      # Initial - Move 2 cells forward (D2->D4)
      it 'moves forward 2 cells' do
        moves = { forward: [@cell_d3], initial: [@cell_d4] }
        expect(board_moves.generate_moves(@w_pawn_d2)).to eq(moves)
      end

      # Forward - Cannot move if cell is occupied (D4->D5 blocked)
      it 'cannot move forward if that cell is blocked' do
        allow(@cell_d5).to receive(:empty?).and_return(false)
        moves = {}
        expect(board_moves.generate_moves(@w_pawn_d4)).to eq(moves)
      end 

      # Initial - Cannot move if the first Forward Cell is blocked 
      # (even if Initial Cell is empty) (D2->D4 blocked by D3 block)
      it 'cannot move forward 2 cells if the first forward cell is blocked' do
        allow(@cell_d3).to receive(:empty?).and_return(false)
        moves = {}
        expect(board_moves.generate_moves(@w_pawn_d2)).to eq(moves)
      end
      # Initial - Cannot move if the Initial Cell is blocked
      # (but CAN move to the Forward Cell if that's empty) (D2->D3->D4 blocked)
      it 'cannot move forward 2 cells if the second cell is blocked' do
        allow(@cell_d4).to receive(:empty?).and_return(false)
        moves = { forward: [@cell_d3] }
        expect(board_moves.generate_moves(@w_pawn_d2)).to eq(moves)
      end

      # Diagonal - Can only move if Diagonal Cell has an enemy Piece on it
      it 'can only move diagonally if that cell has an enemy' do
        # Block Cell D3
        allow(@cell_d3).to receive(:empty?).and_return(false)
        # Place a juicy enemy Piece on Cell C3 (Diagonal Left)
        cell_c3 = board_moves.find_cell('c3')
        allow(cell_c3).to receive(:has_enemy?).and_return(true)

        moves = { forward_left: [cell_c3] }
        expect(board_moves.generate_moves(@w_pawn_d2)).to eq(moves)
      end

      # Direction - Black Pawns move in reverse (Forward = -1)
      it 'moves DOWN the board instead of up if it is Black' do
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
        board_pawn_move.instance_variable_set(:@cells, @cell_doubles)
        board_pawn_move.instance_variable_set(:@columns, @columns)
        board_pawn_move.instance_variable_set(:@rows, @rows)
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
  end

  
  # Generate Valid Moves - Generate and Prune
  # Valid Moves of a Piece - EXCLUDING King safety checks
  # describe '#generate_valid_moves' do
  #   subject(:board_valid_moves) { described_class.new }
  #   before do
  #     # Create a Board of Instance Doubles for Cells
  #     @cell_doubles = []
  #     8.times do | x |
  #       column = (x + 97).chr
  #       8.times do | y |
  #         row = (y + 1)
  #         @cell_doubles << instance_double(Cell, "#{column+row.to_s}", column: column, row: row, piece: nil)
  #       end
  #     end
  #     # Set Board's @cells to @cell_doubles Array
  #     board_valid_moves.instance_variable_set(:@cells, @cell_doubles)

  #     # Sort Cell Instance Doubles into Hashes sorted by Columns/Rows
  #     @columns = board_valid_moves.sort_cells(:column)
  #     @rows = board_valid_moves.sort_cells(:row)
  #   end

  #   # given a Piece, it will return a Hash of that Piece's
  #   # MOVEMENT directions and cells (array) - Fill Piece's @moves
  #   # cells (array) with Cells the Piece can move to
  #   describe '#generate_moves' do
  #     subject(:board_moves) { described_class.new }
  #     before do
  #       board_moves.instance_variable_set(:@cells, @cell_doubles)
  #       board_moves.instance_variable_set(:@columns, @columns)
  #       board_moves.instance_variable_set(:@rows, @rows)
  #     end

  #     # Pawns
  #     context "for a Piece of the Pawn subclass" do
  #       before do
  #         @empty_moves = { forward:[], initial:[], forward_left: [], forward_right: [] }        
  #       end

  #       context "for a White Pawn at e2" do
  #         before do
  #           @cell_e2 = board_moves.find_cell('e2')
  #           @pawn = instance_double(Pawn, 'Pawne2', position: @cell_e2, class: Pawn)
  #           allow(@pawn).to receive(:moves).and_return(@empty_moves)

  #           @cell_e3 = board_moves.find_cell('e3')
  #           @cell_e4 = board_moves.find_cell('e4')
  #           @cell_d3 = board_moves.find_cell('d3')
  #           @cell_f3 = board_moves.find_cell('f3')

  #           @pawn_moves = {
  #             forward:[@cell_e3], initial:[@cell_e4], forward_left: [@cell_d3], forward_right: [@cell_f3]
  #           }
  #         end

  #         xit "populates the empty cells array of Pawn@moves with its possible move cells" do
  #           expect(board_moves.generate_moves(@pawn)).to eq(@pawn_moves)
  #         end
  #       end

  #       context "for a White Pawn at h2 (end of board)" do
  #         before do
  #           @cell_h2 = board_moves.find_cell('h2')
  #           @pawn = instance_double(Pawn, 'Pawnh2', position: @cell_h2, class: Pawn)
  #           allow(@pawn).to receive(:moves).and_return(@empty_moves)

  #           @cell_g3 = board_moves.find_cell('g3')
  #           @cell_h3 = board_moves.find_cell('h3')
  #           @cell_h4 = board_moves.find_cell('h4')

  #           @pawn_moves = {
  #             forward:[@cell_h3], initial:[@cell_h4], forward_left: [@cell_g3]
  #           }
  #         end

  #         xit 'properly constrains the possible cells (ie. no out-of-bounds moves)' do
  #           expect(board_moves.generate_moves(@pawn)).to eq(@pawn_moves)
  #         end
  #       end
        
  #       context "for a Black Pawn at e7" do
  #         before do
  #           @cell_e7 = board_moves.find_cell('e7')
  #           @b_pawn = instance_double(Pawn, position: @cell_e7, forward: -1, class: Pawn)
  #           allow(@b_pawn).to receive(:is_a?).with(Pawn).and_return(true)
  #           allow(@b_pawn).to receive(:moves).and_return(@empty_moves)

  #           @cell_e6 = board_moves.find_cell('e6')
  #           @cell_e5 = board_moves.find_cell('e5')
  #           @cell_d6 = board_moves.find_cell('d6')
  #           @cell_f6 = board_moves.find_cell('f6')
            
  #           # Relevant subset of Black Pawn's moves - Check that direction 
  #           # is being accounted for 
  #           @pawn_moves = {
  #             forward:[@cell_e6], initial:[@cell_e5], forward_left: [@cell_d6], forward_right: [@cell_f6]
  #           }
  #         end
          
  #         xit "takes the Pawn's direction (based on color) into account" do
  #           expect(board_moves.generate_moves(@b_pawn)).to eq(@pawn_moves)
  #         end
  #       end
  #     end

  #     context "for Pieces with infinite Movement (eg. Rook)" do
  #       before do
  #         @empty_moves = { top:[], right:[], bot: [], left: [] }
  #         @cell_a5 = board_moves.find_cell('a5')
  #         @rook = instance_double(Rook, position: @cell_a5, class: Rook)
  #         allow(@rook).to receive(:moves).and_return(@empty_moves)

  #         @cell_a6 = board_moves.find_cell('a6')
  #         @cell_a7 = board_moves.find_cell('a7')
  #         @cell_a8 = board_moves.find_cell('a8')
  #         @rook_top_moves = [@cell_a6, @cell_a7, @cell_a8]    
  #       end

  #       xit "iterates in each direction until it reaches the end of the board" do
  #         rook_full_moves = board_moves.generate_moves(@rook)
  #         #binding.pry
  #         # Expect rook_full_moves[:top] to equal @rook_top_moves
  #         expect(rook_full_moves[:top]).to eq(@rook_top_moves)
  #       end
  #     end
  #   end

  #   # Given a Hash of moves, prune the moves based on the position of other Pieces
  #   # Modifies and returns the Hash of pruned moves
  #   describe '#prune_moves' do
  #     subject(:board_prune) { described_class.new }
  #     before do
  #       board_prune.instance_variable_set(:@cells, @cell_doubles)
  #       board_prune.instance_variable_set(:@columns, @columns)
  #       board_prune.instance_variable_set(:@rows, @rows)
  #     end

  #     # Infinite Movement Classes - Rook, Bishop, Queen
  #     context "for Pieces with infinite Movement (eg. Rook)" do
  #       before do
  #         @empty_moves = { top:[], right:[], bot: [], left: [] }
  #         @cell_a4 = board_prune.find_cell('a4')
  #         @rook = instance_double(Rook, position: @cell_a4, class: Rook, color: :W)
  #         allow(@rook).to receive(:moves).and_return(@empty_moves)
          
  #         @moves = board_prune.generate_moves(@rook)

  #         @cell_a5 = board_prune.find_cell('a5')
          
  #         @cell_a6 = board_prune.find_cell('a6')
  #         @cell_a7 = board_prune.find_cell('a7')
  #         @cell_a8 = board_prune.find_cell('a8')
  #       end

  #       context "when it encounters a Cell with an enemy Piece" do
  #         before do
  #           # Cell A6 has a Black Pawn on it 
  #           @b_pawn = instance_double(Pawn, color: :B) 
  #           allow(@cell_a6).to receive(:piece).and_return(@b_pawn)

  #           @pruned_moves_top = [@cell_a5, @cell_a6]
  #           allow(@cell_a6).to receive(:has_enemy?).and_return(true)
  #         end
          
  #         xit "includes that Cell, but stops iterating any further in that direction" do
  #           pruned_moves_full = board_prune.prune_moves(@rook, @moves)
            
  #           expect(pruned_moves_full[:top]).to eq(@pruned_moves_top)
  #         end
  #       end
  #     end
  #   end

  # end

  
end