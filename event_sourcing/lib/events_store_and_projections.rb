require 'pp'

class Main
end

# * event - событие которое произошло в прошлом
# * event store - место где лежат эвенты
# * projection - штука, которая "собирает" стейт
#
# * producer - абстракция, которая создает эвенты


# event
#   было в прошлом
#   data object
#   обязательно имя и данные
#   может быть чем угодно, хешом, структурой, etc

module Events
  class Base
    attr_reader :payload

    def initialize(payload:)
      @payload = Hash(payload)
    end
  end

  # Order logic

  class OrderCreated < Base; end
  class OrderClosed < Base; end
  class ItemAddedToOrder < Base; end
  class ItemRemovedFromOrder < Base; end
  class OrderCheckouted < Base; end
end

# event store
#   imuttable
#
#   interface:
#     * get (nil -> list of events)
#     * append (list of events -> nil)

class EventStore
  def initialize
    # { stream => [...] }
    @store = {}
  end

  def get
    @store.flat_map { |stream, events| events }
  end

  def get_stream(stream)
    @store[stream] || []
  end

  def append(stream, *events)
    @store[stream] ||= []

    events.each { |event| @store[stream] << event }
  end

  def evolve(stream, producer, payload)
    events = get_stream(stream)

    new_events = producer.call(events, payload)
    @store[stream] = (@store[stream] || []) + new_events
  end
end

# projection
#   pure function
#
#   f(g, initial_state, event_list) -> state
#   f(g, state, event_list) -> new state
#
#   f -> project
#   g -> projection
#
#   project(projection, initial_state, event_list) -> state

module Projections
  class Project
    def call(projection, initial_state, events)
      events.reduce(initial_state) { |state, event| projection.call(state, event) }
    end
  end

  class AllOrders
    def call(state, event)
      case event
      when Events::OrderCreated
        state[:orders] ||= []
        state[:orders] << { **event.payload, items: [] }
      when Events::ItemAddedToOrder
        order = state[:orders].select { |o| o[:order_id] == event.payload[:order_id] }.first
        state[:orders].delete_if { |o| o[:order_id] == event.payload[:order_id] }.first

        order[:items] << event.payload
        state[:orders] << order
      end

      state
    end
  end

  class CostForOrders
    def call(state, event)
      case event
      when Events::OrderCreated
        state[:order_costs] ||= {}
        state[:order_costs][event.payload[:order_id]] = 0
      when Events::ItemAddedToOrder
        state[:order_costs][event.payload[:order_id]] += event.payload[:cost]
      end

      state
    end
  end
end


########################################

# event_store = EventStore.new
# project = Projections::Project.new
#
# # puts 'Initial state:'
# events = event_store.get
# project.call(Projections::AllOrders.new, {}, events)
#
# # puts 'After creating order:'
# event = Events::OrderCreated.new(payload: { order_id: 1, account_id: 1 })
# event_store.append(event)
#
# events = event_store.get
# project.call(Projections::AllOrders.new, {}, events)
#
# # puts 'After creating one more order:'
# event = Events::OrderCreated.new(payload: { order_id: 2, account_id: 1 })
# event_store.append(event)
#
# events = event_store.get
# project.call(Projections::AllOrders.new, {}, events)

########################################

# event_store = EventStore.new
# project = Projections::Project.new
#
# puts 'After creating order:'
# event = Events::OrderCreated.new(payload: { order_id: 1, account_id: 1 })
# event_store.append(event)
#
# yesterdays_events = event_store.get
# yesterdays_orders = project.call(Projections::AllOrders.new, {}, yesterdays_events)
#
#
# puts 'After creating one more order:'
# event_store = EventStore.new
#
# event = Events::OrderCreated.new(payload: { order_id: 2, account_id: 1 })
# event_store.append(event)
#
# events = event_store.get
# p project.call(Projections::AllOrders.new, yesterdays_orders, events)

########################################
  # class ItemAddedToOrder < Base; end
  # class ItemRemovedFromOrder < Base; end

# events:
#
#   OrderCreated
#   OrderClosed
#   ItemAddedToOrder
#   ItemRemovedFromOrder
#   OrderCheckouted

# event_store = EventStore.new
# project = Projections::Project.new
#
# event = Events::OrderCreated.new(payload: { order_id: 1, account_id: 1 })
# event_store.append(event)
#
# event = Events::OrderCreated.new(payload: { order_id: 2, account_id: 2 })
# event_store.append(event)
#
# events = event_store.get
# pp project.call(Projections::AllOrders.new, {}, events)
#
# puts '*' * 80
#
# event = Events::ItemAddedToOrder.new(payload: { order_id: 1, item_id: 1, name: 'ruby sticker', cost: 10 })
# event_store.append(event)
#
# event = Events::ItemAddedToOrder.new(payload: { order_id: 1, item_id: 2, name: 'git sticker', cost: 17 })
# event_store.append(event)
#
# event = Events::ItemAddedToOrder.new(payload: { order_id: 2, item_id: 3, name: 'ruby sticker', cost: 11 })
# event_store.append(event)
#
# events = event_store.get
# pp project.call(Projections::AllOrders.new, {}, events)
#
# puts '*' * 80
#
# pp project.call(Projections::CostForOrders.new, {}, events)

####################################################################

require 'securerandom'

module Producers
  class AddItem
    def initialize
      @project = Projections::Project.new
    end

    # payload:
    #   account_id
    #   name
    #   cost
    def call(events, payload)
      state = @project.call(Projections::AllOrders.new, {}, events)
      order_for_account = state[:orders]&.first

      if order_for_account
        [
          Events::ItemAddedToOrder.new(
            payload: {
              order_id: order_for_account[:order_id], item_id: SecureRandom.uuid, name: payload[:name], cost: payload[:cost]
            }
          )
        ]
      else
        order_id = SecureRandom.uuid

        [
          Events::OrderCreated.new(
            payload: { order_id: order_id, account_id: payload[:account_id] }
          ),
          Events::ItemAddedToOrder.new(
            payload: {
              order_id: order_id, item_id: SecureRandom.uuid, name: payload[:name], cost: payload[:cost]
            }
          )
        ]
      end
    end
  end
end

event_store = EventStore.new
project = Projections::Project.new

events = event_store.get
pp project.call(Projections::AllOrders.new, {}, events)

puts '*' * 80

event = Events::OrderCreated.new(payload: { order_id: SecureRandom.uuid, account_id: 1 })
event_store.append(1, event)

event_store.evolve(1, Producers::AddItem.new, account_id: 1, name: 'ruby sticker', cost: 10)


event_store.evolve(2, Producers::AddItem.new, account_id: 2, name: 'hanami sticker', cost: 5)
event_store.evolve(2, Producers::AddItem.new, account_id: 2, name: 'ruby sticker', cost: 15)

events = event_store.get
pp project.call(Projections::AllOrders.new, {}, events)

puts '*' * 80

events = event_store.get_stream(1)
pp project.call(Projections::AllOrders.new, {}, events)

events = event_store.get_stream(2)
pp project.call(Projections::AllOrders.new, {}, events)

####################################################################

# [
#   create order #stream=1
#   add item #stream=1
#   add item #stream=1
#   remove item #stream=1
#   checkout #stream=1
#
#   create order #stream=2
#   add item #stream=2
#   checkout #stream=2
# ]
