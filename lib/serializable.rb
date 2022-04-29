# frozen_string_literal: true

require 'pry'

module Serializable
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

  def load_game
    # create a list of games within saves/ - if list is empty, print warning; exit(?)
    # print the list of games - add index [1] - file name
    # select game file - gets.chomp, input must be between 1 and game_list.size
    #   => return selected number
    # find game file - game_list[returned number]
    # deserialize the found game file (Marshal.load(file))
  end
end