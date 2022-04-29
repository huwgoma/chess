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

def create_game(mode)
  case mode
  when 1
    game = Game.new
  when 2
    # game = load_game
    #   load_game: display list of games -> select game to load -> deserialize game file
    # game.play
  end
end

loop do
  system 'clear'
  
  puts tutorial_message
  puts game_mode_message
  mode = select_game_mode
# if game mode = 1, start a new game and play it
# else if game mode = 2, load selected game (select later) and play that
  game = create_game(mode)
  game.play
  
  unless game.play_again?
    puts 'Thanks for playing!'
    break
  end
  clear_game_environment
end



