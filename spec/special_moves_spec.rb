# frozen_string_literal: true
Dir.glob('./lib/*.rb').each { |file| require file unless file.include?('main') }
Dir.glob(('./lib/pieces/*.rb'), &method(:require))
require 'pry'

# Game
RSpec.configure do
  include SpecialMoves
end

describe SpecialMoves do
  describe PawnPromotion do
    # PawnPromotion
    before do
      @cell_d8 = instance_double(Cell, 'd8', column: 'd', row: 8)
      @cell_d7 = instance_double(Cell, 'd7', column: 'd', row: 7)
      @cell_d1 = instance_double(Cell, 'd1', column: 'd', row: 1)

      rows = { 1 => [@cell_d1], 7 => [@cell_d7], 8 => [@cell_d8] }
      @board = instance_double(Board, rows: rows)

      @piece = instance_double(Pawn, color: :W, is_a?: true)
      @last_move = instance_double(Move, piece: @piece)
    end
    
    # Check if Pawn Promotion is possible for the Move that just occurred 
    describe '#promotion_possible?' do
      context "when the @active_piece is a Pawn" do
        context "when the @active_piece's @position is at the END of the board" do
          context 'when the @active_piece is white' do
            before do
              allow(@piece).to receive_messages(color: :W)
              allow(@last_move).to receive(:end).and_return(@cell_d8)
            end
            it 'returns true' do
              expect(promotion_possible?(@last_move)).to be true
            end
          end
          
          context 'when the @active_piece is black' do
            before do
              allow(@piece).to receive_messages(color: :B)
              allow(@last_move).to receive(:end).and_return(@cell_d1)
            end
            it 'also returns true' do
              expect(promotion_possible?(@last_move)).to be true
            end
          end
        end

        context "when the  @active_piece's @position is not at the end of the board" do
          before do
            allow(@piece).to receive_messages(color: :W)
            allow(@last_move).to receive(:end).and_return(@cell_d7)
          end
          it 'returns false' do
            expect(promotion_possible?(@last_move)).to be false
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
          expect(promotion_possible?(@last_move)).to be false 
        end
      end
    end

    # Promote the Pawn (Kill Pawn, create and place a new Piece)
    describe '#promote_pawn' do
      subject(:game_promote) { Game.new(@board) }
      before do
        # Last Move
        @last_move = instance_double(Move, piece: @piece, end: @cell_d8)

        # Board
        allow(@board).to receive_messages(kill_piece: @piece, place_pieces: @queen_piece) 

        # Living_pieces
        living_pieces = { W: [@pawn], B:[] }
        @board.instance_variable_set(:@living_pieces, living_pieces)

        # Current_player
        current_player = instance_double(Player, name: 'Lei')
        game_promote.instance_variable_set(:@current_player, current_player)
        
        allow(game_promote).to receive(:puts)
        allow(game_promote).to receive(:gets).and_return('Q')
      end

      it "sends #kill_piece to @board with the Pawn (last move's @piece)" do
        expect(@board).to receive(:kill_piece).with(@piece)
        game_promote.promote_pawn(@last_move)
      end

      it "sends #place_pieces to @board with a Hash of the new Piece's details" do
        hash = { 'd8' => { color: :W, type: :Queen } }
        expect(@board).to receive(:place_pieces).with(hash)
        game_promote.promote_pawn(@last_move)
      end
    end

    # Prompt the current player to enter a piece type to promote to
    # If input is valid, return the corresponding type Symbol
    # If input is invalid, print a warning and recurse
    describe '#choose_promotion_type' do
      subject(:game_choose_promotion) { Game.new(@board) }
    
      before do
        current_player = instance_double(Player, name: 'Lei')
        game_choose_promotion.instance_variable_set(:@current_player, current_player)
        
        allow(game_choose_promotion).to receive(:puts)
      end

      context 'when the user input is valid' do
        before do
          allow(game_choose_promotion).to receive(:gets).and_return('q')
        end
        it 'returns the corresponding piece type Symbol' do
          expect(game_choose_promotion.choose_promotion_type).to eq(:Queen)
        end
      end

      context 'when the user input is invalid twice, then valid' do
        before do
          allow(game_choose_promotion).to receive(:gets).and_return('w', 'w', 'q')
          
          @warning_string = "Invalid input! Please enter one of the above options for your Pawn to promote to."
          @warning = instance_double(InvalidPromotionInput, to_s: @warning_string)
          @invalid_promotion_input = class_double(InvalidPromotionInput, new: @warning).as_stubbed_const
          
          input_warning = class_double(InputWarning).as_stubbed_const
          allow(input_warning).to receive(:===)
          allow(input_warning).to receive(:===).with(@warning).and_return(true)
        end

        it 'calls #to_s on the returned Warning object' do
          expect(@warning).to receive(:to_s).twice
          game_choose_promotion.choose_promotion_type
        end

        it "#puts the returned string from the Warning object's #to_s method" do
          expect(game_choose_promotion).to receive(:puts).with(@warning_string)
          game_choose_promotion.choose_promotion_type
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

  describe Castling do
    # Calculate the move details of the castling Rook, then move the Rook
    describe '#move_castling_rook' do
      subject(:board_move_castle) { Board.new }
      
      before do
        @cell_e1 = instance_double(Cell, column: 'e', row: 1, coords: 'e1')
        @cell_f1 = instance_double(Cell, column: 'f', row: 1, coords: 'f1')
        @cell_g1 = instance_double(Cell, column: 'g', row: 1, coords: 'g1')
        @cell_h1 = instance_double(Cell, column: 'h', row: 1, coords: 'h1')
        @cells = [@cell_e1, @cell_f1, @cell_g1, @cell_h1]

        board_move_castle.instance_variable_set(:@cells, @cells)

        @king = instance_double(King, position: @cell_e1)
        @rook = instance_double(Rook, position: @cell_h1)

        @rook_start = @cell_h1
        allow(@rook_start).to receive(:piece).and_return(@rook)
        @rook_end = @cell_f1
        @dir = :castle_king
      end

      it "calls #move_piece with the castling Rook's move details" do
        expect(board_move_castle).to receive(:move_piece).with(piece: @rook, start_cell: rook_start, end_cell: rook_end, dir: dir)
        board_move_castle.move_castling_rook(@king, dir)
      end

      it 'returns the Rook Move object from #move_piece' do
        rook_move = instance_double(Move, piece: @rook, start: @rook_start, end: @rook_end)
        move = class_double(Move, new: rook_move).as_stubbed_const
        expect(board_move_castle.move_castling_rook(@king, @dir)).to eq(rook_move)
      end
    end
  end
end
