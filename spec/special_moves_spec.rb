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

    it "passes the last Move's @piece (the Pawn) to #kill_piece" do
      
    end

    it "passes a Hash of the new Piece's details to #place_pieces" do
      
    end
  end

  # Return a Warning object if invalid; if valid, return the input
  describe '#verify_promotion_input' do
    context 'when the input is valid' do
      it 'returns the input (string)' do
        
      end
    end
    
    context 'when the input is invalid' do
      it 'returns an InvalidPromotionInput object' do
        
      end
    end
  end

  # Promotion Input is Valid if Input matches one of the keys of PROMOTION_TYPES
  describe '#promotion_input_valid?' do
    subject(:board_promote_valid) { Board.new }
    
    context 'when the given input matches one of the keys of PROMOTION_types' do
      it 'returns true' do
        
      end
    end

    context 'when the given input does not match one of the above keys' do
      it 'returns false' do
        
      end
    end
  end
end
