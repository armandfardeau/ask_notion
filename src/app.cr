require "kemal"
require "crest"

HOST                = ENV["HOST"]?.try(&.to_s) || "0.0.0.0"
PORT                = ENV["PORT"]?.try(&.to_i) || 8080
NOTION_API_KEY      = ENV["NOTION_API_KEY"]?.try(&.to_s) || ""
ROCKET_SECRET_TOKEN = ENV["ROCKET_SECRET_TOKEN"]?.try(&.to_s) || ""
NOTION_URL          = ENV["NOTION_URL"]?.try(&.to_s) || ""
NOTION_SEARCH_URL   = "https://api.notion.com/v1/search"
ROCKET_CHAT_URL     = "https://osp.rocket.chat"
ROCKET_API_TOKEN    = ENV["ROCKET_API_TOKEN"]?.try(&.to_s) || ""
ROCKET_API_ID       = ENV["ROCKET_API_ID"]?.try(&.to_s) || ""

Kemal.config.port = PORT
Kemal.config.env = "production"

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
    halt env, status_code: 200, response: "tmid provided, doing nothing" if body["tmid"]?

    # Check notion search for response
    request = search_in_notion(body["text"])
    room_id = body["channel_id"]
    message_id = body["message_id"]

    results = JSON.parse(request.body)["results"].as_a

    if results.empty?
      Log.info { "Empty results for #{body["text"]}" }
      halt env, status_code: 200, response: "Empty response for #{body["text"]}"
    else
      responses = Array(Crest::Response).new
      results.each do |result|
        responses << send_to_rocket(room_id, message_id, message_builder(result))
      end

      returned_responses = responses.map { |response| JSON.parse(response.body) }.to_json
      Log.info { "Returned_responses: #{returned_responses}" }
      halt env, status_code: 200, response: returned_responses
    end
  end
end

def check_rocket_token(params_token, env_token)
  params_token != env_token
end

def send_to_rocket(room_id, message_id, message)
  Log.info { message.to_json }

  Crest::Request.execute(:post,
    "#{ROCKET_CHAT_URL}/api/v1/chat.sendMessage",
    headers: {
      "Content-Type" => "application/json",
      "X-Auth-Token" => ROCKET_API_TOKEN,
      "X-User-Id"    => ROCKET_API_ID,
    },
    form: {
      "message": {
        "rid":         room_id,
        "tmid":        message_id,
        "alias":       "AskNotion",
        "avatar":      "https://upload.wikimedia.org/wikipedia/commons/4/45/Notion_app_logo.png",
        "attachments": [{
          "title":      message["title"],
          "title_link": message["link"],
          "collapsed":  false,
        }],
      },
    }.to_json
  )
end

def search_in_notion(text)
  Crest::Request.execute(:post,
    NOTION_SEARCH_URL,
    headers: {
      "Content-Type"   => "application/json",
      "Notion-Version" => "2021-05-13",
      "Authorization"  => NOTION_API_KEY,
    },
    form: {
      "query"   => text,
      "page_size": 5,
      "sort":      {
        "direction" => "ascending",
        "timestamp" => "last_edited_time",
      },
    }.to_json
  )
end

def message_builder(result)
  text = result["properties"]["title"]["title"][0]["plain_text"]
  id = result["id"].as_s.gsub("-", "")

  {title: text, link: "#{NOTION_URL}/#{id}"}
end

Kemal.run do |config|
  server = config.server.not_nil!
  server.bind_tcp HOST, PORT, reuse_port: true
end
