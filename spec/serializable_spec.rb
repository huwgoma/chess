# frozen_string_literal: true

require './lib/serializable'
require './lib/game'
require './lib/board'

RSpec.configure do
  include Serializable
end

describe Serializable do
  describe '#save_game' do
    subject(:game_save) { Game.new }

    before do
      allow(File).to receive(:open)
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

    it 'writes the serialized string to the created File' do
      string = Marshal.dump(game_save)
      file_path = "saves/Chess-#{Time.now.strftime("%Y-%m-%d%k:%M:%S")}"

      allow(File).to receive(:open).with(file_path, 'w') do | file |
        expect(file).to receive(:puts).with(string)
      end
    end
  end

  describe '#create_file_name' do
    # Time.now.strftime("%Y-%m-%d %k:%M:%S")
    # eg. Chess - 2022-04-28 23:25:12
    it 'returns a string with Chess - current date and time' do
      time = Time.now.strftime("%Y-%m-%d%k:%M:%S")
      string = "Chess-#{time}"
      expect(create_file_name).to eq(string)
    end
  end
end