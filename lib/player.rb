# frozen_string_literal: true

class Player
  attr_reader :name, :color

  @@list = []

  def initialize(name, color)
    @name = name
    @color = color
    @@list << self
  end

  def self.list
    @@list
  end

  

  def white?
    @color == :W
  end
end