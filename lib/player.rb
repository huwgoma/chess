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

  def self.load_list(list)
    @@list = list
  end

  def self.find(color)
    @@list.find { | player | player.color == color }
  end

  def white?
    @color == :W
  end
end