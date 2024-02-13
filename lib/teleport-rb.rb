require 'open3'
require 'multi_json'

class TeleportRb
  class Error < StandardError; end;
  class AccessError < Error; end;
  class ResponseError < Error; end;

  def initialize auth_server:, identity_file:
    @auth_server = auth_server
    @identity_file = identity_file
  end

  def nodes labels={}
    labels_filter = labels.entries.map{|k, v| "#{k}=#{v}"}.join(' ')
    command = "tctl nodes ls --format=json --identity=#{@identity_file} --auth-server=#{@auth_server} #{labels_filter}"
    stdout, stderr, status = Open3.capture3(command)
    raise AccessError.new(stderr) unless status == 0
    MultiJson.load(stdout)
  rescue MultiJson::ParseError => e
    raise ResponseError.new(e)
  end
end
