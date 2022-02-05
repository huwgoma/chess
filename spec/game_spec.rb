# frozen_string_literal: true
require './lib/game'
require './lib/player'
require './lib/board'

describe Game do
  before do
    allow(STDOUT).to receive(:write)
  end

  describe '#initialize' do
    
  end

  describe '#create_players' do
    subject(:game_players) { described_class.new }
    
    describe 'it loops twice: ' do
      before do
        allow(game_players).to receive(:gets).and_return('Lei', 'W', 'Hugo')

        @player = class_double(Player).as_stubbed_const
        @player_one = instance_double(Player, white?: true)
        allow(@player).to receive(:new)
        allow(@player).to receive(:list).and_return([@player_one])
      end

      context 'on the first loop' do
        it "calls Game#select_color to set Player 1's @color" do
          expect(game_players).to receive(:select_color).once
          game_players.create_players
        end
      end

      context 'on the second loop' do
        it 'asks Player for its @@list' do
          expect(@player).to receive(:list)
          game_players.create_players
        end

        it 'asks Player 1 (Player@@list[0]) if it is #white?' do
          expect(@player_one).to receive(:white?)
          game_players.create_players
        end
      end

      it 'sends 2 #new messages to Player' do
        expect(@player).to receive(:new).twice
        game_players.create_players
      end
    end
  end

  describe '#select_color' do
    subject(:game_color) { described_class.new }
    let(:name) { 'Lei' }

    context "when given a valid input (either 'B' or 'W')" do
      it 'returns the given input' do
        allow(game_color).to receive(:gets).and_return('W')
        
        expect(game_color.select_color(name)).to eq('W')
      end
    end

    context "when given a lowercase of a valid input" do
      it 'returns the input capitalized' do
        allow(game_color).to receive(:gets).and_return('b')

        expect(game_color.select_color(name)).to eq('B')
      end
    end

    context "when given an invalid input" do
      before do
        allow(game_color).to receive(:gets).and_return('x', 'y', 'W')
        allow(game_color).to receive(:puts)
      end

      it 'prints an invalid input prompt' do
        invalid = 'Please enter [B] for Black or [W] for White!'
        expect(game_color).to receive(:puts).with(invalid).twice
        game_color.select_color(name)
      end

      it 'calls itself until a valid input is given, then returns said input' do
        expect(game_color.select_color(name)).to eq('W')
      end
    end
  end

  # describe '#create_board' do
  #   let(:game_board) { described_class.new }
  #   it 'sends #new to the Board class' do
  #     board = class_double(Board)
  #     allow(board).to_receive(:new)
  #   end
  # end
end