gem 'iron_mq'
require 'iron_mq'
require 'iron_worker_ng'

ironmq = IronMQ::Client.new()
worker = IronWorkerNG::Client.new
@all_hotels_queue = ironmq.queue("all_hotels")
@city = ["LAS", "LAX" ,"NYC","SFO", "DCA"]
@hotels = ["Hilton", "Hyatt" ,"Ritz", "W"]

def price_update #create dummy data
  messages = []
  ARGV[0].to_i.times do
   messages << {:body => JSON.generate({:city => "#{@city.sample}",:hotel => "#{@hotels.sample}",:room_price => "#{rand(0..100)}"})}
 end
 messages
end

def queue_inventory #batch post messages to IronMQ
 @all_hotels_queue.post(price_update) 
end


############# RUN RUN RUN! ################
# ARGV[0] == inventory available to update
queue_inventory

worker.tasks.create("retreive_pricing_availability_options") #begin the processing
