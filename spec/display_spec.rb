# frozen_string_literal: true
require './lib/board'
require './lib/cell'
require './lib/display'

# Board
RSpec.configure do
  include Displayable
end

describe '#print_board' do
  
end

describe '#set_print_order' do
  before do
    @cell_a1 = instance_double(Cell, 'a1', column: 'a', row: 1)
    @cell_a2 = instance_double(Cell, 'a2', column: 'a', row: 2)
    @cell_b1 = instance_double(Cell, 'b1', column: 'b', row: 1)
    @cell_b2 = instance_double(Cell, 'b2', column: 'b', row: 2)

    @rows = { 1 => [@cell_a1, @cell_b1], 2 => [@cell_a2, @cell_b2] }
  end

  it 'returns a new array filled with the values of @rows in reverse order' do
    print_order = [@cell_a2, @cell_b2, @cell_a1, @cell_b1]
    expect(set_print_order).to eq(print_order)
  end
end