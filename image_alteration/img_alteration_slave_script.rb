RMAGICK_BYPASS_VERSION_TEST = true
require 'aws/s3'
require 'base64'
require 'benchmark'
require 'json'
require 'mini_magick'
require 'rmagick'
include Magick
require 'thwait'

puts "Connecting to s3"
AWS::S3::Base.establish_connection!(
  access_key_id: config[:amazon][:access_key],
  secret_access_key: config[:amazon][:secret_key]
  )
p @bucket_name = params[:bucket]
p @image_url = params[:image_url]
p @image_name = params[:photo_name][0..-5]
p @extension = File.extname(@image_url)

puts Benchmark.measure {

  def colortone_pink(image_url, level = 100, type = 0)
    color = "#ff59f6"
    image = MiniMagick::Image.open(image_url)
    color_img = image.clone
    color_img.combine_options do |cmd|
     cmd.fill color
     cmd.colorize '63%'
    end

   final_image = image.composite color_img do |cmd|
     cmd.compose 'blend'
     cmd.define "compose:args=#{level},#{100-level}"
   end
   f = final_image.write("./04-#{@image_name}-#{__method__}#{@extension}")
  end

  def transformation(image_url)
    @transform_threads = []
    [50,250,500,1000 ].each do |n|
      image = MiniMagick::Image.open(image_url)
      image.resize "#{n}x#{n}"
      image.format("png")
      if n == 50
        image.write("./08-#{@image_name}-thumbnail-#{n}x#{n}#{@extension}")
      elsif n == 250
        image.write("./09-#{@image_name}-small-#{n}x#{n}#{@extension}")
      elsif n == 500
        image.write("./10-#{@image_name}-medium-#{n}x#{n}#{@extension}")
      elsif n == 1000
        image.write("./11-#{@image_name}-large-#{n}x#{n}#{@extension}")
      else
        p"nope"
      end
    end
  end

  image = MiniMagick::Image.open(@image_url)
  image.write("./13-#{@image_name}-original-#{@extension}")

  Thread.new do
    colortone_pink(@image_url)
  end

  p "$$$$$ transformation benchmark"
  puts Benchmark.measure {
    transformation(@image_url)
  }
}

@threads = []

p "$$$$$ UPLOAD benchmark"
puts Benchmark.measure {
  (Dir["*.png"]+ Dir["*.zip"] + Dir["*.pdf"] + Dir["*.jpg"] + Dir["*.jpeg"]+ Dir["*.gif"]).each do |image|
    if image.match(/me\.jpeg/) || image.match(/_task_code\.zip/)
      p "ignore source"
    else
      @threads << Thread.new do
        p "uploading image #{image} to s3"
        AWS::S3::S3Object.store("#{@image_name}/#{image}", open(image), @bucket_name)
      end
    end
  end

  ThreadsWait.all_waits(@threads)
  p "uploading DONE"
}
