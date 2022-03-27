# frozen_string_literal: true
require './lib/move'
require 'pry'

describe Move do
  before(:each) do
    Move.stack.clear 
  end

  before do
    @move_1 = described_class.new('d2', 'd3', 'WPawn', nil)
    @move_2 = described_class.new('d7', 'd3', 'BRook', 'WPawn')
    @stack = [@move_1, @move_2]
  end
  # Contains an array of Move objects - First in, Last out
  describe '::stack' do
    it "returns Move's @@stack class variable" do
      expect(Move.stack).to eq(@stack)
    end
  end

  # Pop - Removes and returns the last Move object in @@stack
  describe '::pop' do
    it "removes the LAST Move from Move@@stack" do
      stack = [@move_1]
      expect { Move.pop }.to change { Move.stack }.to(stack)
    end

    it 'returns the popped move' do
      expect(Move.pop).to eq(@move_2)
    end
  end
end