# frozen_string_literal: true
require './lib/board'
require './lib/cell'
require 'pry'

describe Board do
  describe '#setup_board' do
    describe '#initialize_cells' do
      subject(:board_cells) { described_class.new }

      it 'creates 64 #new Cell objects' do
        cell = class_double(Cell).as_stubbed_const  

        expect(cell).to receive(:new).exactly(64).times
        board_cells.initialize_cells
      end

      # It converts 0..7(x) => a..h(columns); 0..7(y) => 1..8(rows),
      # then passes those values to Cell.new to create different Cells
      it 'creates Cells with alphanumeric coordinates(starting from A1)' do
        cell = class_double(Cell).as_stubbed_const
        allow(cell).to receive(:new)

        expect(cell).to receive(:new).with('a', 1)
        board_cells.initialize_cells
      end

      it 'creates Cells with alphanumeric coordinates(ending at H8)' do
        cell = class_double(Cell).as_stubbed_const
        allow(cell).to receive(:new)

        expect(cell).to receive(:new).with('h', 8)
        expect(cell).to_not receive(:new).with('h', 9)
        board_cells.initialize_cells
      end
    end

    describe '#set_columns_rows' do
      subject(:board_columns) { described_class.new }
      subject(:board_rows) { described_class.new }
      
      before do
        @cell = class_double(Cell).as_stubbed_const
        @cell_a1 = instance_double(Cell, 'a1', column: 'a', row: 1)
        @cell_a2 = instance_double(Cell, 'a2', column: 'a', row: 2)
        @cell_b1 = instance_double(Cell, 'b1', column: 'b', row: 1)
        @cell_b2 = instance_double(Cell, 'b2', column: 'b', row: 2)
        @column_hash = { 'a' => [@cell_a1, @cell_a2], 'b' => [@cell_b1, @cell_b2] }
        @row_hash = { 1 => [@cell_a1, @cell_b1], 2 => [@cell_a2, @cell_b2] }
      end

      # @columns = { a: [Cell(a1), Cell(a2), Cell(a3), ... Cell(a8)], b: [Cell(b1)]}
      it 'sets @columns to a Hash of Column-Cells' do
        allow(@cell).to receive(:sort_cells).and_return(@column_hash)
        expect { board_columns.set_columns_rows }.to change { board_columns.columns }.to(@column_hash)
      end

      # @rows = { 1: }
      it 'sets @rows to a Hash of Row-Cells' do
        allow(@cell).to receive(:sort_cells).and_return(@row_hash)
        expect { board_rows.set_columns_rows }.to change { board_rows.rows }.to(@row_hash)
      end
    end

    




    # Looping Script Method
    describe '#initialize_pieces' do
      it "sends ::select_factory to Piece using the current piece's type" do
        
      end
    end


    describe '#find_cell' do
      subject(:board_find) { described_class.new }

      before do
        cell = class_double(Cell).as_stubbed_const
        allow(cell).to receive(:new)

        @cell_a1 = instance_double(Cell, 'a1', column: 'a', row: 1)
        @cell_a2 = instance_double(Cell, 'a2', column: 'a', row: 2)
        @cell_b1 = instance_double(Cell, 'b1', column: 'b', row: 1)
        @cell_b2 = instance_double(Cell, 'b2', column: 'b', row: 2)
        @column_hash = { 'a' => [@cell_a1, @cell_a2], 'b' => [@cell_b1, @cell_b2] }
        @row_hash = { 1 => [@cell_a1, @cell_b1], 2 => [@cell_a2, @cell_b2] }
        allow(cell).to receive(:sort_cells).and_return(@column_hash, @row_hash)
        
        board_find.setup_board
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
  end
end