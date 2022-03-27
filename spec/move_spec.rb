# frozen_string_literal: true
require './lib/move'

describe Move do
  describe '::stack' do
    # Contains an array of Move objects - First in, Last out
    it "returns Move's @@stack class variable" do
      move_1 = described_class.new('d2', 'd3', 'WPawn', nil)
      move_2 = described_class.new('d7', 'd3', 'BRook', 'WPawn')
      expect(Move.stack).to eq([move_1, move_2])
    end
  end
end