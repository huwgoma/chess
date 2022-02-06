# frozen_string_literal: true
require 'pry'
Dir.glob('./lib/*.rb').each { |file| require file unless file.include?('main') }

extend GameTextable
puts tutorial_message
# puts game_mode_message

game = Game.new
game.play_game