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
  describe '#promotion_possible?' do
    subject(:board_pawn_promotion) { Board.new }
    before do
      @cell_d8 = board_pawn_promotion.find_cell('d8')
      @cell_d7 = board_pawn_promotion.find_cell('d7')
      @cell_d1 = board_pawn_promotion.find_cell('d1')

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
            expect(board_pawn_promotion.promotion_possible?(@last_move)).to be true
          end
        end
        
        context 'when the @active_piece is black' do
          before do
            allow(@piece).to receive_messages(color: :B)
            allow(@last_move).to receive(:end).and_return(@cell_d1)
          end
          it 'also returns true' do
            expect(board_pawn_promotion.promotion_possible?(@last_move)).to be true
          end
        end
      end

      context "when the  @active_piece's @position is not at the end of the board" do
        before do
          allow(@piece).to receive_messages(color: :W)
          allow(@last_move).to receive(:end).and_return(@cell_d7)
        end
        it 'returns false' do
          expect(board_pawn_promotion.promotion_possible?(@last_move)).to be false
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
        expect(board_pawn_promotion.promotion_possible?(@last_move)).to be false 
      end
    end
  end
end
