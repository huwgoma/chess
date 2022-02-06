# frozen_string_literal: true
require './lib/board'
require './lib/cell'

describe Board do
  describe '#initialize_cells' do
    subject(:board_cells) { described_class.new }

    it 'creates x*y #new Cell objects' do
      cell = class_double(Cell).as_stubbed_const  
      x = 8
      y = 8
      expect(cell).to receive(:new).exactly(x*y).times
      board_cells.initialize_cells(x, y)
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
end