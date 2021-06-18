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

      if !valid_rocket_token?(body["token"].as(String))
        Log.info { "An unauthorized access has been recorded from #{env.request.remote_address} with #{body["token"]}" }
        halt env, status_code: 401, response: "Unauthorized"
      end

      if body["tmid"]?
        Log.info { "Tmid provided, doing nothing" }
        halt env, status_code: 200, response: "tmid provided, doing nothing"
      end

      # Check notion search for response
      room_id = body["channel_id"]
      message_id = body["message_id"]
      searched_text = body["text"]

      request = search_in_notion(searched_text)

      results = JSON.parse(request.body)["results"].as_a
      # results = clean_up_results(results)

      Log.info { "Returning results: #{results}" }
      if results.empty?
        Log.info { "No results found from Notion, creating page..." }
        page_response = create_notion_page(searched_text)
        page = JSON.parse(page_response.body)

        Log.info { "Created page: #{page}" }

        response = send_to_rocket(room_id, message_id, page_message_builder(searched_text, page), CREATED_PAGE_MESSAGE)
        if !response.nil? && !response.body.nil?
          halt env, status_code: 200, response: JSON.parse(response.body)
        end

        halt env, status_code: 200, response: "No response sent"
      end

      Log.info { "#{results.size} results found !" }
      responses = Array(Crest::Response).new
      results.each do |result|
        sent = send_to_rocket(room_id, message_id, search_message_builder(result))

        responses << sent if !sent.nil?
      end

      returned_responses = responses.map { |response| JSON.parse(response.body) }.to_json
      Log.info { "Returned_responses: #{returned_responses}" }
      halt env, status_code: 200, response: returned_responses
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
