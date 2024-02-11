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
    result = `tctl nodes ls --format=json --identity=#{@identity_file} --auth-server=#{@auth_server} #{labels_filter}`
    raise AccessError.new(result) unless $?.exitstatus == 0
    MultiJson.load(result)
  rescue MultiJson::ParseError => e
    raise ResponseError.new(e)
  end
end
