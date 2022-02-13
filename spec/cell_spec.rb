# frozen_string_literal: true
require './lib/cell'
require 'pry'

describe Cell do
  before do
    @cell_a1 = described_class.new('a', 1)
    @cell_a2 = described_class.new('a', 2)
    @cell_b1 = described_class.new('b', 1)
    @cell_b2 = described_class.new('b', 2)
  end

  after(:each) do
    Cell.clear_list
  end

  describe '::list' do
    it 'returns an array of all created Cell objects' do
      expect(described_class.list).to eq([@cell_a1, @cell_a2, @cell_b1, @cell_b2])
    end
  end

  describe '::clear_list' do
    it 'clears @@list' do
      described_class.new('a', 1)
      expect{ described_class.clear_list }.to change{ described_class.list }.to([])
    end
  end

  
end