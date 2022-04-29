# frozen_string_literal: true
require 'pry'
require 'yaml'

Dir.glob('./lib/*.rb').each { |file| require file unless file.include?('main') }
Dir.glob(('./lib/pieces/*.rb'), &method(:require))


extend GamePrompts

def clear_game_environment
  Move.stack.clear
  Player.list.clear
end

loop do
  system 'clear'
  
  puts tutorial_message
  puts game_mode_message
  select_game_mode
# if game mode = 1, start a new game and play it
# else if game mode = 2, load selected game (select later) and play that
  game = Game.new
  game.play

  unless game.play_again?
    puts 'Thanks for playing!'
    break
  end
  clear_game_environment
end



