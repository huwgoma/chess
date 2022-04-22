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
        @king_piece = instance_double(King)
        @rook_piece = instance_double(Rook, color: :W, is_a?: true)
        allow(@rook_piece).to receive(:is_a?).with(Rook).and_return(true)
        rook = class_double(Rook).as_stubbed_const
        allow(rook).to receive(:===).with(@rook_piece).and_return(true)
      end
      
      context 'when the White King is castling Kingside' do
        before do
          king_start = instance_double(Cell, column: 'e', row: 1, coords: 'e1')
          allow(@king_piece).to receive(:position).and_return(king_start)
          king_end = instance_double(Cell, column: 'g', row: 1, coords: 'g1')

          @rook_start = instance_double(Cell, column: 'h', row: 1, coords: 'h1', piece: @rook_piece)
          @rook_end = instance_double(Cell, column: 'f', row: 1, coords: 'f1')

          cells = [king_start, @rook_end, king_end, @rook_start]
          board_move_castle.instance_variable_set(:@cells, cells)

          @dir = :castle_king

          # move_piece
          allow(@rook_start).to receive(:update_piece)
          allow(@rook_piece).to receive(:update_position)
          allow(@rook_end).to receive(:has_enemy?).and_return(false)
          allow(@rook_end).to receive(:update_piece)
        end

        it "calls #move_piece and returns the Move object for the castling Rook's move" do
          rook_move = instance_double(Move, piece: @rook_piece, start: @rook_start, end: @rook_end)
          move = class_double(Move, new: rook_move).as_stubbed_const
          expect(board_move_castle.move_castling_rook(@king_piece, @dir)).to eq(rook_move)
        end

      end

      context 'when the Black King is castling Queenside' do
        before do
          king_start = instance_double(Cell, column: 'e', row: 8, coords: 'e8')
          allow(@king_piece).to receive(:position).and_return(king_start)
          king_end = instance_double(Cell, column: 'c', row: 8, coords: 'c8')

          @rook_start = instance_double(Cell, column: 'a', row: 8, coords: 'a8', piece: @rook_piece)
          @rook_end = instance_double(Cell, column: 'd', row: 8, coords: 'd8')

          cells = [@rook_start, king_end, @rook_end, king_start]
          board_move_castle.instance_variable_set(:@cells, cells)

          @dir = :castle_queen

          # move_piece
          allow(@rook_start).to receive(:update_piece)
          allow(@rook_piece).to receive(:update_position)
          allow(@rook_end).to receive(:has_enemy?).and_return(false)
          allow(@rook_end).to receive(:update_piece)
        end

        it 'correctly calculates Rook move details' do
          rook_move = instance_double(Move, piece: @rook_piece, start: @rook_start, end: @rook_end)
          move = class_double(Move, new: rook_move).as_stubbed_const
          expect(board_move_castle.move_castling_rook(@king_piece, @dir)).to eq(rook_move)
        end
      end
    end

    # Check if Castling is possible (in the given Direction)
    describe '#castling_possible?' do
      subject(:board_castle) { Board.new }
      before do
        @king = instance_double(King, color: :W, moved: false)
        @rook = instance_double(Rook, color: :W, moved: false)
        @dir = :castle_king
      end

      context 'when the King has previously moved' do
        it 'returns false' do
          allow(@king).to receive(:moved).and_return(true)
          expect(board_castle.castling_possible?(@king, @dir)).to be false
        end
      end

      context 'when the castling Rook has previously moved' do
        xit 'returns false' do
          allow(@rook).to receive(:moved).and_return(true)
          expect(board_castle.castling_possible?(@king, @dir)).to be false
        end
      end

      context 'when the lane between the King and the Rook is blocked' do
        it 'returns false' do
          
        end
      end

      context 'if the King is currently in check' do
        it 'returns false' do
          
        end
      end

      # Adjacent Cell - the first Cell that King lands on when moving towards Rook
      context 'if the King would be in check by moving to the adjacent cell' do
        it 'returns false' do
          
        end
      end

      context 'if none of the above conditions are met' do
        it 'returns true' do
          
        end
      end
    end

    # Find and return the castling Rook (ie. the piece on the Rook's cell)
    # If piece is not a Rook or is nil, return nil 
    describe '#find_castling_rook' do
      subject(:board_find_rook) { Board.new }
      before do
        cell_e1 = instance_double(Cell, column: 'e', row: 1, coords: 'e1')
        @king = instance_double(King, position: cell_e1)

        @cell_h1 = instance_double(Cell, column: 'h', row: 1, coords: 'h1')
        @rook = instance_double(Rook, is_a?: true)
        allow(@rook).to receive(:is_a?).with(Rook).and_return(true)

        @cell_e8 = instance_double(Cell, column: 'e', row: 8, coords: 'e8')
        @cell_a8 = instance_double(Cell, column: 'a', row: 8, coords: 'a8')
        # Board Cells
        cells = [cell_e1, @cell_h1, @cell_e8, @cell_a8]
        board_find_rook.instance_variable_set(:@cells, cells)
        
        @dir = :castle_king
      end

      context 'when the Rook is present (on its starting cell)' do
        before do
          allow(@cell_h1).to receive(:piece).and_return(@rook)
        end

        it 'returns the Rook piece' do
          expect(board_find_rook.find_castling_rook(@king, @dir)).to eq(@rook)
        end

        it 'works for Black + Queenside castling too' do
          black_king = instance_double(King, position: @cell_e8)
          allow(@cell_a8).to receive(:piece).and_return(@rook)
          dir = :castle_queen

          expect(board_find_rook.find_castling_rook(black_king, dir)).to eq(@rook)
        end
      end

      context 'when there is no Piece, or a non-Rook Piece, on A1/H1/A8/H8' do
        it 'returns nil (no Piece)' do
          allow(@cell_h1).to receive(:piece).and_return(nil)
          expect(board_find_rook.find_castling_rook(@king, @dir)).to be nil
        end

        it 'returns nil(non-Rook Piece)' do
          not_rook = instance_double(Piece)
          allow(@cell_h1).to receive(:piece).and_return(not_rook)

          expect(board_find_rook.find_castling_rook(@king, @dir)).to be nil
        end
      end
    end

    # Return a Hash of the castling Rook's start and end cells (based on row + direction)
    describe '#find_rook_cells' do
      subject(:board_rook_cells) { Board.new }
      before do
        # White King, Row 1
        @cell_e1 = instance_double(Cell, column: 'e', row: 1, coords: 'e1')
        @w_king = instance_double(King, color: :W, position: @cell_e1)
        # Black King, Row 8
        @cell_e8 = instance_double(Cell, column: 'e', row: 8, coords: 'e8')
        @b_king = instance_double(King, color: :B, position: @cell_e8)

        # White Rook Cells
        @cell_a1 = instance_double(Cell, column: 'a', row: 1, coords: 'a1')
        @cell_d1 = instance_double(Cell, column: 'd', row: 1, coords: 'd1')
        @cell_f1 = instance_double(Cell, column: 'f', row: 1, coords: 'f1')
        @cell_h1 = instance_double(Cell, column: 'h', row: 1, coords: 'h1')
        # Black Rook Cells
        @cell_a8 = instance_double(Cell, column: 'a', row: 8, coords: 'a8')
        @cell_d8 = instance_double(Cell, column: 'd', row: 8, coords: 'd8')
        @cell_f8 = instance_double(Cell, column: 'f', row: 8, coords: 'f8')
        @cell_h8 = instance_double(Cell, column: 'h', row: 8, coords: 'h8')

        cells = [@cell_a1, @cell_d1, @cell_f1, @cell_h1, @cell_a8, @cell_d8, @cell_f8, @cell_h8]
        board_rook_cells.instance_variable_set(:@cells, cells)
      end

      context 'when the King is castling Kingside' do
        before do
          @dir = :castle_king
        end

        context 'when the King is white (row 1)' do
          it 'returns Cells H1 and F1' do
            hash = { start: @cell_h1, end: @cell_f1 }
            expect(board_rook_cells.find_rook_cells(@w_king, @dir)).to eq(hash)
          end
        end

        context 'when the King is black (row 8)' do
          it 'returns Cells H8 and F8' do
            hash = { start: @cell_h8, end: @cell_f8 }
            expect(board_rook_cells.find_rook_cells(@b_king, @dir)).to eq(hash)
          end
        end
      end

      context 'when the King is castling Queenside' do
        before do
          @dir = :castle_queen
        end

        context 'when the King is white (row 1)' do
          it 'returns Cells A1 and D1' do
            hash = { start: @cell_a1, end: @cell_d1 }
            expect(board_rook_cells.find_rook_cells(@w_king, @dir)).to eq(hash)
          end
        end

        context 'when the King is black (row 8)' do
          it 'returns Cells A8 and D8' do
            hash = { start: @cell_a8, end: @cell_d8 }
            expect(board_rook_cells.find_rook_cells(@b_king, @dir)).to eq(hash)
          end
        end
      end
    end
  end
end
