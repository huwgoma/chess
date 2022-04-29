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
    file_list = create_file_list
    abort(no_saved_games_message) if file_list.empty?
    
    display_file_list(file_list)
    # print the list of games - add index [1] - file name
    # select game file - gets.chomp, input must be between 1 and game_list.size
    #   => return selected number
    # find game file - game_list[returned number]
    # deserialize the found game file (Marshal.load(file))
  end

  def create_file_list
    Dir.entries('saves').select { | file | file.include?('Chess') }
  end

  def display_file_list(file_list)
    file_list.each_with_index do | file, index |
      puts "[#{index + 1}] - #{file}"
    end
  end
end