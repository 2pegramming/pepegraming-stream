require_relative './lock'

redis = Redis.new

lock = Lock.new(redis: redis)

lock_result = lock.lock('hotel.1', ttl: 20_000)

if lock_result
  puts "Service 2 locked: #{lock_result}"
  puts 'Execute logic'
  sleep 10
  lock.unlock(lock_result)
else
  puts "Service 2 failed with lock: #{lock_result}"
  lock.unlock(lock_result)
  puts 'Error'
end
