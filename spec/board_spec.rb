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

    @columns = { 'a' => [@cell_a1, @cell_a2], 'b' => [@cell_b1, @cell_b2] }
    @rows = { 1 => [@cell_a1, @cell_b1], 2 => [@cell_a2, @cell_b2] }
  end

  describe '#prepare_board' do
    describe '#initialize_cells' do
      subject(:board_cells) { described_class.new }

      it 'creates 64 #new Cell objects' do
        expect(@cell).to receive(:new).exactly(64).times
        board_cells.initialize_cells
      end

      # It converts 0..7(x) => a..h(columns); 0..7(y) => 1..8(rows),
      # then passes those values to Cell.new to create different Cells
      it 'creates Cells with alphanumeric coordinates(starting from A1)' do
        allow(@cell).to receive(:new)

        expect(@cell).to receive(:new).with('a', 1)
        board_cells.initialize_cells
      end

      it 'creates Cells with alphanumeric coordinates(ending at H8)' do
        allow(@cell).to receive(:new)

        expect(@cell).to receive(:new).with('h', 8)
        expect(@cell).to_not receive(:new).with('h', 9)
        board_cells.initialize_cells
      end
    end

    
    # Looping Script Method
    describe '#place_pieces' do
      subject(:board_pieces) { described_class.new }
      before do
        @piece = class_double(Piece).as_stubbed_const
        @pieces = {
          'a1' => { color: :W, type: :Rook }
          #, 'b1' => { color: :W, type: :Knight }
        }

        board_pieces.instance_variable_set(:@columns, @columns)
        board_pieces.instance_variable_set(:@rows, @rows)

        @rook_factory = instance_double(RookFactory)
        allow(@rook_factory).to receive(:place_piece)
      end
      
      
      it "calls ::select_factory on Piece using the current piece's type" do
        allow(@piece).to receive(:select_factory).and_return(@rook_factory)
        a1_type = :Rook

        expect(@piece).to receive(:select_factory).with(a1_type)
        board_pieces.place_pieces(@pieces)
      end

      it "sends #place_piece to the PieceFactory subclass object" do
        allow(@piece).to receive(:select_factory).and_return(@rook_factory)
        
        expect(@rook_factory).to receive(:place_piece)
        board_pieces.place_pieces(@pieces)
      end
    end
  end
    

  # Query Method
  describe '#find_cell' do
    subject(:board_find) { described_class.new }

    before do
      board_find.instance_variable_set(:@columns, @columns)
      board_find.instance_variable_set(:@rows, @rows)
    end

    context 'when given a valid inbounds alphanumeric coordinate' do
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
      before do
        @cell_e3 = instance_double(Cell, 'e3', column: 'e', row: 3)
        @cell_e4 = instance_double(Cell, 'e4', column: 'e', row: 4)
        @cell_d3 = instance_double(Cell, 'd3', column: 'd', row: 3)
        @cell_f3 = instance_double(Cell, 'f3', column: 'f', row: 3)  
      end

      context "for Pieces of the Pawn Subclass" do
        
      end
      context "for a Piece of the Pawn subclass" do
        # Pawn color WHITE - Forward is +1; BLACK - Forward is -1
        before do
          @pawn_cell = instance_double(Cell, 'e2', column: 'e', row: 2)
          @pawn = instance_double(Pawn, 'Pawne2', position: @pawn_cell, color: :W, class: Pawn)

          @empty_moves = { forward:[], initial:[], forward_left: [], forward_right: [] }
          allow(@pawn).to receive(:moves).and_return(@empty_moves)

        end

        it "populates the empty cells array of Pawn@moves with its possible move cells" do
          allow(board_valid_moves).to receive(:find_cell).and_return(@cell_e3, @cell_e4, @cell_d3, @cell_f3)
          @pawn_moves = {
            forward:[@cell_e3], initial:[@cell_e4], forward_left: [@cell_d3], forward_right: [@cell_f3]
          }

          expect(board_valid_moves.generate_moves(@pawn)).to eq(@pawn_moves)
        end
      end
    end
  end
end