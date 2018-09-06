this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'rpcbench_services_pb'

def main
  stub = Rpcbench::Database::Stub.new("#{ARGV[0]}:50051", :this_channel_is_insecure)

  photo = ARGV[1] == "true" ? true : false
  startid = ARGV[2].to_i
  endid = ARGV[3].to_i
  if startid >= 0
    (startid..endid).each do |i|
      stub.request(Rpcbench::InfoRequest.new(id: i, photo: photo))
    end
  else
    stub.request_all(Rpcbench::InfoListRequest.new(photo: photo))
  end
end

main
