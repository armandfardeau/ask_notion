require "http/server"
require "json"

HOST = ENV.has_key?("HOST") ? ENV["HOST"] : "0.0.0.0"
PORT = ENV.has_key?("PORT") ? ENV["PORT"].to_i : 8080

server = HTTP::Server.new do |context|
  params = context.request.query_params

  context.response.content_type = "application/json"
  req = context.request.body.not_nil!.gets_to_end == "" ? "No request" : JSON.parse(context.request.body.not_nil!.gets_to_end)

  puts req
  context.response.print(req.to_json)
end

address = server.bind_tcp(HOST, PORT)

puts "Listening on http://#{address}"
server.listen
