this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'active_support/core_ext/hash'
require 'csv'
require 'pathname'

require 'grpc'
require 'rpcbench_services_pb'

Entry = Struct.new(
  :id,
  :first_name,
  :last_name,
  :age,
  :email,
  :phone,
  :newsletter,
  :latitude,
  :longitude,
  :photo
)

DB = Struct.new(:entries)

def TrueOrFalse answer
  if answer == true || answer == false
    answer
  elsif answer == "true"
    true
  elsif answer == "false"
    false
  else
    answer
  end
end

class RpcbenchServer < Rpcbench::Database::Service
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def request(info_req, _unused_call)
    info = @data.entries[info_req.id]
    Rpcbench::Info.new(
      id: info.id,
      first_name: info.first_name,
      last_name: info.last_name,
      age: info.age,
      email: info.email,
      phone: info.phone,
      newsletter: info.newsletter,
      latitude: info.latitude,
      longitude: info.longitude,
      photo: info_req.photo ? info.photo : ""
    )
  rescue Exception => e
    STDERR.puts e.message
    STDERR.puts e.backtrace
  end

  def request_all(info_list_req, _unused_call)
    list = Rpcbench::InfoList.new
    @data.entries.each do |id, info|
      list.infos << Rpcbench::Info.new(
        id: info.id,
        first_name: info.first_name,
        last_name: info.last_name,
        age: info.age,
        email: info.email,
        phone: info.phone,
        newsletter: info.newsletter,
        latitude: info.latitude,
        longitude: info.longitude,
        photo: info_list_req.photo ? info.photo : ""
      )
    end
    list
  rescue Exception => e
    STDERR.puts e.message
    STDERR.puts e.backtrace
  end
end

def readDB(dbpath)
  data = DB.new({})
  trueFalseLambda = lambda { |x| TrueOrFalse x }
  CSV.foreach(dbpath, headers: :first_row, converters: [:numeric, trueFalseLambda]) do |row|
    id = row['id'].to_i
    entry = Entry.new(
      *row.to_hash.symbolize_keys.values_at(*Entry.members)
    )
    entry.photo = IO.binread(Pathname.new(ARGV[0]).dirname + "img#{id.to_s.rjust(4, '0')}.png")
    data.entries[id] = entry
  end
  data
end

def main
  raise ArgumentError.new('Provide input CSV') unless ARGV.size > 0

  puts "Reading DB..."

  db = readDB(ARGV[0])

  puts "Creating server..."

  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
  s.handle(RpcbenchServer.new(db))

  puts "Server listening on 50051"

  s.run_till_terminated
end

main

