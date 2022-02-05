# frozen_string_literal: true
require 'pry'
Dir.glob('./lib/*.rb').each { |file| require file unless file.include?('main') }

game = Game.new
game.play_game