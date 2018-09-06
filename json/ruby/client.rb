require 'base64'

require 'net/http'
require 'net/http/post/multipart'

require 'jsonrpc2.0'

class RpcBenchClient < JsonRpcClient
  def initialize(endpoint)
    @uri = URI(endpoint)
    @http = Net::HTTP.start(@uri.host, @uri.port)
  end

  def send_request(data)
    req = Net::HTTP::Post.new(@uri.path, {'Content-Type': 'application/json'})
    req.body = data
    res = @http.request(req)
    res.body
  end
end

def main
  client = RpcBenchClient.new("http://#{ARGV[0]}:50051/RPC2")

  photo = ARGV[1] == "true" ? true : false
  startid = ARGV[2].to_i
  endid = ARGV[3].to_i

  (startid..endid).each do |i|
    req = client.fire_request("request", i, photo)
    req["photo"] = Base64.strict_decode64(req["photo"]) if photo
  end
end

main
