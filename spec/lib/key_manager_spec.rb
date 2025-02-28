# frozen_string_literal: true

require_relative '../../lib/key_manager'

RSpec.describe KeyManager do
  let(:key_manager) { KeyManager.new }

  describe '#get_available_key' do
    it 'returns nil if there is no available key' do
      key = key_manager.get_available_key
      expect(key).to be_nil
    end

    it 'returns nil if the key is expired' do
      key_manager.generate_key
      key = key_manager.get_available_key
      key.instance_variable_set(:@expiration, Time.now - 1)
      key = key_manager.get_available_key
      expect(key).to be_nil
    end

    it 'returns a key if there is an available key' do
      key_manager.generate_key
      key = key_manager.get_available_key
      expect(key).to be_instance_of(Key)
    end
  end

  describe '#release_key' do
    it 'return false if the key does not exist' do
      response = key_manager.release_key('key')
      expect(response).to be false
    end

    it 'return false if the key is not locked' do
      key_manager.generate_key
      key = key_manager.get_available_key
      key_manager.release_key(key.key)

      response = key_manager.release_key(key.key)
      expect(response).to be false
    end

    it 'unlocks the key and adds the key back to the heap' do
      key_manager.generate_key
      key1 = key_manager.get_available_key

      response = key_manager.release_key(key1.key)
      expect(response).to be true

      key2 = key_manager.get_available_key
      expect(key1).to eq(key2)
    end
  end

  describe '#remove_key' do
    it 'return false if the key does not exist' do
      response = key_manager.remove_key('key')
      expect(response).to be false
    end

    it 'removes the key from the heap' do
      key_manager.generate_key
      key = key_manager.get_available_key
      remove_response = key_manager.remove_key(key.key)
      expect(remove_response).to be true

      response = key_manager.get_available_key
      expect(response).to be_nil
    end
  end

  describe '#keep_alive' do
    it 'return false if the key does not exist' do
      response = key_manager.keep_alive('key')
      expect(response).to be false
    end

    it 'return false if the key is already expired' do
      key_manager.generate_key
      key = key_manager.get_available_key
      key.instance_variable_set(:@key_expiry, Time.now - 2)
      response = key_manager.keep_alive(key.key)
      expect(response).to be false
    end

    it 'updates the expiration of the key' do
      key_manager.generate_key
      key = key_manager.get_available_key
      expiry = key.key_expiry
      key_manager.keep_alive(key.key)
      expect(key.key_expiry).to be > expiry
    end
  end

  describe '#purge_expired_keys' do
    it 'removes expired keys from the heap' do
      stub_const('Config::KEY_EXPIRATION_SECONDS', -1)
      5.times { key_manager.generate_key }

      key = key_manager.get_available_key
      expect(key).to be_nil
    end
  end

  describe '#to_hash' do
    it 'return valid hash' do
      key_manager.generate_key
      expect(key_manager.to_hash).to be_a(Array)
    end
  end
end
