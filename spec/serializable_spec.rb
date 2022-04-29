# frozen_string_literal: true

require './lib/serializable'

RSpec.configure do
  include Serializable
end

describe Serializable do
  describe '#save_game' do
    context 'if the saves Directory does not exist yet' do
      it 'sends #mkdir to Dir' do
        
      end
    end

    it '#opens the specified file path' do
      
    end

    it 'serializes the object on which it is called with Marshal#dump' do
      
    end

    it 'writes (#puts) the serialized game string to the file' do
      
    end
  end

  describe '#create_file_name' do
    # Time.now.strftime("%Y-%m-%d %k:%M:%S")
    # eg. Chess - 2022-04-28 23:25:12
    it 'returns a string with Chess - current date and time' do
      
    end
  end
end