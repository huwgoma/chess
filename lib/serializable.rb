# frozen_string_literal: true

require './lib/game_prompts'
require 'pry'

module Serializable
  include GamePrompts
  
  # Save (Serialize) Game
  def save_game
    dir = 'saves'
    Dir.mkdir(dir) unless Dir.exist?(dir)
    serialize = Marshal.dump(self)
    
    file_path = "#{dir}/#{create_file_name}"
    File.open(file_path, 'w') do | file |
      file.puts serialize
    end

    puts game_saved_message(file_path)
    exit
  end

  def create_file_name
    time = Time.now.strftime("%Y-%m-%d%k:%M:%S")
    "Chess-#{time}"
  end

  # Load (De-serialize) Game
  def load_game
    file = select_game_file
    # select_game_file => game file
    #   create file list -> display file list - DONE
    #   select_file_number
    #   game_file = file_list[file_number - 1]
    # then deserialize contents of game file
    
    
    
    # print the list of games - add index [1] - file name
    # select game file - gets.chomp, input must be between 1 and game_list.size
    #   => return selected number
    # find game file - game_list[returned number]
    # deserialize the found game file (Marshal.load(file))
  end

  # Create file list, display file list, prompt user to input a number,
  # return the file name corresponding to the inputted number
  def select_game_file
    file_list = create_file_list
    abort(no_saved_games_message) if file_list.empty?

    display_file_list(file_list)
    file_num = select_file_number(file_list.size)
    file_list[file_num - 1]
  end

  # Create and return an array of the files (with 'Chess') in saves/ directory
  def create_file_list
    Dir.entries('saves').select { | file | file.include?('Chess') }
  end

  # Display each file in file_list, prepended with index + 1
  def display_file_list(file_list)
    file_list.each_with_index do | file, index |
      puts "[#{index + 1}] - #{file}"
    end
  end

  # Prompt user to input a number corresponding to a saved file
  def select_file_number(max_num)
    input = gets.chomp.to_i
    return input if input.between?(1, max_num)

    puts invalid_file_number_message(max_num)
    select_file_number(max_num)
  end
end