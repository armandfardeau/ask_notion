require "kemal"

PORT = ENV.has_key?("PORT") ? ENV["PORT"].to_i : 8080

Kemal.config.port = PORT

post "/" do
  "Hello World!"
end

Kemal.run
