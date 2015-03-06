require 'iron_mq'
require 'iron_worker_ng'

@ironmq = IronMQ::Client.new()
@worker = IronWorkerNG::Client.new
@all_hotels_queue = @ironmq.queue("all_hotels")


def number_cycles
  @all_hotels_queue.size / 50 > 0 ? @all_hotels_queue.size / 50 : 1
end

def queue_db_update_workers(cities)
  cities.each do |name|
    @worker.tasks.create("update_internal_inventory", {city: name})
  end
end

def fan_out_messages(messages)
  messages.each do |m|  
    m_body = m.body
    hotel_data = JSON.parse(m_body)
    new_queue = @ironmq.queue("#{hotel_data['city']}-hotels")
    new_queue.post(m_body)
    m.delete
  end
end

number_cycles.times do
  messages = @all_hotels_queue.get(n: 50)
  fan_out_messages(messages)
end

queue_db_update_workers(["LAS", "LAX" ,"NYC","SFO", "DCA"])
