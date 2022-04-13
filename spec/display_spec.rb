# frozen_string_literal: true
require './lib/board'
require './lib/cell'
require './lib/pieces/piece'
require './lib/pieces/pawn'

# Board Include
RSpec.configure do
  include Displayable
end

# Display/Print the Chess Board
describe '#print_board' do
  before do
    @cell_a1 = instance_double(Cell, 'a1', column: 'a', row: 1)
    @cell_a2 = instance_double(Cell, 'a2', column: 'a', row: 2)
    @cell_b1 = instance_double(Cell, 'b1', column: 'b', row: 1)
    @cell_b2 = instance_double(Cell, 'b2', column: 'b', row: 2)

    @rows = { 1 => [@cell_a1, @cell_b1], 2 => [@cell_a2, @cell_b2] }
  end

  # Rearrange the Cells into the print order (a8->h8, ..., a1->h1)
  describe '#set_print_order' do
    it 'returns a new array filled with the values of @rows in reverse order' do
      print_order = [@cell_a2, @cell_b2, @cell_a1, @cell_b1]
      expect(set_print_order).to eq(print_order)
    end
  end

  # Calculate and return the string for the current cell (Piece or Blank)
  describe '#set_string' do
    context 'for the default Piece icons' do
      it "returns ♟ (Black Pawn) when the cell's @piece is a Black Pawn" do
        pawn_a2 = instance_double(Pawn, class: Pawn, position: @cell_a2, color: :B)
        allow(@cell_a2).to receive(:piece).and_return(pawn_a2)
        piece_selected = false
        expect(set_string(@cell_a2, piece_selected)).to eq('♙')
      end
  
      it "returns ♙.white (White Pawn) when the @piece is a White Pawn" do
        pawn_b2 = instance_double(Pawn, class: Pawn, position: @cell_b2, color: :W)
        allow(@cell_b2).to receive(:piece).and_return(pawn_b2)
        piece_selected = false
        expect(set_string(@cell_b2, piece_selected)).to eq('♟')
      end
    end
  
    # If Piece is nil (Cell empty)
    context "when the Piece is nil" do
      subject(:board_set_string) { Board.new }

      context "when piece_selected is set to true AND the Cell is in @active_piece's @moves" do
        before do
          allow(@cell_a2).to receive(:piece).and_return(nil)
          active_moves = { forward: [@cell_a2], initial: [], forward_left: [], forward_right: [@cell_b2] }
          active_piece = instance_double(Pawn, position: @cell_a1, moves: active_moves)
          board_set_string.instance_variable_set(:@active_piece, active_piece)
        end

        it 'returns ● to symbolize a potential move' do
          piece_selected = true
          expect(board_set_string.set_string(@cell_a2, piece_selected)).to eq('●')
        end
      end

      context "when piece_selected is set to false" do
        it "returns an empty string(' ')" do
          allow(@cell_b2).to receive(:piece).and_return(nil)
          piece_selected = false
          expect(set_string(@cell_b2, piece_selected)).to eq(' ')
        end
      end
    end
  end
  
  # Calculate and return the BG Color for the current Cell
  describe '#set_bg' do
    subject(:board_set_bg) { Board.new }

    before do
      # Active Piece
      active_moves = { forward: [@cell_a2], initial: [], forward_left: [], forward_right: [@cell_b2] }
      @active_piece = instance_double(Piece, position: @cell_a1, moves: active_moves)  
      board_set_bg.instance_variable_set(:@active_piece, @active_piece)
      # Last Move
      @move = class_double(Move, last: nil).as_stubbed_const
    end

    # Highlight the Active Piece
    context "when piece_selected is true and the cell is the @active_piece's cell" do
      it 'returns 46 (Cyan)' do
        piece_selected = true
        expect(board_set_bg.set_bg(@cell_a1, piece_selected)).to eq(46)
      end
    end

    # Highlight Potential Captures
    context "when piece_selected is true, the cell is included in @active_piece's @moves, and the cell has a piece" do
      before do
        allow(@cell_b2).to receive(:piece).and_return(instance_double(Piece))
      end
      it 'returns 41 (Red)' do
        piece_selected = true
        expect(board_set_bg.set_bg(@cell_b2, piece_selected)).to eq(41)
      end
    end

    # Highlight the Last Move
    context "when the cell is equal to the previous move's @end_cell" do
      it 'returns 44 (Blue)' do
        # Last Move: Enemy Piece moved to Cell B1
        last_move = instance_double(Move, end: @cell_b1)
        allow(@move).to receive(:last).and_return(last_move)

        piece_selected = true
        expect(board_set_bg.set_bg(@cell_b1, piece_selected)).to eq(44)
      end

      # If the last cell is also a potential capture of the current turn's 
      # @active_piece, prioritize highlighting Red over highlighting Blue
      context "if the last move is a potential capture of the current @active_piece" do
        before do
          # Last Move: Enemy Piece moved to Cell B2
          last_move = instance_double(Move, end: @cell_b2)
          allow(@move).to receive(:last).and_return(last_move)
          allow(@cell_b2).to receive(:piece).and_return(instance_double(Piece))
        end
        it 'returns 41 (Red)' do
          piece_selected = true
          expect(board_set_bg.set_bg(@cell_b2, piece_selected)).to eq(41)
        end
      end
    end

    # Default Black/White Backgrounds
    context "if none of the above are true" do
      before do
        @piece_selected = false
      end
      it 'returns 40(Black) for even cells' do
        # A(97) + 1 => Even
        expect(board_set_bg.set_bg(@cell_a1, @piece_selected)).to eq(40)
      end

      it 'returns 47(White) for odd cells' do
        # B(98) + 1 => Odd
        expect(board_set_bg.set_bg(@cell_b1, @piece_selected)).to eq(47)
      end
    end
  end
end


