# frozen_string_literal: true
require './lib/board'
require './lib/cell'

describe Board do
  describe '#initialize' do
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

    describe '#set_columns' do
      subject(:board_columns) { described_class.new }

      it 'returns a Hash of Column-Cells' do
        # @columns = { a: [Cell(a1), Cell(a2), Cell(a3), ... Cell(a8)], b: [Cell(b1)]}
        cell = class_double(Cell).as_stubbed_const
        allow(cell).to receive(:new)
        cell_a1 = instance_double(Cell, column: 'a', row: 1)
        
        allow(cell).to receive(:list)

        expect(board_columns.set_columns()).to eq(nil)
      end
    end
  end
end