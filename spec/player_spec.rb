# frozen_string_literal: true
require './lib/player'

describe Player do
  let(:player_one) { described_class.new('Lei', 'W') }
  let(:player_two) { described_class.new('Hugo', 'B') }

  describe '::list' do
    it 'returns an array of all Player objects' do
      expect(Player.list).to eq([player_one, player_two])
    end
  end

  describe '#white?' do
    it "returns true if the Player's @color is 'W'" do
      expect(player_one.white?).to be true
    end

    it "returns false if the Player's @color is not 'W'" do
      expect(player_two.white?).to be false
    end
  end
end