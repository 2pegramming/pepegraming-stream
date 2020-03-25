URL="redis://localhost:6379"

require 'redis'
require 'securerandom'

class Lock
  Result = Struct.new(:name, :version) do
    def inspect
      "<Lock::Result name=#{name} version=#{version}>"
    end
  end

  UnlockScript='
  if redis.call("get",KEYS[1]) == ARGV[1] then
    return redis.call("del",KEYS[1])
  else
    return 0
  end'

  attr_reader :redis

  def initialize(redis:)
    @redis = redis
  end

  def lock(name, ttl: 1000)
    version = SecureRandom.uuid

    if redis.set(name, version, px: ttl, nx: true)
      Result.new(name, version)
    else
      unlock(Result.new(name, version))
      nil
    end
  end

  def unlock(lock)
    return unless lock

    begin
      redis.call([:eval, UnlockScript, 1, lock.name, lock.version])
    rescue
      # Nothing to do, unlocking is just a best-effort attempt.
    end
  end
end
