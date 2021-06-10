require "http/server"
require "json"

HOST = ENV.has_key?("HOST") ? ENV["HOST"] : "0.0.0.0"
PORT = ENV.has_key?("PORT") ? ENV["PORT"].to_i : 8080

server = HTTP::Server.new do |context|
  params = context.request.query_params

  context.response.content_type = "application/json"
  context.response.print(params)
end

address = server.bind_tcp(HOST, PORT)

puts "Listening on http://#{address}"
server.listen
