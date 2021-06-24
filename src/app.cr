require "kemal"
require "crest"
require "./config"
require "./core"

include AskNotion::Config
include AskNotion::Core

module AskNotion
  before_all "/" do |env|
    env.response.content_type = "application/json"
  end

  post "/" do |env|
    begin
      # Get question from rocketchat
      body = env.params.json

      # check if Rocket token is valid
      if !valid_rocket_token?(body["token"].as(String))
        Log.info { "An unauthorized access has been recorded from #{env.request.remote_address} with #{body["token"]}" }
        halt env, status_code: 401, response: "Unauthorized"
      end

      # Stop program if request came from thread answer
      if body["tmid"]?
        Log.info { "Tmid provided, doing nothing" }
        halt env, status_code: 200, response: "tmid provided, doing nothing"
      end

      # Store data from message
      data = {
        "room_id":       body["channel_id"]?,
        "message_id":    body["message_id"]?,
        "searched_text": body["text"]?,
      }

      # Search for results in Notion
      request = search_in_notion(data["searched_text"])
      # Format results
      results = notion_results(request.body)

      if results.nil? || results.empty?
        # Create page and send message on rocket
        page = create_new_page(data)
        response = send_to_rocket(data["room_id"], data["message_id"], page_message_builder(data["searched_text"], page), CREATED_PAGE_MESSAGE)
        if !response.nil? && !response.body.nil?
          halt env, status_code: 200, response: JSON.parse(response.body)
        end

        halt env, status_code: 200, response: "No response sent"
      end
    end

    Log.info { "#{results.not_nil!.size} results found !" }
    responses = Array(JSON::Any).new
    results.not_nil!.each_with_index do |result, index|
      sent = send_to_rocket(data["room_id"], data["message_id"], search_message_builder(result, data["searched_text"], index))

      responses << JSON.parse(sent.body) if !sent.nil?
    end

    Log.info { "Return: #{responses.to_json}" }
    halt env, status_code: 200, response: responses.to_json
  rescue ex : JSON::ParseException
    Log.error { "Request from #{env.request.remote_address} - Body parsing error" }
    Log.error { "Catched exception : #{ex}" }
    halt env, status_code: 500, response: "Error when parsing body request, please ensure your body request is correct"
  rescue ex : Exception
    Log.error { "Request from #{env.request.remote_address} - Unexpected error happened" }
    Log.error { "Catched exception : #{ex}" }
    halt env, status_code: 500, response: "Unexpected error happened"
  end
end

def self.create_new_page(data)
  Log.info { "No results found from Notion, creating page..." }
  page_response = create_notion_page(data["searched_text"])
  page = JSON.parse(page_response.body)

  Log.info { "Created page: #{page}" }

  page
end

Kemal.config.env = ENVIRONNEMENT
serve_static false

if Kemal.config.env == "production"
  Kemal.run do |config|
    server = config.server.not_nil!
    server.bind_tcp HOST, PORT, reuse_port: true
  end
else
  Kemal.run
end
