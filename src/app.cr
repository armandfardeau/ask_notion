require "kemal"

PORT = ENV.has_key?("PORT") ? ENV["PORT"].to_i : 8080

Kemal.config.port = PORT

post "/" do
  # TODO: Get question from rocketchat
  # TODO: Check notion search for response
  #     if empty, create a page and return the link
  #     if not empty return the first 5 responses
end

Kemal.run
