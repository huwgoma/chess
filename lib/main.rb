# frozen_string_literal: true
require 'pry'
require 'yaml'

Dir.glob('./lib/*.rb').each { |file| require file unless file.include?('main') }
Dir.glob(('./lib/pieces/*.rb'), &method(:require))


extend GameTextable

def clear_game_environment
  Move.stack.clear
  Player.list.clear
end

loop do
  clear_game_environment
  system 'clear'
  
  puts tutorial_message
# puts game_mode_message
  game = Game.new
  game.play

  unless game.play_again?
    puts 'Thanks for playing!'
    break
  end
end



