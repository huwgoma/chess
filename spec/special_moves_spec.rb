# frozen_string_literal: true
Dir.glob('./lib/*.rb').each { |file| require file unless file.include?('main') }
Dir.glob(('./lib/pieces/*.rb'), &method(:require))
require 'pry'

RSpec.configure do
  include SpecialMoves
end

describe SpecialMoves do
  # Board Class Setup
  before do
    # Create a Board of Instance Doubles for Cells
    @cell_doubles = []
    8.times do | x |
      column = (x + 97).chr
      8.times do | y |
        row = (y + 1)
        @cell_doubles << instance_double(Cell, "#{column+row.to_s}", 
          column: column, row: row, 
          piece: nil, empty?: true, has_enemy?: false, has_ally?: false,
          update_piece: nil)
      end
    end

    # Set each Board (subject)'s @cells to @cell_doubles
    subject.instance_variable_set(:@cells, @cell_doubles)
    # Sort @cell_doubles for each Board into column/row Hashes
    @columns = subject.sort_cells(:column)
    @rows = subject.sort_cells(:row)
    # Then set each Board's @columns/@rows to the sorted @cell_double Hashes
    subject.instance_variable_set(:@columns, @columns)
    subject.instance_variable_set(:@rows, @rows)    
  end

  # PawnPromotion
  # Check if Pawn Promotion is possible for the Move that just occurred 
  describe '#promotion_possible?' do
    subject(:board_promote_possible) { Board.new }
    before do
      @cell_d8 = board_promote_possible.find_cell('d8')
      @cell_d7 = board_promote_possible.find_cell('d7')
      @cell_d1 = board_promote_possible.find_cell('d1')

      @piece = instance_double(Pawn, is_a?: true)
      @last_move = instance_double(Move, piece: @piece)
    end

    context "when the @active_piece is a Pawn" do
      context "when the @active_piece's @position is at the END of the board" do
        context 'when the @active_piece is white' do
          before do
            allow(@piece).to receive_messages(color: :W)
            allow(@last_move).to receive(:end).and_return(@cell_d8)
          end
          it 'returns true' do
            expect(board_promote_possible.promotion_possible?(@last_move)).to be true
          end
        end
        
        context 'when the @active_piece is black' do
          before do
            allow(@piece).to receive_messages(color: :B)
            allow(@last_move).to receive(:end).and_return(@cell_d1)
          end
          it 'also returns true' do
            expect(board_promote_possible.promotion_possible?(@last_move)).to be true
          end
        end
      end

      context "when the  @active_piece's @position is not at the end of the board" do
        before do
          allow(@piece).to receive_messages(color: :W)
          allow(@last_move).to receive(:end).and_return(@cell_d7)
        end
        it 'returns false' do
          expect(board_promote_possible.promotion_possible?(@last_move)).to be false
        end
      end
    end

    context 'when the @active_piece is not a Pawn' do
      before do
        rook = instance_double(Rook, is_a?: true, color: :W)
        allow(rook).to receive(:is_a?).with(Pawn).and_return(false)
        allow(@last_move).to receive(:piece).and_return(rook)
      end
      it 'returns false' do
        expect(board_promote_possible.promotion_possible?(@last_move)).to be false 
      end
    end
  end

  # Promote the Pawn (Kill Pawn, create and place a new Piece)
  describe '#promote_pawn' do
    subject(:board_promote_pawn) { Board.new }

    before do
      # Current Player
      current_player = instance_double(Player, name: 'Lei')
      board_promote_pawn.instance_variable_set(:@current_player, current_player)
      
      # Last Move
      @cell_d8 = board_promote_pawn.find_cell('d8')
      @pawn = instance_double(Pawn, color: :W, is_killed: nil)
      @last_move = instance_double(Move, piece: @pawn, end: @cell_d8)
      
      # Living Pieces
      @living_pieces = { W: [@pawn], B:[] }
      
      allow(board_promote_pawn).to receive(:gets).and_return('Q')
      # Place Pieces - Piece Factory
      @queen_piece = instance_double(Queen, color: :W)
      @queen_factory = instance_double(QueenFactory, place_piece: @queen_piece)
      @piece = class_double(Piece, select_factory: @queen_factory).as_stubbed_const
    end

    it "sends #is_killed to the last Move's @piece (Pawn)" do
      expect(@pawn).to receive(:is_killed)
      expect(board_promote_pawn.promote_pawn(@last_move))
    end

    it "calls #place_pieces with a Hash of the new Piece's details" do
      hash = { 'd8' => { color: :W, type: :Queen } }
      expect(board_promote_pawn).to receive(:place_pieces).with(hash)
      board_promote_pawn.promote_pawn(@last_move)
    end
  end

  # Prompt the current player to enter a piece type to promote to
  # If input is valid, return the corresponding type Symbol
  # If input is invalid, print a warning and recurse
  describe '#choose_promotion_type' do
    subject(:board_choose_promotion) { Board.new }
   
    before do
      current_player = instance_double(Player, name: 'Lei')
      board_choose_promotion.instance_variable_set(:@current_player, current_player)  
    end

    context 'when the user input is valid' do
      before do
        allow(board_choose_promotion).to receive(:gets).and_return('q')
      end
      it 'returns the corresponding piece type Symbol' do
        expect(board_choose_promotion.choose_promotion_type).to eq(:Queen)
      end
    end

    context 'when the user input is invalid twice, then valid' do
      before do
        allow(board_choose_promotion).to receive(:gets).and_return('w', 'w', 'q')
        allow(board_choose_promotion).to receive(:puts)
        @warning_string = "Invalid input! Please enter one of the above options for your Pawn to promote to."
        @warning = instance_double(InvalidPromotionInput, to_s: @warning_string)
        @invalid_promotion_input = class_double(InvalidPromotionInput, new: @warning).as_stubbed_const
        
        input_warning = class_double(InputWarning).as_stubbed_const
        allow(input_warning).to receive(:===)
        allow(input_warning).to receive(:===).with(@warning).and_return(true)
      end

      it 'calls #to_s on the returned Warning object' do
        expect(@warning).to receive(:to_s).twice
        board_choose_promotion.choose_promotion_type
      end

      it "#puts the returned string from the Warning object's #to_s method" do
        expect(board_choose_promotion).to receive(:puts).with(@warning_string)
        board_choose_promotion.choose_promotion_type
      end
    end
  end

  # Return a Warning object if invalid; if valid, return the input
  describe '#verify_promotion_input' do
    subject(:board_verify_promotion) { Board.new }

    context 'when the input is valid' do
      it 'returns the input, capitalized' do
        input = 'q'
        expect(verify_promotion_input(input)).to eq('Q')
      end
    end
    
    context 'when the input is invalid' do
      before do
        @warning = instance_double(InvalidPromotionInput)
        @invalid_promotion_input = class_double(InvalidPromotionInput, new: @warning).as_stubbed_const
      end
      it 'returns an InvalidPromotionInput object' do
        input = 'k'
        expect(verify_promotion_input(input)).to eq(@warning)
      end
    end
  end

  # Promotion Input is Valid if Input matches one of the keys of PROMOTION_OPTIONS
  describe '#promotion_input_valid?' do
    subject(:board_promotion_valid) { Board.new }
    context 'when the given input matches one of the keys of PROMOTION_OPTIONS' do
      it 'returns true' do
        input = 'Q'
        expect(promotion_input_valid?(input)).to be true
      end
    end

    context 'when the given input does not match one of the above keys' do
      it 'returns false' do
        input = 'K'
        expect(promotion_input_valid?(input)).to be false
      end
    end
  end
end
