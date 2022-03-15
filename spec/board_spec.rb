# frozen_string_literal: true
require './lib/board'
require './lib/cell'
require './lib/pieces/piece'
require './lib/pieces/pawn'
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


  describe '#generate_valid_moves' do
    subject(:board_valid_moves) { described_class.new }

    # given a Piece, it will return a Hash of that Piece's
    # MOVEMENT directions and cells (array) - Fill Piece's @moves
    # cells (array) with Cells the Piece can move to
    describe '#generate_moves' do
      
      #######
      before do
        # Create a Board of Instance Doubles for Cells
        @cell_doubles = []
        8.times do | x |
          column = (x + 97).chr
          8.times do | y |
            row = (y + 1)
            @cell_doubles << instance_double(Cell, "#{column+row.to_s}", column: column, row: row)
          end
        end
        board_valid_moves.instance_variable_set(:@cells, @cell_doubles)

        # Sort Cell Instance Doubles and set them onto board_valid_moves'
        # @columns/@rows instance variables 
        @columns = board_valid_moves.sort_cells(:column)
        @rows = board_valid_moves.sort_cells(:row)
        board_valid_moves.instance_variable_set(:@columns, @columns)
        board_valid_moves.instance_variable_set(:@rows, @rows)
      end

      #######
      context "for a Piece of the Pawn subclass" do
        before do
          binding.pry
          @cell_e2 = instance_double(Cell, 'e2', column: 'e', row: 2)
          @cell_e3 = instance_double(Cell, 'e3', column: 'e', row: 3)
          @cell_e4 = instance_double(Cell, 'e4', column: 'e', row: 4)
          @cell_d3 = instance_double(Cell, 'd3', column: 'd', row: 3)
          @cell_f3 = instance_double(Cell, 'f3', column: 'f', row: 3) 
          
          @empty_moves = { forward:[], initial:[], forward_left: [], forward_right: [] }        
        end

        context "for a White Pawn at e2" do
          before do
            @pawn = instance_double(Pawn, 'Pawne2', position: @cell_e2, class: Pawn)
            allow(@pawn).to receive(:moves).and_return(@empty_moves)

            # Manually set board's @columns and @rows to cover the Cells we need to test
            # for find_cell to work properly.
            @columns = {
              'd' => [@cell_d3], 'e' => [@cell_e2, @cell_e3, @cell_e4], 'f' => [@cell_f3]
            }
            @rows = {
              2 => [@cell_e2], 3 => [@cell_d3, @cell_e3, @cell_f3], 4 => [@cell_e4]
            }

            board_valid_moves.instance_variable_set(:@columns, @columns)
            board_valid_moves.instance_variable_set(:@rows, @rows)

            @pawn_moves = {
              forward:[@cell_e3], initial:[@cell_e4], forward_left: [@cell_d3], forward_right: [@cell_f3]
            }
          end

          it "populates the empty cells array of Pawn@moves with its possible move cells" do
            expect(board_valid_moves.generate_moves(@pawn)).to eq(@pawn_moves)
          end
        end
        
      end
    end
  end
end