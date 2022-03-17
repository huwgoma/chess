# frozen_string_literal: true
require './lib/cell'
require './lib/pieces/piece'
require './lib/pieces/pawn'
require './lib/pieces/rook'
require 'pry'

describe Cell do
  before do
    @cell_a1 = described_class.new('a', 1)
    @cell_a2 = described_class.new('a', 2)
    @cell_b1 = described_class.new('b', 1)
    @cell_b2 = described_class.new('b', 2)
  end

  describe '#update_piece' do
    subject(:cell_piece) { described_class.new('a', 1) }

    it "updates the Cell's @piece to the given Piece object" do
      rook_piece = instance_double(Rook)
      expect { cell_piece.update_piece(rook_piece) }.to change { cell_piece.piece }.to(rook_piece)
    end
  end

  describe '#has_enemy?' do
    subject(:cell_enemy) { described_class.new('a', 2) }
    it 'returns true if the cell piece has a DIFFERENT color as the given color' do
      enemy_piece = instance_double(Pawn, color: :B)
      cell_enemy.update_piece(enemy_piece)
      
      expect(cell_enemy.has_enemy?(:W)).to be true
    end

    it 'returns false if the cell piece has the SAME color' do
      ally_piece = instance_double(Pawn, color: :W)
      cell_enemy.update_piece(ally_piece)

      expect(cell_enemy.has_enemy?(:W)).to be false
    end

    it 'returns false if the cell has NO piece' do
      cell_enemy.update_piece(nil)
      
      expect(cell_enemy.has_enemy?(:W)).to be false
    end
  end

  describe '#has_ally?' do
    subject(:cell_ally) { described_class.new('a', 2) }
    it 'returns true if the cell piece has the SAME color as the given color' do
      ally_piece = instance_double(Pawn, color: :W)
      cell_ally.update_piece(ally_piece)

      expect(cell_ally.has_ally?(:W)).to be true
    end

    it 'returns false if the cell piece has a DIFFERENT color' do
      enemy_piece = instance_double(Pawn, color: :B)
      cell_ally.update_piece(enemy_piece)

      expect(cell_ally.has_ally?(:W)).to be false
    end

    it 'returns false if the cell has NO piece' do
      cell_ally.update_piece(nil)
      expect(cell_ally.has_ally?(:W)).to be false
    end
  end
end