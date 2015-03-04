start_time = Time.now

require "iron_worker_ng"
require "aws/s3"
client = IronWorkerNG::Client.new(token: 'FILL ME IN',
  project_id: 'FILL ME IN')

puts "Connecting to s3"
puts AWS::S3::Base.establish_connection!(
  access_key_id: config[:amazon][:access_key],
  secret_access_key: config[:amazon][:secret_key]
)

bucket_name = params[:bucket]
raw_photos_in_bucket = AWS::S3::Bucket.objects(bucket_name)
@photo_urls = []
options = {cluster: 'mem1', priority: 2}

def file_to_url(bucket_name, file)
  "https://s3.amazonaws.com/#{bucket_name}/#{file}"
end

############## Process Images! ###############
raw_photos_in_bucket.each do |obj|
  @photo_urls << file_to_url(bucket_name, obj.key)
end
slaves_launched = 0
while @photo_urls.length > 0
  payload = {bucket: bucket_name, image_url: @photo_urls.first, photo_name: "#{raw_photos_in_bucket[slaves_launched].key}"}
  client.tasks.create("image_alteration_slave", payload, options)
  slaves_launched += 1
  @photo_urls.shift
end
puts "Cycle over. spun up #{slaves_launched} slaves."
