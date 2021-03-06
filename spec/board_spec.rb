# frozen_string_literal: true
Dir.glob('./lib/*.rb').each { |file| require file unless file.include?('main') }
Dir.glob(('./lib/pieces/*.rb'), &method(:require))

require 'pry'

describe Board do
  # Test the Board Preparation/Utility Methods first
  context "Board Preparation/Utility Methods" do
    before do
      @cell = class_double(Cell).as_stubbed_const
  
      @cell_a1 = instance_double(Cell, 'a1', column: 'a', row: 1, coords: 'a1')
      @cell_a2 = instance_double(Cell, 'a2', column: 'a', row: 2, coords: 'a2')
      @cell_b1 = instance_double(Cell, 'b1', column: 'b', row: 1, coords: 'b1')
      @cell_b2 = instance_double(Cell, 'b2', column: 'b', row: 2, coords: 'b2')
  
      @cell_list = [@cell_a1, @cell_a2, @cell_b1, @cell_b2]
  
      @column_hash = {'a' => [@cell_a1, @cell_a2], 'b' => [@cell_b1, @cell_b2]}
      @row_hash = {1 => [@cell_a1, @cell_b1], 2 => [@cell_a2, @cell_b2]}
    end  
    
    describe '#prepare_board' do
      subject(:board_prepare) { described_class.new }
      # Initialize the 64 Cells
      describe '#initialize_cells' do
        it 'sends ::new to Cell class 64 times' do
          expect(@cell).to receive(:new).exactly(64).times
          board_prepare.initialize_cells
        end
      end
  
      # Sort @cells into columns/rows
      describe '#sort_cells' do
        before do
          board_prepare.instance_variable_set(:@cells, @cell_list)
        end
  
        context "when given :column as the axis parameter" do
          it 'sorts @cells into a Hash of cells organized by columns' do
            expect(board_prepare.sort_cells(:column)).to eq(@column_hash) 
          end
        end
  
        context "when given :row as the axis parameter" do   
          it 'sorts @cells into a Hash of cells organized by rows' do
            expect(board_prepare.sort_cells(:row)).to eq(@row_hash) 
          end
        end
      end
  
      # Iterate through the 32 Pieces and place them onto their initial Cells
      # Add Pieces to @living_pieces as they are created/placed
      describe '#place_pieces' do
        before do
          @piece = class_double(Piece).as_stubbed_const
          @pieces = { 'a1' => { color: :W, type: :Rook } } 
          
          @rook_factory = instance_double(RookFactory)
          allow(@piece).to receive(:select_factory).and_return(@rook_factory)
          @rook = instance_double(Rook, color: :W)
          allow(@rook_factory).to receive(:place_piece).and_return(@rook)
        end
        
        it "calls ::select_factory on Piece using the current piece's type" do
          cell_a1_type = :Rook
          expect(@piece).to receive(:select_factory).with(cell_a1_type)
          board_prepare.place_pieces(@pieces)
        end
  
        it "sends #place_piece to the PieceFactory subclass object" do
          expect(@rook_factory).to receive(:place_piece)
          board_prepare.place_pieces(@pieces)
        end

        it "adds the created Piece to @living_pieces" do
          living_pieces = { W: [@rook], B: [] }
          expect { board_prepare.place_pieces(@pieces) }.to change { board_prepare.living_pieces }.to(living_pieces)
        end
      end
    end
  
    # Find and return the corresponding Cell given a coordinate input
    describe '#find_cell' do
      subject(:board_find) { described_class.new }
  
      before do
        board_find.instance_variable_set(:@cells, @cell_list)
      end
  
      context 'when given a valid alphanumeric coordinate' do
        it 'returns the corresponding Cell object' do
          coords = 'a1'
          expect(board_find.find_cell(coords)).to eq(@cell_a1)
        end
      end
  
      context 'when given an invalid out of bounds coordinate' do
        it 'returns nil when the column is out of bounds' do
          coords = 'c1'
          expect(board_find.find_cell(coords)).to be nil
        end

        it 'returns nil when the row is out of bounds' do
          coords = 'a10'
          expect(board_find.find_cell(coords)).to be nil
        end
      end
    end

    # Set @active_piece - Given a Piece, set the board's @active piece to that Piece
    describe '#set_active_piece' do
      subject(:board_active) { described_class.new }
      it "updates @active_piece to the given piece" do
        piece = instance_double(Piece)
        expect { board_active.set_active_piece(piece) }.to change { board_active.active_piece }.to(piece)
      end
    end
  end

  before do
    # Create a Board of Instance Doubles for Cells
    @cell_doubles = []
    8.times do | x |
      column = (x + 97).chr
      8.times do | y |
        row = (y + 1)
        @cell_doubles << instance_double(Cell, 
          column: column, row: row, coords: "#{column+row.to_s}",
          piece: nil, empty?: true, has_enemy?: false, has_ally?: false,
          update_piece: nil)
      end
    end

    # Set each Board (subject)'s @cells to @cell_doubles
    subject.instance_variable_set(:@cells, @cell_doubles)
  end

  # Move Piece - Given a Piece, Start, and End, move the Piece from Start to End Cell
  describe '#move_piece' do
    subject(:board_move) { described_class.new }
    before do
      # Start Cell
      @start = instance_double(Cell, 'start')
      allow(@start).to receive(:update_piece)
      # Moving Piece
      @piece = instance_double(Piece, 'moved', color: :W)
      allow(@piece).to receive(:update_position)
      # Killed Piece
      @killed = instance_double(Piece, 'killed', color: :B)
      allow(@killed).to receive(:is_killed)
      # End Cell
      @end = instance_double(Cell, 'end', piece: nil, has_enemy?: false)
      allow(@end).to receive(:update_piece)
      # Direction
      @dir = :forward
      # Set Living Pieces
      @living_pieces = { W: [@piece], B: [@killed] }
      board_move.instance_variable_set(:@living_pieces, @living_pieces)
    end

    it 'sends #update_piece with nil to the start cell' do
      expect(@start).to receive(:update_piece).with(nil)
      board_move.move_piece(piece: @piece, start_cell: @start, end_cell: @end, dir: @dir)
    end

    it 'sends #update_position with the end cell to the moving piece' do
      expect(@piece).to receive(:update_position).with(@end)
      board_move.move_piece(piece: @piece, start_cell: @start, end_cell: @end, dir: @dir)
    end

    context "if the end cell already has an enemy piece occupying it" do
      before do
        allow(@end).to receive(:has_enemy?).and_return(true)
        allow(@end).to receive(:piece).and_return(@killed)
        allow(@killed).to receive(:position).and_return(@end)
      end

      it 'kills the enemy piece' do
        expect(board_move).to receive(:kill_piece).with(@killed)
        board_move.move_piece(piece: @piece, start_cell: @start, end_cell: @end, dir: @dir)
      end

      # If a Killed Piece exists, send that Piece to Move#new
      it 'creates a new Move object with the Killed Piece' do
        move = class_double(Move).as_stubbed_const
        expect(move).to receive(:new).with(piece: @piece, start_cell: @start, end_cell: @end, dir: @dir, kill: @killed)
        board_move.move_piece(piece: @piece, start_cell: @start, end_cell: @end, dir: @dir)
      end
    end

    it 'sends #update_piece with the moving piece to the end cell' do
      expect(@end).to receive(:update_piece).with(@piece)
      board_move.move_piece(piece: @piece, start_cell: @start, end_cell: @end, dir: @dir)
    end

    # If no Piece was killed, killed = nil is passed to Move#new
    it 'creates a new Move object' do
      move = class_double(Move).as_stubbed_const
      expect(move).to receive(:new).with(piece: @piece, start_cell: @start, end_cell: @end, dir: @dir, kill: nil)
      board_move.move_piece(piece: @piece, start_cell: @start, end_cell: @end, dir: @dir)
    end

    # Castling
    context 'when the direction of the move is castle_king' do
      before do
        @dir = :castle_king
        @move = class_double(Move).as_stubbed_const

        # Castling Rook
        @rook_piece = instance_double(Rook, color: :W)
        @rook_start = instance_double(Cell, coords: 'h1', piece: @rook_piece)
        @rook_end = instance_double(Cell, coords: 'f1', piece: nil)

        # Move Rook
        allow(@rook_start).to receive(:update_piece)
        allow(@rook_piece).to receive(:update_position)
        allow(@rook_end).to receive_messages(has_enemy?: false, update_piece: @rook_piece)
        
        # Rook
        rook = class_double(Rook).as_stubbed_const
        allow(rook).to receive(:===).with(@rook_piece).and_return(true)
      end

      context 'when the type of the moving Piece is King' do
        before do
          # King
          @king_start = instance_double(Cell, column: 'e', row: 1, coords: 'e1')
          @king_piece = instance_double(King, position: @king_start, color: :W)
          @king_end = instance_double(Cell, coords: 'g1', piece: nil)
          
          king = class_double(King).as_stubbed_const
          allow(king).to receive(:===).with(@king_piece).and_return(true)
          allow(king).to receive(:===).with(@rook_piece).and_return(false)

          # Move King
          allow(@king_start).to receive(:update_piece)
          allow(@king_piece).to receive(:update_position)
          allow(@king_end).to receive_messages(has_enemy?: false, update_piece: @king_piece)

          # Rook Castle Cells
          cells = [@rook_start, @rook_end]
          board_move.instance_variable_set(:@cells, cells)
        end

        it "returns the Move object for the King's castle move" do
          rook_move = instance_double(Move, 'r', piece: @rook_piece, start: @rook_start, end: @rook_end)
          king_move = instance_double(Move, 'k', piece: @king_piece, start: @king_start, end: @king_end, rook_move: rook_move)
          allow(@move).to receive(:new).and_return(rook_move, king_move)
          
          expect(board_move.move_piece(piece: @king_piece, start_cell: @king_start, end_cell: @king_end, dir: @dir)).to eq(king_move)
        end
      end

      context 'when the type of the moving Piece is Rook' do
        it "sends #new to Move with the details of the castling Rook's move - secondary flag set to true" do
          expect(@move).to receive(:new).with(piece: @rook_piece, start_cell: @rook_start, end_cell: @rook_end, dir: @dir, secondary: true)
          board_move.move_piece(piece: @rook_piece, start_cell: @rook_start, end_cell: @rook_end, dir: @dir)
        end
      end
    end
  end

  # King in Check? - Given a Color, check if that Color's King is in danger
  describe '#king_in_check?' do
    subject(:board_check) { described_class.new }
    before do      
      # Mock White King at E2
      cell_e2 = board_check.find_cell('e2')
      @w_king_e2 = instance_double(King, color: :W, position: cell_e2)
      allow(@w_king_e2).to receive(:is_a?)
      allow(@w_king_e2).to receive(:is_a?).with(King).and_return(true)
        
      # Mock Black King at E8 
      cell_e8 = board_check.find_cell('e8')
      @b_king_e8 = instance_double(King, color: :B, position: cell_e8)
      allow(@b_king_e8).to receive(:is_a?)
      allow(@b_king_e8).to receive(:is_a?).with(King).and_return(true)

      # Mock a Black Rook 
      @rook_moves = { top:[], right:[], bot:[], left:[] }
      @b_rook = instance_double(Rook, class: Rook,
        moves: @rook_moves, color: :B)
      allow(@b_rook).to receive(:is_a?)
      allow(@b_rook).to receive(:is_a?).with(Pawn).and_return(false)

      # Living Pieces - Black Rook E7
      living_pieces = { W:[@w_king_e2], B:[@b_rook] }
      board_check.instance_variable_set(:@living_pieces, living_pieces)
    end

    context "if the King is in check" do
      before do
        # Move the Black Rook to E7 ====> White King at E2
        cell_e7 = board_check.find_cell('e7')
        allow(@b_rook).to receive(:position).and_return(cell_e7)
      end

      it 'returns true' do
        expect(board_check.king_in_check?(:W)).to be true
      end
    end

    context "if the King is not in check" do
      before do 
        # Move the Black Rook to D7 =========> (no King)
        cell_d7 = board_check.find_cell('d7')
        allow(@b_rook).to receive(:position).and_return(cell_d7)
      end

      it 'returns false if the King is not in check' do
        expect(board_check.king_in_check?(:W)).to be false
      end
    end
  end

  # King in Checkmate - Given a color, check if that color's King is in checkmate
  describe '#king_in_checkmate?' do
    subject(:board_checkmate) { described_class.new }
    before do
      # Black King at A8
      king_moves = { top:[], top_right:[], right:[], bot_right:[], bot:[], bot_left:[], left:[], top_left:[] }
      @cell_a8 = board_checkmate.find_cell('a8')
      @b_king = instance_double(King, class: King, is_a?: true, color: :B,
        position: @cell_a8, moves: king_moves, update_position: nil)
      allow(@b_king).to receive(:is_a?).with(Pawn).and_return(false)
      allow(@cell_a8).to receive(:piece).and_return(@b_king)
      
      # White Rook at C8
      rook_moves = { top:[], right:[], bot:[], left:[] }

      @cell_c8 = board_checkmate.find_cell('c8')
      @w_rook_1 = instance_double(Rook, class: Rook, is_a?: true, color: :W,
        position: @cell_c8, moves: rook_moves)
      allow(@w_rook_1).to receive(:is_a?).with(Pawn).and_return(false)
      allow(@w_rook_1).to receive(:is_a?).with(King).and_return(false)

      # White Rook at D7
      @cell_d7 = board_checkmate.find_cell('d7')
      @w_rook_2 = instance_double(Rook, class: Rook, is_a?: true, color: :W,
        position: @cell_d7, moves: rook_moves)
      allow(@w_rook_2).to receive(:is_a?).with(Pawn).and_return(false)
      allow(@w_rook_2).to receive(:is_a?).with(King).and_return(false)

      # Generate Black King Moves
      @cell_b8 = board_checkmate.find_cell('b8')
      @cell_b7 = board_checkmate.find_cell('b7')
      @cell_a7 = board_checkmate.find_cell('a7')

      # Move the King Cell to each Cell
      allow(board_checkmate).to receive(:find_king_cell).with(:B).and_return(@cell_b8, @cell_b7, @cell_a7)

      # Verify Black King Moves
      # B8:
      allow(@cell_b8).to receive(:empty?).and_return(true, false)
      allow(@cell_b8).to receive(:has_enemy?).with(:W).and_return(true)
      # B7:
      allow(@cell_b7).to receive(:empty?).and_return(true, false, true)
      allow(@cell_b7).to receive(:has_enemy?).with(:W).and_return(true)
      # A7:
      allow(@cell_a7).to receive(:empty?).and_return(true, false)
      allow(@cell_a7).to receive(:has_enemy?).with(:W).and_return(true)

      # Living Pieces
      @living_pieces = { W: [@w_rook_1, @w_rook_2], B: [@b_king] }
      board_checkmate.instance_variable_set(:@living_pieces, @living_pieces)

      # Clone Board
      @clone_board = described_class.new 
      @clone_board.instance_variable_set(:@cells, @cell_doubles)
      @clone_board.instance_variable_set(:@living_pieces, @living_pieces)
      allow(@clone_board).to receive(:find_king_cell).with(:B).and_return(@cell_b8, @cell_b7, @cell_a7)

      marshal = class_double(Marshal).as_stubbed_const
      allow(marshal).to receive(:dump)
      allow(marshal).to receive(:load).and_return(@clone_board)
    end

    # Checkmate - when none of the living Pieces of that color have any legal moves
    context 'when the Black King is in Checkmate' do
      it 'returns true' do
        expect(board_checkmate.king_in_checkmate?(:B)).to be true
      end
    end

    context 'when the Black King is not in Checkmate' do
      before do
        # Remove the White Rook at D7, allowing Black King to escape
        @living_pieces = { W: [@w_rook_1], B: [@b_king] }
        board_checkmate.instance_variable_set(:@living_pieces, @living_pieces)
        @clone_board.instance_variable_set(:@living_pieces, @living_pieces)

        allow(@cell_b8).to receive(:empty?).and_return(true, false)
        allow(@cell_b7).to receive(:empty?).and_return(true)
      end
      it 'returns false' do
        expect(board_checkmate.king_in_checkmate?(:B)).to be false
      end
    end
  end

  # Find King Cell - Given a Color, find+return that Color's King's Cell
  describe '#find_king_cell' do
    subject(:board_find_king) { described_class.new }
    before do
      # White King at E2 - #is_a?(King)
      @cell_e2 = board_find_king.find_cell('e2')
      @w_king = instance_double(King, position: @cell_e2, color: :W)
      allow(@w_king).to receive(:is_a?).with(King).and_return(true)
      # White Rook - Verify it only finds the King Piece
      @w_rook = instance_double(Rook, is_a?: false)
      # Black King at E8
      @cell_e8 = board_find_king.find_cell('e8')
      @b_king = instance_double(King, position: @cell_e8, color: :B)
      allow(@b_king).to receive(:is_a?).with(King).and_return(true)

      # Set Living Pieces
      @living_pieces = { W: [@w_rook, @w_king], B: [@b_king] }
      board_find_king.instance_variable_set(:@living_pieces, @living_pieces)
    end

    context 'when :W (White) is the given color' do
      it "returns the White King's cell" do
        expect(board_find_king.find_king_cell(:W)).to eq(@cell_e2)
      end
    end

    context 'when :B (Black) is the given color' do
      it "returns the Black King's cell" do
        expect(board_find_king.find_king_cell(:B)).to eq(@cell_e8)
      end
    end

  end

  # Kill Piece - Kill the given Piece and remove it from Board@living_pieces
  describe '#kill_piece' do
    subject(:board_kill) { described_class.new }
    before do
      # Place a White Piece on A1 and a Black Piece on A2
      @cell_a1 = instance_double(Cell, 'a1', update_piece: nil)
      @w_a1_piece = instance_double(Piece, 'w_a1', color: :W, killed: false, position: @cell_a1)
      allow(@w_a1_piece).to receive(:is_killed)

      @cell_a2 = instance_double(Cell, 'a2', update_piece: nil)
      @b_a2_piece = instance_double(Piece, 'b_a2', color: :B, killed: false, position: @cell_a2)
      allow(@b_a2_piece).to receive(:is_killed)
      # Create the Living Pieces Hash (with just 2 pieces on the board)
      @living_pieces = { W: [@w_a1_piece], B: [@b_a2_piece] }
      board_kill.instance_variable_set(:@living_pieces, @living_pieces)
    end

    it 'sends #is_killed to the given piece' do
      expect(@w_a1_piece).to receive(:is_killed)
      board_kill.kill_piece(@w_a1_piece)
    end
    
    it "vacates the given Piece's cell" do
      expect(@cell_a1).to receive(:update_piece).with(nil)
      board_kill.kill_piece(@w_a1_piece)
    end

    it 'deletes the killed piece from @living_pieces' do
      after_kill = { W: [], B: [@b_a2_piece] }
      expect { board_kill.kill_piece(@w_a1_piece) }.to change { board_kill.living_pieces }.to(after_kill) 
    end

    it 'returns the killed piece after deletion' do
      expect(board_kill.kill_piece(@b_a2_piece)).to eq(@b_a2_piece)
    end
  end

  # Undo Last Move - Remove the last Move from Move@@stack, then call 
  # #undo on that Move object - Will revert the changes made by that Move
  # Also #revive the killed Piece (if any) and add it back to @living_pieces
  describe '#undo_last_move' do
    subject(:board_undo) { described_class.new }
    before do
      # Mock the killed Piece
      @killed_piece = instance_double(Piece, killed: true, color: :W)
      allow(@killed_piece).to receive(:is_revived)
      # Set Board's Living Pieces
      @living_pieces = { W:[], B:[] }
      board_undo.instance_variable_set(:@living_pieces, @living_pieces)
      # Mock the last Move Object
      @last_move = instance_double(Move, kill: nil)
      allow(@last_move).to receive(:undo)
      # Mock the Move Class
      @move = class_double(Move).as_stubbed_const
      allow(@move).to receive(:pop).and_return(@last_move)
    end
    
    it "asks the Move class to ::pop the last move from its @@stack" do
      expect(@move).to receive(:pop)
      board_undo.undo_last_move
    end

    it "asks the popped Move object to #undo the effects of its move" do
      expect(@last_move).to receive(:undo)
      board_undo.undo_last_move
    end

    context "if there was a Killed Piece" do
      before do
        allow(@last_move).to receive(:kill).and_return(@killed_piece)
      end
      it 'calls Board#revive_piece to revive the Piece' do
        expect(board_undo).to receive(:revive_piece).with(@killed_piece)
        board_undo.undo_last_move
      end
    end
  end

  # Revive Piece - Revive the given Piece and add it back to @living_pieces
  describe '#revive_piece' do
    subject(:board_revive) { described_class.new }
    before do
      @w_piece = instance_double(Piece, color: :W)
      allow(@w_piece).to receive(:is_revived)

      @living_pieces = { W:[], B:[] }
      board_revive.instance_variable_set(:@living_pieces, @living_pieces)
    end

    it 'sends #is_revived to the Piece' do
      expect(@w_piece).to receive(:is_revived)
      board_revive.revive_piece(@w_piece)
    end

    it 'adds the Piece to @living_pieces' do
      updated_living_pieces = { W:[@w_piece], B:[] }
      expect { board_revive.revive_piece(@w_piece) }.to change { board_revive.living_pieces }.to(updated_living_pieces)
    end
  end
end