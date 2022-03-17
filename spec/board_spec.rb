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

  # Generate Valid Moves - Generate and Prune
  # Valid Moves of a Piece - EXCLUDING King safety checks
  describe '#generate_valid_moves' do
    subject(:board_valid_moves) { described_class.new }
    before do
      # Create a Board of Instance Doubles for Cells
      @cell_doubles = []
      8.times do | x |
        column = (x + 97).chr
        8.times do | y |
          row = (y + 1)
          @cell_doubles << instance_double(Cell, "#{column+row.to_s}", column: column, row: row, piece: nil)
        end
      end
      # Set Board's @cells to @cell_doubles Array
      board_valid_moves.instance_variable_set(:@cells, @cell_doubles)

      # Sort Cell Instance Doubles into Hashes sorted by Columns/Rows
      @columns = board_valid_moves.sort_cells(:column)
      @rows = board_valid_moves.sort_cells(:row)
    end

    # given a Piece, it will return a Hash of that Piece's
    # MOVEMENT directions and cells (array) - Fill Piece's @moves
    # cells (array) with Cells the Piece can move to
    describe '#generate_moves' do
      subject(:board_moves) { described_class.new }
      before do
        board_moves.instance_variable_set(:@cells, @cell_doubles)
        board_moves.instance_variable_set(:@columns, @columns)
        board_moves.instance_variable_set(:@rows, @rows)
      end

      # Pawns
      context "for a Piece of the Pawn subclass" do
        before do
          @empty_moves = { forward:[], initial:[], forward_left: [], forward_right: [] }        
        end

        context "for a White Pawn at e2" do
          before do
            @cell_e2 = board_moves.find_cell('e2')
            @pawn = instance_double(Pawn, 'Pawne2', position: @cell_e2, class: Pawn)
            allow(@pawn).to receive(:moves).and_return(@empty_moves)

            @cell_e3 = board_moves.find_cell('e3')
            @cell_e4 = board_moves.find_cell('e4')
            @cell_d3 = board_moves.find_cell('d3')
            @cell_f3 = board_moves.find_cell('f3')

            @pawn_moves = {
              forward:[@cell_e3], initial:[@cell_e4], forward_left: [@cell_d3], forward_right: [@cell_f3]
            }
          end

          it "populates the empty cells array of Pawn@moves with its possible move cells" do
            expect(board_moves.generate_moves(@pawn)).to eq(@pawn_moves)
          end
        end

        context "for a White Pawn at h2 (end of board)" do
          before do
            @cell_h2 = board_moves.find_cell('h2')
            @pawn = instance_double(Pawn, 'Pawnh2', position: @cell_h2, class: Pawn)
            allow(@pawn).to receive(:moves).and_return(@empty_moves)

            @cell_g3 = board_moves.find_cell('g3')
            @cell_h3 = board_moves.find_cell('h3')
            @cell_h4 = board_moves.find_cell('h4')

            @pawn_moves = {
              forward:[@cell_h3], initial:[@cell_h4], forward_left: [@cell_g3]
            }
          end

          it 'properly constrains the possible cells (ie. no out-of-bounds moves)' do
            expect(board_moves.generate_moves(@pawn)).to eq(@pawn_moves)
          end
        end
        
        context "for a Black Pawn at e7" do
          before do
            @cell_e7 = board_moves.find_cell('e7')
            @b_pawn = instance_double(Pawn, position: @cell_e7, forward: -1, class: Pawn)
            allow(@b_pawn).to receive(:is_a?).with(Pawn).and_return(true)
            allow(@b_pawn).to receive(:moves).and_return(@empty_moves)

            @cell_e6 = board_moves.find_cell('e6')
            @cell_e5 = board_moves.find_cell('e5')
            @cell_d6 = board_moves.find_cell('d6')
            @cell_f6 = board_moves.find_cell('f6')
            
            # Relevant subset of Black Pawn's moves - Check that direction 
            # is being accounted for 
            @pawn_moves = {
              forward:[@cell_e6], initial:[@cell_e5], forward_left: [@cell_d6], forward_right: [@cell_f6]
            }
          end
          
          it "takes the Pawn's direction (based on color) into account" do
            expect(board_moves.generate_moves(@b_pawn)).to eq(@pawn_moves)
          end
        end
      end

      context "for Pieces with infinite Movement (eg. Rook)" do
        before do
          @empty_moves = { top:[], right:[], bot: [], left: [] }
          @cell_a5 = board_moves.find_cell('a5')
          @rook = instance_double(Rook, position: @cell_a5, class: Rook)
          allow(@rook).to receive(:moves).and_return(@empty_moves)

          @cell_a6 = board_moves.find_cell('a6')
          @cell_a7 = board_moves.find_cell('a7')
          @cell_a8 = board_moves.find_cell('a8')
          @rook_top_moves = [@cell_a6, @cell_a7, @cell_a8]    
        end

        it "iterates in each direction until it reaches the end of the board" do
          rook_full_moves = board_moves.generate_moves(@rook)
          #binding.pry
          # Expect rook_full_moves[:top] to equal @rook_top_moves
          expect(rook_full_moves[:top]).to eq(@rook_top_moves)
        end
      end
    end

    # Given a Hash of moves, prune the moves based on the position of other Pieces
    # Modifies and returns the Hash of pruned moves
    describe '#prune_moves' do
      subject(:board_prune) { described_class.new }
      before do
        board_prune.instance_variable_set(:@cells, @cell_doubles)
        board_prune.instance_variable_set(:@columns, @columns)
        board_prune.instance_variable_set(:@rows, @rows)
      end

      # Infinite Movement Classes - Rook, Bishop, Queen
      context "for Pieces with infinite Movement (eg. Rook)" do
        before do
          @empty_moves = { top:[], right:[], bot: [], left: [] }
          @cell_a4 = board_prune.find_cell('a4')
          @rook = instance_double(Rook, position: @cell_a4, class: Rook)
          allow(@rook).to receive(:moves).and_return(@empty_moves)
          
          @moves = board_prune.generate_moves(@rook)

          @cell_a5 = board_prune.find_cell('a5')
          @cell_a6 = board_prune.find_cell('a6')
          @cell_a7 = board_prune.find_cell('a7')
          @cell_a8 = board_prune.find_cell('a8')
        end

        context "when it encounters a Cell with an enemy Piece" do
          before do
            @b_pawn = instance_double(Pawn, color: :B) 
            allow(@cell_a6).to receive(:piece).and_return(@b_pawn)
            @pruned_top_moves = [@cell_a5, @cell_a6]
          end
          xit "includes that Cell, but stops iterating any further in that direction" do
            pruned_full_moves = board_prune.prune_moves(@moves)
            
            expect(pruned_full_moves[:top]).to eq(@pruned_top_moves)
          end
        end
      end
    end

  end

  
end