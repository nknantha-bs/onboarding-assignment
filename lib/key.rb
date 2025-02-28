# frozen_string_literal: true

require_relative 'config'
require 'securerandom'

class Key
  attr_reader :key, :key_expiry

  def initialize
    @key = "bs-#{SecureRandom.alphanumeric(Config::API_KEY_LENGTH)}"
    @key_expiry = Time.now + Config::KEY_EXPIRATION_SECONDS
    @lock_expiry = nil
  end

  def expired?
    Time.now > @key_expiry
  end

  def locked?
    @lock_expiry != nil
  end

  def lock_expired?
    Time.now > @lock_expiry
  end

  def lock
    @lock_expiry = Time.now + Config::LOCK_EXPIRATION_SECONDS
  end

  def unlock
    @lock_expiry = nil
    update_expiry
  end

  def update_expiry
    @key_expiry = Time.now + Config::KEY_EXPIRATION_SECONDS
  end

  def to_hash
    {
      key: @key,
      key_expiry: @key_expiry.strftime('%H:%M:%S.%L'),
      lock_expiry: @lock_expiry.is_a?(Time) ? @lock_expiry.strftime('%H:%M:%S.%L') : nil,
      is_expired: expired?,
      is_locked: locked?
    }
  end
end
