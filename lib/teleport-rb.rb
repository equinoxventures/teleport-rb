require 'multi_json'

class TeleportRb
  class Error < StandardError; end;
  class AccessError < Error; end;
  class ResponseError < Error; end;

  def initialize auth_server:
    @auth_server = auth_server
  end

  def nodes labels={}
    labels_filter = labels.entries.map{|k, v| "#{k}=#{v}"}.join(' ')
    result = `tctl nodes ls --format=json --auth-server=#{@auth_server} #{labels_filter}`
    raise AccessError.new(result) unless $?.exitstatus == 0
    MultiJson.load(result)
  rescue MultiJson::ParseError => e
    raise ResponseError.new(e)
  end
end
