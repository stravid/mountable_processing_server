require "sinatra/base"
require "mini_magick"
require "pathname"
require "rack"
require "tempfile"

module MountableProcessingServer
  class Endpoint < Sinatra::Base
    def initialize(source_directory)
      @source_directory = Pathname.new source_directory
      super
    end

    get "/:file" do
      original = Pathname.new params["file"]

      image = MiniMagick::Image.open @source_directory + original

      if params["frame"]
        # Currently to expensive for large GIFs
        # image = image.coalesce
        frame = image.frames[params["frame"].to_i]

        Tempfile.open "frame" do |file|
          frame.write file.path
          image = MiniMagick::Image.open file.path
        end
      end

      if params["resize"]
        image.resize params["resize"]
      end

      if params["watermark"]
        watermark = MiniMagick::Image.open params["watermark"]

        image = image.composite(watermark, 'png') do |composite|
          composite.geometry "+10+10"
        end
      end

      content_type(Rack::Mime::MIME_TYPES.fetch(original.extname, 'text/plain'))
      image.to_blob.to_s
    end
  end
end
