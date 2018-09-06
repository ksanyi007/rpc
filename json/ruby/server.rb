require 'active_support/core_ext/hash'

require 'csv'
require 'pathname'

require 'webrick'
require 'jsonrpc2.0'
require 'base64'

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

class RpcbenchServer < JsonRpcServer
  attr_reader :data

  def initialize(data)
    @data = data
  end

  private

  def r_request(id, photo)
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
    res[:photo] = Base64.strict_encode64(info.photo) if photo

    res
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
  wserver = WEBrick::HTTPServer.new :Port => 50051
  trap 'INT' do wserver.shutdown end
  wserver.mount_proc '/RPC2' do |req, res|
    begin
      jsonres = server.handle_message(req.body)
      res.status = 200
      res['Content-Type'] = 'application/json'
      res.body = jsonres
    rescue Exception => e
      STDERR.puts e.message
      STDERR.puts e.backtrace
    end
  end

  puts "Server listening on 50051"
  wserver.start
rescue Exception => e
  STDERR.puts e.message
  STDERR.puts e.backtrace
end

main
