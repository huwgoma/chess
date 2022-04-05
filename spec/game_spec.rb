# frozen_string_literal: true

require './lib/game'
require './lib/game_text'
require './lib/board'
require './lib/cell'
require './lib/player'
require './lib/warnings'

require 'pry'

describe Game do
  before do
    #allow(STDOUT).to receive(:write)
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
    subject(:game_select_piece) { described_class.new(@board) }
    before do
      @board = instance_double(Board)
      @cell = instance_double(Cell)
      @piece = instance_double(Piece)

      allow(game_select_piece).to receive(:puts)
      
      @player_1 = instance_double(Player, name: 'Lei', color: :W)
      game_select_piece.instance_variable_set(:@current_player, @player_1)
    end

    context "when the current player enters a valid set of coordinates" do
      before do
        allow(@board).to receive_messages(find_cell: @cell, generate_legal_moves: nil, set_active_piece: nil)
        allow(@cell).to receive_messages(has_ally?: true, piece: @piece)
        allow(@piece).to receive_messages(has_moves?: true)

        allow(game_select_piece).to receive(:gets).and_return('d2')
      end

      it 'asks @board to find the cell corresponding to the input' do
        # find_cell called twice in verify_piece_input
        expect(@board).to receive(:find_cell).exactly(3).times
        game_select_piece.select_active_piece
      end

      it "sets @board's @active_piece to the Piece on that cell" do
        expect(@board).to receive(:set_active_piece).with(@piece)
        game_select_piece.select_active_piece
      end
    end

    context "when an invalid input is given once, followed by a valid input" do
      before do
        @warning = instance_double(InvalidInputFormat, is_a?: true)
        allow(@warning).to receive(:is_a?).with(InputWarning).and_return(true)
        @string = "Invalid input! Please enter a valid set of alphanumeric coordinates (eg. d2)"
        allow(@warning).to receive(:to_s).and_return(@string)

        @invalid_input_format = class_double(InvalidInputFormat, new: @warning).as_stubbed_const
      
        allow(game_select_piece).to receive(:gets).and_return('d22', 'd2')
        # Second, valid loop
        allow(@board).to receive_messages(find_cell: @cell, generate_legal_moves: nil, set_active_piece: nil)
        allow(@cell).to receive_messages(has_ally?: true, piece: @piece)
        allow(@piece).to receive_messages(has_moves?: true)
      end

      it 'calls #to_s on the returned Warning object' do
        expect(@warning).to receive(:to_s).once
        game_select_piece.select_active_piece
      end

      it "#puts the returned string from Warning object's #to_s method" do
        expect(game_select_piece).to receive(:puts).with(@string)
        game_select_piece.select_active_piece
      end
    end
  end

  # Verify Input - If the input is not valid (see below), return a Warning object
  # If the input is valid, return the input
  describe '#verify_piece_input' do
    subject(:game_verify_piece) { described_class.new(@board) }
    before do
      @board = instance_double(Board)
      allow(@board).to receive(:generate_legal_moves)
      @cell = instance_double(Cell)
      @piece = instance_double(Piece)
    end

    context "when the input is valid" do
      before do
        allow(@board).to receive(:find_cell).and_return(@cell)
        allow(@cell).to receive(:has_ally?).and_return(true)
        allow(@cell).to receive(:piece).and_return(@piece)
        allow(@piece).to receive(:has_moves?).and_return(true)
      end

      it "returns the input (string)" do
        input = 'd2'
        expect(game_verify_piece.verify_piece_input(input)).to eq(input)
      end
    end

    context "when the input is invalid" do
      # Invalid = Not a 2-digit alphanumeric coordinate
      context "when the input format is not valid" do
        before do
          @warning = instance_double(InvalidInputFormat)
          @invalid_input_format = class_double(InvalidInputFormat, new: @warning).as_stubbed_const
        end

        it 'sends #new to InvalidInputFormat' do
          input = 'd22'
          expect(@invalid_input_format).to receive(:new)
          game_verify_piece.verify_piece_input(input)
        end

        it 'returns the InvalidInputFormat object' do
          input = 'd22'
          expect(game_verify_piece.verify_piece_input(input)).to eq(@warning)
        end
      end

      # Invalid = Cell does not exist, Cell has no Piece, or Cell has an Enemy Piece on it
      context "when the input coordinates correspond to an invalid cell" do
        before do
          @warning = instance_double(InvalidInputCell)
          @invalid_input_cell = class_double(InvalidInputCell, new: @warning).as_stubbed_const
          # Cell is nil
          allow(@board).to receive(:find_cell).and_return(nil)
        end
        
        it 'sends #new to InvalidInputCell' do
          input = 'a9'
          expect(@invalid_input_cell).to receive(:new)
          game_verify_piece.verify_piece_input(input)
        end

        it 'returns the InvalidInputCell object' do
          input = 'a9'
          expect(game_verify_piece.verify_piece_input(input)).to eq(@warning)
        end
      end

      # Invalid = Piece has no legal moves
      context "when the input coordinates correspond to an invalid piece" do
        before do
          allow(@board).to receive(:find_cell).and_return(@cell)
          allow(@cell).to receive_messages(has_ally?: true, piece: @piece)
          
          allow(@piece).to receive(:has_moves?).and_return(false)
          @warning = instance_double(InvalidInputPiece)
          @invalid_input_piece = class_double(InvalidInputPiece, new: @warning).as_stubbed_const
        end

        it 'sends #new to InvalidInputPiece' do
          input = 'd1'
          expect(@invalid_input_piece).to receive(:new)
          game_verify_piece.verify_piece_input(input)
        end 

        it 'returns the InvalidInputPiece object' do
          input = 'd1'
          expect(game_verify_piece.verify_piece_input(input)).to eq(@warning)
        end
      end
    end
  end

  # Valid: 2 Characters, Alpha-Numeric
  describe '#input_format_valid?' do
    subject(:game_input_format) { described_class.new }

    context "when the input format is a valid 2 digit coordinate" do
      it 'returns true' do
        input = 'a5'
        expect(game_input_format.input_format_valid?(input)).to be true
      end
    end

    context "when the input format is invalid" do
      it 'returns false' do
        input = '5qq'
        expect(game_input_format.input_format_valid?(input)).to be false
      end
    end
  end

  # Valid: Cell exists and has one of the current player's Pieces on it
  describe '#input_cell_valid?' do
    subject(:game_input_cell) { described_class.new(@board, :W) }

    before do
      @board = instance_double(Board)
      @cell = instance_double(Cell)
    end

    context "when the input is valid" do
      before do
        allow(@board).to receive(:find_cell).and_return(@cell)
        allow(@cell).to receive(:has_ally?).with(:W).and_return(true)
      end
      it 'returns true' do
        input = 'd2'
        expect(game_input_cell.input_cell_valid?(input)).to be true
      end
    end

    context "when the input is invalid" do
      context "when the input does not corresponding to an existing cell" do
        before do
          allow(@board).to receive(:find_cell).and_return(nil)
        end
        it 'returns false' do
          input = 'a9'
          expect(game_input_cell.input_cell_valid?(input)).to be false
        end
      end
      
      context "when the input corresponds to a Cell that does not have an ally piece on it" do
        before do
          allow(@board).to receive(:find_cell).and_return(@cell)
          allow(@cell).to receive(:has_ally?).with(:W).and_return(false)
        end
        it 'returns false' do
          input = 'd7'
          expect(game_input_cell.input_cell_valid?(input)).to be false
        end
      end
    end
  end

  # Valid: Input Piece has at least one legal move
  describe '#input_piece_valid?' do
    subject(:game_input_piece) { described_class.new(@board) }
    before do
      @piece = instance_double(Piece)
      @cell = instance_double(Cell, piece: @piece)
      @board = instance_double(Board, find_cell: @cell)
      allow(@board).to receive(:generate_legal_moves)
    end

    context "when the input Piece has at least one legal move" do
      before do
        allow(@piece).to receive(:has_moves?).and_return(true)
      end
      it 'returns true' do
        input = 'd2'
        expect(game_input_piece.input_piece_valid?(input)).to be true
      end
    end

    context "when the input Piece has no legal moves" do
      before do
        allow(@piece).to receive(:has_moves?).and_return(false)
      end
      it 'returns false' do
        input = 'd1'
        expect(game_input_piece.input_piece_valid?(input)).to be false
      end
    end
  end
end