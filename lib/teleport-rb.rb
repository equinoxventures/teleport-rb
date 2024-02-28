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

  private

  def execute_command command, handle_json_errors: true
    stdout, stderr, status = Open3.capture3(command)
    if handle_json_errors
      begin
        MultiJson.load(stdout)
      rescue MultiJson::ParseError => e
        raise ResponseError.new(e)
      end
    else
      raise Error.new("Command failed with status #{status} and stderr:\n#{stderr}") unless status == 0
      puts stdout
    end
  end

  public

  def nodes labels: {}
    labels_filter = labels.entries.map{|k, v| "#{k}=#{v}"}.join(' ')
    command = "tctl nodes ls --format=json --identity=#{@identity_file} --auth-server=#{@auth_server} #{labels_filter}"
    execute_command(command)
  end

  def generate_token type:, ttl: 3600, labels: {}
    labels_filter = labels.entries.map{|k, v| "#{k}=#{v}"}.join(' ')
    command = "tctl tokens add --type=#{type} --format=json --identity=#{@identity_file} --auth-server=#{@auth_server} #{labels_filter}"
    execute_command(command)
  end

  def list_tokens labels: {}
    labels_filter = labels.entries.map{|k, v| "#{k}=#{v}"}.join(' ')
    command = "tctl tokens ls --format=json --identity=#{@identity_file} --auth-server=#{@auth_server} #{labels_filter}"
    execute_command(command)
  end

  def configure_host roles:, token:, proxy:, nodes_labels: {}
    labels_filter = nodes_labels.entries.map{|k, v| "#{k}=#{v}"}.join(',')
    roles_string = roles.join(',')
    command = "teleport configure --roles=#{roles_string} --token=#{token} --proxy=#{proxy} --node-labels #{labels_filter} -o file"
    execute_command(command, handle_json_errors: false)
  end
end