require "kemal"
require "crest"

HOST                = ENV["HOST"]?.try(&.to_s) || "0.0.0.0"
PORT                = ENV["PORT"]?.try(&.to_i) || 8080
NOTION_ENDPOINT     = ENV["NOTION_ENDPOINT"]?.try(&.to_s) || "https://api.notion.com/v1/search"
NOTION_API_KEY      = ENV["NOTION_API_KEY"]?.try(&.to_s) || ""
ROCKET_SECRET_TOKEN = ENV["ROCKET_SECRET_TOKEN"]?.try(&.to_s) || ""

# Configuration
Kemal.config.port = PORT
Kemal.config.env = "production"
serve_static false

before_all "/" do |env|
  env.response.content_type = "application/json"
end

post "/" do |env|
  # Get question from rocketchat
  body = env.params.json["body"].as(Hash(String, JSON::Any))

  if check_rocket_token(body["token"], ROCKET_SECRET_TOKEN)
    Log.info { "An unauthorized access has been recorded from #{env.request.remote_address} with #{body["token"]}" }
    halt env, status_code: 401, response: "Unauthorized"
  else
    # Check notion search for response
    request = search_in_notion(body["text"])

    request.body
    #     if empty, create a page and return the link
    #     if not empty return the first 5 responses
  end
end

def check_rocket_token(params_token, env_token)
  params_token != env_token
end

def search_in_notion(text)
  begin
    Crest::Request.execute(:post,
      NOTION_ENDPOINT,
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
  rescue ex : Crest::NotFound | Crest::Unauthorized
    ex.response
  end
end

Kemal.run do |config|
  server = config.server.not_nil!
  server.bind_tcp HOST, PORT, reuse_port: true
end
