# frozen_string_literal: true
Dir.glob('./lib/*.rb').each { |file| require file unless file.include?('main') }
Dir.glob(('./lib/pieces/*.rb'), &method(:require))

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

  describe '#set_current_player' do
    subject(:game_current_player) { described_class.new }
    before do
      @player = class_double(Player).as_stubbed_const
    end

    it 'asks Player class to ::find the Player of the given color' do
      expect(@player).to receive(:find)
      game_current_player.set_current_player(:W)
    end
  end

  describe '#select_color' do
    subject(:game_color) { described_class.new }
    let(:name) { 'Lei' }

    context "when given a valid input (either 'B' or 'W')" do
      it 'returns the given input' do
        allow(game_color).to receive(:gets).and_return('W')
        expect(game_color.select_color(name)).to eq(:W)
      end
    end

    context "when given a lowercase of a valid input" do
      it 'returns the input capitalized' do
        allow(game_color).to receive(:gets).and_return('b')
        expect(game_color.select_color(name)).to eq(:B)
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
        expect(game_color.select_color(name)).to eq(:W)
      end
    end
  end

  describe '#game_loop' do
    
  end

  # Collect the current player's input and verify it
  # If input is valid, set @board's @active_piece to the Piece on the cell
  # Otherwise, print a warning and recurse
  describe '#select_active_piece' do
    before do
      
    end

    context "when the current player enters a valid set of coordinates" do
      it 'asks @board to find the cell corresponding to the input' do
        
      end

      it "sets @board's @active_piece to the Piece on that cell" do
        
      end
    end

    context "when the current player enters an invalid input" do
      it 'calls #to_s on the returned Warning object' do
        
      end

      it "#puts the returned string from Warning object's #to_s method" do
        
      end
    end
  end

  # Verify Input - If the input is not valid (see below), return a Warning object
  # If the input is valid, return the input
  describe '#verify_piece_input' do
    before do
      
    end

    context "when the input is valid" do
      it "returns the input (string)" do
        
      end
    end

    context "when the input is invalid" do
      context "when the input format is not valid" do
        it 'returns an InvalidInputFormat object' do
          
        end
      end

      context "when the input coordinates correspond to an invalid cell" do
        # Cell does not exist, Cell has no Piece, or Cell has an Enemy Piece on it
        it 'returns an InvalidInputCell object' do
          
        end
      end

      context "when the input coordinates correspond to an invalid piece" do
        # Piece has no legal moves
        it 'returns an InvalidInputPiece object' do
          
        end 
      end
    end
  end
end