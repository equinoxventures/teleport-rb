require 'open3'
require 'multi_json'

class TeleportRb
  class Error < StandardError; end;
  class AccessError < Error; end;
  class ResponseError < Error; end;

  def initialize auth_server:, identity_file:, proxy:
    @auth_server = auth_server
    @identity_file = identity_file
    @proxy = proxy

  end

  def nodes labels: {}
    command = "tctl nodes ls --format=json --identity=#{@identity_file} --auth-server=#{@auth_server} #{stringify_labels(labels)}"
    execute_json_command(command)
  end

  def generate_token(type:, ttl: 3600, labels: {})
    labels_argument = labels.empty? ? "" : "--labels=#{stringify_labels(labels)}"
    command = "tctl tokens add --type=#{type} --format=json --identity=#{@identity_file} --auth-server=#{@auth_server} #{labels_argument}"
    execute_json_command(command)
  end

  def list_tokens
    command = "tctl tokens ls --format=json --identity=#{@identity_file} --auth-server=#{@auth_server}"
    execute_json_command(command)
  end

  def list_nodes_via_labels labels: {}
    command = "tsh --proxy=#{@proxy} --identity=identity ls --format=json #{stringify_labels(labels)}"
    execute_json_command(command)
  end

  def configure_host roles:, token:, nodes_labels: {}
    roles_string = roles.join(',')
    labels = nodes_labels.empty? ? "" : "--node-labels #{stringify_labels(nodes_labels)}"
    command = "teleport configure --roles=#{roles_string} --token=#{token} --proxy=#{@proxy} #{labels} -o file"
    execute_command(command)
  end

  private

  def execute_json_command command
    json, _, _ = execute_command(command)
    MultiJson.load(json)
  rescue MultiJson::ParseError => e
    raise ResponseError.new(e)
  end

  def execute_command command
    stdout, stderr, status = Open3.capture3(command)
    raise Error.new("Command: #{command} failed with status #{status} and stderr:\n#{stderr}") unless status == 0
    return stdout, stderr, status
  end

  def stringify_labels labels={}
    labels.entries.map{|k, v| "#{k}=#{v}"}.join(',')
  end
end
