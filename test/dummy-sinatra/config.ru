$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require "mountable_processing_server/endpoint"

run MountableProcessingServer::Endpoint.new('uploads')
