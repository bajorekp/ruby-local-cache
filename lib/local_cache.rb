# frozen_string_literal: true

require 'logger'

# Simple memory backed cache.
# This cache is not thread safe and is intended only for
# serving as a temporary memory cache for a single thread.
class LocalCache
  DEFAULT_EXPIRES_IN_SECONDS = 30

  def initialize(logger: nil)
    @store = {}
    @logger = logger || Logger.new($stdout)
    @logger.debug('New store for LocalCache initialized')
  end

  def fetch(key, expires_in_seconds: DEFAULT_EXPIRES_IN_SECONDS, save_nil: false)
    return raw_read(key) if valid?(key)

    new_value = yield
    return nil if new_value.nil? && !save_nil

    write(key, new_value, expires_in_seconds: expires_in_seconds)
  end

  def write(key, value, expires_in_seconds: DEFAULT_EXPIRES_IN_SECONDS)
    valid_key = key.to_s
    raise ArgumentError, "Key is too short: #{valid_key}" unless valid_key.length > 1

    logger.debug("Write '#{valid_key}' into cache. Expires in #{expires_in_seconds} seconds")
    @store[valid_key] = {
      value: value,
      expires_at: Time.now.to_i + expires_in_seconds
    }
    @store[key][:value]
  end

  def read(key)
    return nil unless valid?(key)

    raw_read(key)
  end

  def valid?(key)
    @store.key?(key) && @store[key][:expires_at] > Time.now.to_i
  end

  def clear(key)
    @store.delete(key)
    nil
  end

  private

  attr_reader :logger

  def raw_read(key)
    expires_at = @store[key][:expires_at] - Time.now.to_i
    logger.debug("Read '#{key}' from cache. Expires in #{expires_at} seconds")
    @store[key][:value]
  end
end
