module AskNotion
  module Core
    # Ensure ROCKET_CHAT_TOKEN and given token are equals
    def self.valid_rocket_token?(params_token : String | Nil, token : String = AskNotion::Config::ROCKET_SECRET_TOKEN)
      params_token === token
    end

    def self.message_builder(text, id)
      {title: text, link: "#{AskNotion::Config::NOTION_URL}/#{id}"}
    end

    def self.page_message_builder(text, page)
      message_builder(text, page["id"].as_s.gsub("-", ""))
    end

    def self.search_message_builder(result)
      message_builder(result["properties"]["title"]["title"][0]["plain_text"], result["id"].as_s.gsub("-", ""))
    end

    def self.send_to_rocket(room_id, message_id, message, text = nil)
      Log.info { message.to_json }

      begin
        Crest::Request.execute(:post,
          "#{AskNotion::Config::ROCKET_CHAT_URL}/api/v1/chat.sendMessage",
          headers: {
            "Content-Type" => "application/json",
            "X-Auth-Token" => AskNotion::Config::ROCKET_API_TOKEN,
            "X-User-Id"    => AskNotion::Config::ROCKET_API_ID,
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
      rescue ex : Exception
        Log.error { "Error while performing response to Rocket chat" }
        Log.error { "Catched exception : #{ex}" }
        return nil
      end
    end
  end
end
