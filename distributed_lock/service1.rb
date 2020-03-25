require_relative './lock'

redis = Redis.new
redis.flushdb

lock = Lock.new(redis: redis)

lock_result = lock.lock('hotel.1', ttl: 20_000)
puts "Service 1 locked: #{lock_result}"
sleep 19
lock.unlock(lock_result)
