# frozen_string_literal: true

require 'algorithms'
require_relative 'key'

# A threaded key manager generate key on-demand and clean them up.
# It uses a map to achieve constant lookup time. It uses a heap to
# keep track of the available keys to allocate. Also, it uses a
# background thread to purge expired keys from the map and heap.
# This helps to clean up the increasing size of the map and heap.
# Operations are synchronized using a mutual lock.
# Generated keys will have an expiry time and a lock time.
# If a key not kept alive before expiry, it will be removed.
class KeyManager
  include Containers
  def initialize
    @keys_map = {}
    @keys_heap = Heap.new { |a, b| a.key_expiry > b.key_expiry }
    @mutual_lock = Mutex.new

    Thread.new { purge_expired_keys }
  end

  # Generate a new key and store it.
  # It should return the key.
  def generate_key
    key = Key.new

    @mutual_lock.synchronize do
      @keys_map[key.key] = key
      @keys_heap.push(key)
    end
  end

  # Get an available key. While getting it, the key will be locked.
  # After the lock expiry, the key will be released to use.
  #
  # @return [Key, nil] returns a key if there is an available key
  # and nil if there is no available key.
  def get_available_key
    @mutual_lock.synchronize do
      key = @keys_heap.pop
      return nil if key.nil?

      @keys_map.delete(key.key) && return if key.expired?

      key.lock
      return key
    end
  end

  # Release a locked key.
  #
  # @return [Boolean] returns true if the key was released and false otherwise.
  def release_key(key_str)
    @mutual_lock.synchronize do
      key = @keys_map[key_str]
      return false if key.nil? || !key.locked?

      key.unlock
      @keys_heap.push(key)
      return true
    end
  end

  # Remove a key entirely.
  #
  # @return [Boolean] returns true if the key was removed and false otherwise.
  def remove_key(key_str)
    @mutual_lock.synchronize do
      key = @keys_map[key_str]
      return false if key.nil?

      delete_key(key)
      return true
    end
  end

  # Keep a key alive. If a key is not kept alive before expiry, it will be removed.
  #
  # @return [Boolean] returns the key if the key was kept alive and false otherwise.
  def keep_alive(key_str)
    @mutual_lock.synchronize do
      key = @keys_map[key_str]
      return false if key.nil? || key.expired?

      key.update_expiry
      @keys_heap.change_key(key, key)
      return key
    end
  end

  # Serialize the keys for display purposes.
  #
  # @return [Array] returns an array of keys.
  def to_hash
    @mutual_lock.synchronize do
      return @keys_map.values.map(&:to_hash)
    end
  end

  private

  # Clean up a key from the store.
  def delete_key(key)
    @keys_map.delete(key.key)
    @keys_heap.delete(key)
  end

  # Purge expired keys from the store. It runs in a background thread.
  # It purge expired keys every PURGE_INTERVAL_SECONDS.
  def purge_expired_keys
    loop do
      @mutual_lock.synchronize do
        keys_to_delete = []
        @keys_map.each do |_, key|
          key.unlock if key.locked? && key.lock_expired?
          keys_to_delete.push(key) if key.expired?
        end

        keys_to_delete.each { |key| delete_key(key) }
      end

      sleep(Config::PURGE_INTERVAL_SECONDS)
    end
  end
end
