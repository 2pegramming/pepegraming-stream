require 'waterdrop'
require 'avro_turf'
require 'avro_turf/messaging'

avro = AvroTurf::Messaging.new(registry_url: "http://192.168.1.65:8081/")

params = { 'nickname' => '2pe', 'full_name' => 'Jane', 'age' => 28, 'address' => 'here' }
data1 = avro.encode(params, subject: 'person', version: 1)
data2 = avro.encode(params, subject: 'person', version: 2)

# p avro.decode(data)

WaterDrop.setup do |config|
  config.deliver = true
  config.kafka.seed_brokers = %w[kafka://192.168.1.65:9092]
end

p WaterDrop::SyncProducer.call(data1, topic: 'person', headers: { message_subject: 'person', message_version: 1 })
p WaterDrop::SyncProducer.call(data2, topic: 'person', headers: { message_subject: 'person', message_version: 2 })
