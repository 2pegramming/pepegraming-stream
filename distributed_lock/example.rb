class Lock
  def initialize
    @mutex = Mutex.new
    @resources = {}
  end

  def lock(name)
    if @resources[name]
      false
    else
      @mutex.synchronize do
        @resources[name] = true
      end
    end
  end

  def unlock(name)
    @mutex.synchronize do
      @resources.delete(name)
    end
  end
end

class Repo
  def update(id, payload)
    puts "Updating... ##{id}, #{payload}"
  end
end

lock = Lock.new
repo = Repo.new

threads = [
  Thread.new do
    result = lock.lock('repo.update.1')
    puts 'resource locked in thread 1'

    if result
      sleep 0.5
      repo.update(1, name: 'thread 1')
    end

    lock.unlock('repo.update.1')
  end,

  Thread.new do
    sleep 0.1

    if lock.lock('repo.update.1')
      repo.update(1, name: 'thread 2')

      lock.unlock('repo.update.1')
    else

      puts "resource wasn't lock in thread 2"
      sleep 1

      if lock.lock('repo.update.1')
        puts 'resource locked in thread 2'
        repo.update(1, name: 'thread 2, subcondition')

        lock.unlock('repo.update.1')
      end
    end

  end
]
threads.each(&:join)



