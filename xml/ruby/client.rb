require 'xmlrpc/client'

def main
  server = XMLRPC::Client.new(ARGV[0], "/RPC2", 50051)

  photo = ARGV[1] == "true" ? true : false
  startid = ARGV[2].to_i
  endid = ARGV[3].to_i

  (startid..endid).each do |i|
    server.call("database.request", i, photo)
  end
end

main
