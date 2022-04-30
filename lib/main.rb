# frozen_string_literal: true

Dir.glob('./lib/*.rb').sort.each { |file| require file unless file.include?('main') }
Dir.glob('./lib/pieces/*.rb').sort.each(&method(:require))

extend GamePrompts
extend Serializable

def clear_game_environment
  Move.stack.clear
  Player.list.clear
end

def create_game(mode)
  case mode
  when 1
    Game.new
  when 2
    load_game
  end
end

def play_again?
  loop do
    input = gets.chomp
    next puts invalid_replay_input_warning unless ['P', 'Q'].include?(input.upcase)

    break input.upcase == 'P'
  end
end

loop do
  system 'clear'
  puts tutorial_message
  puts game_mode_message

  mode = select_game_mode
  # Mode = 1 => new game is true ; Mode = 2 => new game is false
  new_game = mode == 1

  game = create_game(mode)
  game.play(new_game: new_game)

  break puts 'Thanks for playing!' unless play_again?

  clear_game_environment
end
