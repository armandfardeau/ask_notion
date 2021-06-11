require "crest"
require "json"

HOST                = ENV["HOST"]?.try(&.to_s) || "0.0.0.0"
PORT                = ENV["PORT"]?.try(&.to_i) || 8080
NOTION_API_KEY      = ENV["NOTION_API_KEY"]?.try(&.to_s) || ""
ROCKET_SECRET_TOKEN = ENV["ROCKET_SECRET_TOKEN"]?.try(&.to_s) || ""

server = HTTP::Server.new do |context|
  # Get question from rocketchat
  body = JSON.parse(context.request.body.not_nil!.gets_to_end)["body"]

  if check_rocket_token(body["token"], ROCKET_SECRET_TOKEN)
    puts "An unauthorized access has been recorded from #{context.request.remote_address} with #{body["token"]}"
    context.response.respond_with_status(401, "Unauthorized")
  else
    # Check notion search for response
    request = search_in_notion(body["text"])

    context.response.respond_with_status(200, request.body)
    #     if empty, create a page and return the link
    #     if not empty return the first 5 responses
  end
end

def check_rocket_token(params_token, env_token)
  params_token != env_token
end

def search_in_notion(text)
  Crest::Request.execute(:post,
    "https://api.notion.com/v1/search",
    headers: {
      "Content-Type"   => "application/json",
      "Notion-Version" => "2021-05-13",
      "Authorization"  => NOTION_API_KEY,
    },
    form: {
      "query" => text,
      "sort":    {
        "direction" => "ascending",
        "timestamp" => "last_edited_time",
      },
    }.to_json
  )
end

address = server.bind_tcp(HOST, PORT)

puts "Listening on http://#{address}"
server.listen
