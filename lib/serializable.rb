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
  # def save game
  # Dir.mkdir(saves) unless saves exists already
  # file name?: 
  # save the current game (to saves/) then exit

  def create_file_name
    time = Time.now.strftime("%Y-%m-%d%k:%M:%S")
    "Chess-#{time}"
  end

  # def create game list
  # create an array of files within saves/ directory

  # def print game list
  # print the array of game files (with index)
  # if list is empty exit program

  # find saved file to play

  # select game
  # get user input; select one of the games to load and play
  
  # load game file
  # deserialize the string in the chosen file
end