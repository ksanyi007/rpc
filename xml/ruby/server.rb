this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'active_support/core_ext/hash'
require 'csv'
require 'pathname'

require 'xmlrpc/server'

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

class RpcbenchServer
  attr_reader :data
  attr_reader :xmlrpc

  def initialize(data)
    @data = data

    @xmlrpc = XMLRPC::Server.new(50051, "0.0.0.0")

    @xmlrpc.add_handler("database.request") do |id, photo|
      begin
        info = @data.entries[id]
        res = {}
        res[:id] = info.id
        res[:first_name] = info.first_name
        res[:last_name] = info.last_name
        res[:age] = info.age
        res[:phone] = info.phone
        res[:newsletter] = info.newsletter
        res[:latitude] = info.latitude
        res[:longitude] = info.longitude
        res[:photo] = XMLRPC::Base64.encode(info.photo) if photo
        res
      rescue Exception => e
        STDERR.puts e.message
        STDERR.puts e.backtrace
      end
    end

    @xmlrpc.set_default_handler do |name, *args|
      raise XMLRPC::FaultException.new(
        -99,
        "Method #{name} missing or wrong number of parameters!")
    end
  end

  def serve
    @xmlrpc.serve
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
  server = RpcbenchServer.new(db)
  puts "Server listening on 50051"
  server.serve
end

main
