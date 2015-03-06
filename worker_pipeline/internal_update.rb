require 'iron_mq'
require 'aws/s3'
require 'csv'

puts "Connecting to MQ"
ironmq = IronMQ::Client.new()
puts "Connecting to s3"
AWS::S3::Base.establish_connection!(
  access_key_id: config[:amazon][:access_key],
  secret_access_key: config[:amazon][:secret_key]
  )

@queue = ironmq.queue("#{params[:city]}-hotels")

CSV.open("#{params[:city]}-hotels.csv", "wb") do |csv|
  csv << ["city", "hotel", "room_price"]
end

def number_cycles
  @queue.size / 100 > 0 ? queue.size / 100 : 1
end

number_cycles.times do 
  messages = @queue.get(n: 100)
  messages.each do |m|  
    m_body = m.body
    p 'hotel data:'
    p hotel_data = JSON.parse(m_body)
    CSV.open("#{params[:city]}-hotels.csv", "a+") do |csv|
      csv << hotel_data.values
    end
    m.delete  
  end
end

puts "Uploading to s3" if AWS::S3::S3Object.store("#{params[:city]}-hotels.csv", open("#{params[:city]}-hotels.csv"), config[:amazon][:bucket])
