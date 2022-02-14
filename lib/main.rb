# frozen_string_literal: true
require 'pry'
require 'yaml'

Dir.glob('./lib/*.rb').each { |file| require file unless file.include?('main') }
Dir.glob(('./lib/pieces/*.rb'), &method(:require))

extend GameTextable
puts tutorial_message
# puts game_mode_message

game = Game.new
game.play_game