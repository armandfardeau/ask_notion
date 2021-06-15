require "kemal"
require "crest"
require "./config"
require "./core"

module AskNotion
  before_all "/" do |env|
    env.response.content_type = "application/json"
  end

  post "/" do |env|
    begin
      # Get question from rocketchat
      body = env.params.json

      if !Core.valid_rocket_token?(body["token"].as(String))
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
          response = send_to_rocket(room_id, message_id, Core.page_message_builder(searched_text, page), Config::CREATED_PAGE_MESSAGE)
          halt env, status_code: 200, response: JSON.parse(response.body)
        else
          responses = Array(Crest::Response).new
          results.each do |result|
            responses << send_to_rocket(room_id, message_id, Core.search_message_builder(result))
          end

          returned_responses = responses.map { |response| JSON.parse(response.body) }.to_json
          Log.info { "Returned_responses: #{returned_responses}" }
          halt env, status_code: 200, response: returned_responses
        end
      end
    rescue ex : JSON::ParseException
      Log.info { "Request from #{env.request.remote_address} - Body parsing error" }
      halt env, status_code: 500, response: "Error when parsing body request, please ensure your body request is correct"
    end
  end

  def self.check_rocket_token(params_token, env_token)
    params_token != env_token
  end

  def self.send_to_rocket(room_id, message_id, message, text = nil)
    Log.info { message.to_json }

    Crest::Request.execute(:post,
      "#{Config::ROCKET_CHAT_URL}/api/v1/chat.sendMessage",
      headers: {
        "Content-Type" => "application/json",
        "X-Auth-Token" => Config::ROCKET_API_TOKEN,
        "X-User-Id"    => Config::ROCKET_API_ID,
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

  def self.search_in_notion(searched_text)
    Crest::Request.execute(:post,
      Config::NOTION_SEARCH_URL,
      headers: {
        "Content-Type"   => "application/json",
        "Notion-Version" => Config::NOTION_API_VERSION,
        "Authorization"  => Config::NOTION_API_KEY,
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

  def self.create_notion_page(searched_text)
    Crest::Request.execute(:post,
      Config::NOTION_PAGE_URL,
      headers: {
        "Content-Type"   => "application/json",
        "Notion-Version" => Config::NOTION_API_VERSION,
        "Authorization"  => Config::NOTION_API_KEY,
      },
      form: {
        "parent": {
          "type":    "page_id",
          "page_id": Config::PAGE_PARENT_ID,
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
end

Kemal.config.env = AskNotion::Config::ENVIRONNEMENT
serve_static false

if Kemal.config.env == "production"
  Kemal.run do |config|
    server = config.server.not_nil!
    server.bind_tcp AskNotion::Config::HOST, AskNotion::Config::PORT, reuse_port: true
  end
else
  Kemal.run
end
