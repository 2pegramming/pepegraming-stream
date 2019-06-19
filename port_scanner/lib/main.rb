require 'socket'
require 'concurrent'
require 'concurrent-edge'

# version 1
# class CheckPort
#   HOST = 'localhost'
#
#   def call(port_number)
#     TCPSocket.new(HOST, port_number)
#     true
#   rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
#     false
#   end
# end
#
# puts CheckPort.new.call(2000)
# puts CheckPort.new.call(3333)
#
# result = []
# threads = []
# (2000..2020).each { |p| threads << Thread.new { result << CheckPort.new.call(p) } }
#
# threads.each(&:join)
# p result

# -----------------------------

# version 2
class CheckPort
  include Socket::Constants

  TIMEOUT = 2

  def call(port_number, host)
    socket = Socket.new(AF_INET, SOCK_STREAM, 0)
    sockaddr = Socket.sockaddr_in(port_number, host)
    sockets = nil

    begin
      socket.connect_nonblock(sockaddr)
    rescue Errno::EINPROGRESS, Errno::EISCONN
      _, sockets, _ = IO.select(nil, [socket], nil, TIMEOUT)
      begin
        socket.connect_nonblock(sockaddr)
      rescue Errno::EINPROGRESS, Errno::EISCONN
      end
    end

    socket.close
    !!sockets
  rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
    false
  end
end

class SyncPortsScanner
  HOST = '127.0.0.1'

  attr_reader :check_port

  def initialize(check_port = CheckPort.new)
    @check_port = check_port
  end

  def call(port_list, host = HOST)
    port_list.to_a.each { |port| check_port.call(port, host) }
  end
end

# SyncPortsScanner.new.call(3300..3700)
# realtime = Benchmark.realtime { SyncPortsScanner.new.call(4000..4260) }
# puts "Sync version #{realtime}"

class ThreadPortsScanner
  HOST = '127.0.0.1'

  attr_reader :check_port

  def initialize(check_port = CheckPort.new)
    @check_port = check_port
  end

  def call(port_list, host = HOST)
    port_list.to_a.each_slice(50).each do |batch|
      threads = []
      batch.each { |port| threads << Thread.new { check_port.call(port, host) } }
      threads.each(&:join)
    end
  end
end

class PromisesPortsScanner
  HOST = '127.0.0.1'

  attr_reader :check_port

  def initialize(check_port = CheckPort.new)
    @check_port = check_port
  end

  def call(port_list, host = HOST)
    promises = []

    port_list.to_a.each_slice(50).each do |batch|
      batch.each do |port|
        promises << Concurrent::Promises.future { [port, check_port.call(port, host)] } 
      end
    end
  end
end

class ActorPortsScanner
  HOST = '127.0.0.1'

  attr_reader :check_port

  def initialize(check_port = CheckPort.new)
    @check_port = check_port
    @actors = (0..10).map do
      Concurrent::ErlangActor.spawn(type: :on_thread, name: 'sum') do
        while true
          ports = receive
          break if message == :done
          reply ports.map { |port| [port, check_port.call(port, host)] }
        end
      end
    end
  end

  def call(port_list, host = HOST)
    results = []

    port_list.to_a.each_slice(10).each do |batch|
      results << actor.tell(batch)
    end
  end
end


actor.tell(1).tell(1)

puts actor.ask 10  
