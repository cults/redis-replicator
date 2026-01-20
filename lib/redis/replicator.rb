# frozen_string_literal: true

require "redis"
require "connection_pool"

require_relative "replicator/version"

class Redis
  # Wrapper that acts as a Redis client.
  class Replicator
    def initialize(urls:)
      @urls = urls
    end

    # Check if the key exists in any of the instances
    def exists?(...)
      connection_pools.any? do |pool|
        pool.then { |redis| redis.exists?(...) }
      rescue *IGNORED_EXCEPTIONS
        false
      end
    end

    # Get the first key it finds on any of the instances
    def get(...)
      connection_pools.each do |pool|
        value = pool.then { |redis| redis.get(...) }
        return value if value
      rescue *IGNORED_EXCEPTIONS
        # Do nothing
      end

      nil
    end

    # Apply updates to all Redis instances
    [:set, :setex, :del].each do |method|
      define_method method do |*args|
        connection_pools.each do |pool|
          pool.then { |redis| redis.public_send(method, *args) }
        rescue *IGNORED_EXCEPTIONS
          # Do nothing
        end
        nil
      end
    end

    private

    IGNORED_EXCEPTIONS = [
      ConnectionPool::TimeoutError,
      Errno::ECONNREFUSED,
      Redis::CannotConnectError,
    ].freeze
    private_constant :IGNORED_EXCEPTIONS

    attr_reader :urls

    def connection_pools
      @connection_pools ||= urls.map do |url|
        ConnectionPool.new(size: 5, timeout: 5) do
          ::Redis.new(url:)
        end
      end
    end
  end
end
