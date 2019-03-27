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
    @store = []
  end

  def get
    @store
  end

  def append(*events)
    events.each { |event| @store << event }
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

event_store = EventStore.new
project = Projections::Project.new

# puts 'Initial state:'
events = event_store.get
project.call(Projections::AllOrders.new, {}, events)

# puts 'After creating order:'
event = Events::OrderCreated.new(payload: { order_id: 1, account_id: 1 })
event_store.append(event)

events = event_store.get
project.call(Projections::AllOrders.new, {}, events)

# puts 'After creating one more order:'
event = Events::OrderCreated.new(payload: { order_id: 2, account_id: 1 })
event_store.append(event)

events = event_store.get
project.call(Projections::AllOrders.new, {}, events)

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

event_store = EventStore.new
project = Projections::Project.new

event = Events::OrderCreated.new(payload: { order_id: 1, account_id: 1 })
event_store.append(event)

event = Events::OrderCreated.new(payload: { order_id: 2, account_id: 2 })
event_store.append(event)

events = event_store.get
pp project.call(Projections::AllOrders.new, {}, events)

puts '*' * 80

event = Events::ItemAddedToOrder.new(payload: { order_id: 1, item_id: 1, name: 'ruby sticker', cost: 10 })
event_store.append(event)

event = Events::ItemAddedToOrder.new(payload: { order_id: 1, item_id: 2, name: 'git sticker', cost: 17 })
event_store.append(event)

event = Events::ItemAddedToOrder.new(payload: { order_id: 2, item_id: 3, name: 'ruby sticker', cost: 11 })
event_store.append(event)

events = event_store.get
pp project.call(Projections::AllOrders.new, {}, events)

puts '*' * 80

pp project.call(Projections::CostForOrders.new, {}, events)
