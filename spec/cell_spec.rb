# frozen_string_literal: true
require './lib/cell'

describe Cell do
  describe '::list' do
    it 'returns an array of all created Cell objects' do
      cell_a1 = described_class.new('a', 1) 
      cell_a2 = described_class.new('a', 2)

      expect(described_class.list).to eq([cell_a1, cell_a2])
    end
  end

  
end