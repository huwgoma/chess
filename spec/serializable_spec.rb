# frozen_string_literal: true

require './lib/serializable'
require './lib/game'
require './lib/board'

require 'pry'

RSpec.configure do | rspec |
  include Serializable

  # Suppress abort message
  rspec.before(:each) do
    allow(STDERR).to receive(:write)
  end

  # Suppress exit
  rspec.around(:example) do | ex |
    begin
      ex.run
    rescue SystemExit => e
      puts 'Ignoring SystemExit'
    end
  end
end


describe Serializable do
  describe '#save_game' do
    subject(:game_save) { Game.new }

    before do
      allow(File).to receive(:open)
      allow(STDOUT).to receive(:write)
    end

    context 'if the saves Directory does not exist yet' do
      before do
        allow(Dir).to receive(:exist?).with('saves').and_return(false)
      end
      
      it 'sends #mkdir to Dir' do
        expect(Dir).to receive(:mkdir).with('saves')
        game_save.save_game
      end
    end

    it 'opens a File' do
      file_path = "saves/Chess-#{Time.now.strftime("%Y-%m-%d%k:%M:%S")}"
      expect(File).to receive(:open).with(file_path, 'w')
      game_save.save_game
    end

    it 'serializes (dumps) the game object where it is called' do
      expect(Marshal).to receive(:dump).with(game_save)
      game_save.save_game
    end
  end

  describe '#create_file_name' do
    # eg. Chess-2022-04-28 23:25:12
    it 'returns a string with Chess - current date and time' do
      time = Time.now.strftime("%Y-%m-%d%k:%M:%S")
      string = "Chess-#{time}"
      expect(create_file_name).to eq(string)
    end
  end

  describe '#load_game' do
    subject(:game_load) { Game.new }

    before do
      allow(STDOUT).to receive(:write)

      file_list = ["Chess-2022-04-2917:29:38", "..", ".", "Chess-2022-04-2915:53:30"]
      allow(Dir).to receive(:entries).with('saves').and_return(file_list)
      allow(game_load).to receive(:gets).and_return('1')

      @file_path = 'saves/Chess-2022-04-2917:29:38'
    end

    it 'opens the selected File' do
      expect(File).to receive(:open).with(@file_path, 'r')
      game_load.load_game
    end

    it 'deserializes the selected file' do
      temp_file = Tempfile.new('Chess-2022-04-2917:29:38', 'saves')
      allow(File).to receive(:open).with(@file_path) do | file |
        expect(Marshal).to receive(:load)
      end
    end
  end

  describe '#select_game_file' do
    subject(:game_select_file) { Game.new }
    
    before do
      allow(STDOUT).to receive(:write)
      
      file_list = ["Chess-2022-04-2917:29:38", "..", ".", "Chess-2022-04-2915:53:30"]
      allow(Dir).to receive(:entries).with('saves').and_return(file_list)
      allow(game_select_file).to receive(:gets).and_return('1')
    end

    it "returns the filename corresponding to the user's input" do
      expect(game_select_file.select_game_file).to eq("Chess-2022-04-2917:29:38")
    end
  end

  describe '#create_file_list' do
    before do
      file_list = ["..", "Chess-2022-04-2914:49:17", "Chess-2022-04-2914:49:15", "."]
      allow(Dir).to receive(:entries).with('saves').and_return(file_list)
    end
    it "returns an array of files within the saves/ directory (with 'Chess' in its name)" do
      chess_file_list = ["Chess-2022-04-2914:49:17", "Chess-2022-04-2914:49:15"]
      expect(create_file_list).to eq(chess_file_list)
    end
  end

  describe '#select_file_number' do
    subject(:game_select_number) { Game.new }
    
    before do
      allow(STDOUT).to receive(:write)
      @max_num = 3
    end
    
    it 'returns the entered number as an Integer' do
      allow(game_select_number).to receive(:gets).and_return('2')
      expect(game_select_number.select_file_number(@max_num)).to eq(2)
    end

    # Invalid - Input Number is too big, too small (1-max number), or not a number
    context 'if the input is invalid (twice) before being valid' do
      before do
        allow(game_select_number).to receive(:gets).and_return('a', '4', '3')
      end

      it 'prints a warning and recurses' do
        warning = "Invalid input! Please enter a number between [1] and [#{@max_num}]."
        expect(game_select_number).to receive(:puts).with(warning).twice
        game_select_number.select_file_number(@max_num)
      end

      it 'returns the valid number' do
        expect(game_select_number.select_file_number(@max_num)).to eq(3)
      end
    end
  end
end