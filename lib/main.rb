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
    Game.new
  when 2
    # game = load_game
    #   load_game: display list of games -> select game to load -> deserialize game file
    # 
  end
end

def play_again?
  loop do
    input = gets.chomp
    unless ['P', 'Q'].include?(input.upcase)
      puts invalid_replay_input_warning
      next
    end
    break input.upcase == 'P'
  end
end

loop do
  system 'clear'
  
  puts tutorial_message
  
  puts game_mode_message
  game = create_game(select_game_mode)
  game.play

  unless play_again?
    puts 'Thanks for playing!'
    break
  end
  clear_game_environment
end



