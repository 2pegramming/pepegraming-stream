event_store = []
event_store << { name: 'add item', payload: { cost: 4, order_id: 1 } }
event_store << { name: 'add item', payload: { cost: 10, order_id: 1 } }
event_store << { name: 'add item', payload: { cost: 7, order_id: 1 } }

event_store << { name: 'add item', payload: { cost: 11, order_id: 2 } }

# p event_store # => list of events

order_total_cost = 0 # initial state

event_store.each do |event|
  if event[:payload][:order_id] == 1
    order_total_cost = order_total_cost + event[:payload][:cost]
  end
end

order_items_total_count = 0 # initial state

event_store.each do |event|
  if event[:name] == 'add item'
    order_items_total_count += 1
  end
end

puts "Total cost for order #1 - #{order_total_cost}"
puts "Order #1 has #{order_items_total_count} items"

event_store << { name: 'add item', payload: { cost: -3, order_id: 1 } }

order_total_cost = 0 # initial state

event_store.each do |event|
  if event[:payload][:order_id] == 1
    order_total_cost = order_total_cost + event[:payload][:cost]
  end
end

order_items_total_count = 0 # initial state

event_store.each do |event|
  if event[:name] == 'add item'
    order_items_total_count += 1
  end
end

puts "Total cost for order #1 - #{order_total_cost}"
puts "Order #1 has #{order_items_total_count} items"


# event sourcing:
#   works with events
#   no state (no DB tables)
#   get event and store it
#
# event driven arch:
#   works with events
#   get event and handle it or say about it
#   we have a state - DB
#   
