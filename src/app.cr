require "kemal"
require "crest"

HOST                 = ENV["HOST"]?.try(&.to_s) || "0.0.0.0"
PORT                 = ENV["PORT"]?.try(&.to_i) || 8080
NOTION_API_KEY       = ENV["NOTION_API_KEY"]?.try(&.to_s) || ""
ROCKET_SECRET_TOKEN  = ENV["ROCKET_SECRET_TOKEN"]?.try(&.to_s) || ""
NOTION_URL           = ENV["NOTION_URL"]?.try(&.to_s) || ""
NOTION_SEARCH_URL    = "https://api.notion.com/v1/search"
NOTION_PAGE_URL      = "https://api.notion.com/v1/pages"
ROCKET_CHAT_URL      = "https://osp.rocket.chat"
ROCKET_API_TOKEN     = ENV["ROCKET_API_TOKEN"]?.try(&.to_s) || ""
ROCKET_API_ID        = ENV["ROCKET_API_ID"]?.try(&.to_s) || ""
PAGE_PARENT_ID       = "639e6e8d-73ab-45c8-a1b0-bf829d17c5e4"
CREATED_PAGE_MESSAGE = "Bonjour @here, une question a besoin de votre réponse. Si l'un-e d'entre vous a la réponse, n'hésitez pas à la compléter."

Kemal.config.port = PORT
Kemal.config.env = "production"

before_all "/" do |env|
  env.response.content_type = "application/json"
end

post "/" do |env|
  # Get question from rocketchat
  body = env.params.json

  if check_rocket_token(body["token"], ROCKET_SECRET_TOKEN)
    Log.info { "An unauthorized access has been recorded from #{env.request.remote_address} with #{body["token"]}" }
    halt env, status_code: 401, response: "Unauthorized"
  else
    Log.info { "Tmid provided, doing nothing" } if body["tmid"]?
    halt env, status_code: 200, response: "tmid provided, doing nothing" if body["tmid"]?

    # Check notion search for response
    room_id = body["channel_id"]
    message_id = body["message_id"]
    searched_text = body["text"]
    request = search_in_notion(searched_text)

    results = JSON.parse(request.body)["results"].as_a

    if results.empty?
      page_response = create_notion_page(searched_text)
      page = JSON.parse(page_response.body)

      Log.info { "Creating page: #{page}" }
      response = send_to_rocket(room_id, message_id, page_message_builder(searched_text, page), CREATED_PAGE_MESSAGE)
      halt env, status_code: 200, response: JSON.parse(response.body)
    else
      responses = Array(Crest::Response).new
      results.each do |result|
        responses << send_to_rocket(room_id, message_id, search_message_builder(result))
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

def send_to_rocket(room_id, message_id, message, text = nil)
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
        "msg":         text,
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

def search_in_notion(searched_text)
  Crest::Request.execute(:post,
    NOTION_SEARCH_URL,
    headers: {
      "Content-Type"   => "application/json",
      "Notion-Version" => "2021-05-13",
      "Authorization"  => NOTION_API_KEY,
    },
    form: {
      "query"   => searched_text,
      "page_size": 5,
      "sort":      {
        "direction" => "ascending",
        "timestamp" => "last_edited_time",
      },
    }.to_json
  )
end

def create_notion_page(searched_text)
  Crest::Request.execute(:post,
    NOTION_PAGE_URL,
    headers: {
      "Content-Type"   => "application/json",
      "Notion-Version" => "2021-05-13",
      "Authorization"  => NOTION_API_KEY,
    },
    form: {
      "parent": {
        "type":    "page_id",
        "page_id": PAGE_PARENT_ID,
      },
      "properties": {
        "title": [
          {
            "type": "text",
            "text": {
              "content": searched_text,
            },
          },
        ],
      },
    }.to_json
  )
end

def page_message_builder(text, id)
  message_builder(text, id)
end

def search_message_builder(result)
  message_builder(result["properties"]["title"]["title"][0]["plain_text"], result["id"].as_s.gsub("-", ""))
end

def message_builder(text, id)
  {title: text, link: "#{NOTION_URL}/#{id}"}
end

Kemal.run do |config|
  server = config.server.not_nil!
  server.bind_tcp HOST, PORT, reuse_port: true
end
