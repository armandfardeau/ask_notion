module AskNotion
  module Core
    extend self

    # Ensure ROCKET_CHAT_TOKEN and given token are equals
    def valid_rocket_token?(params_token : String | Nil, token : String = ROCKET_SECRET_TOKEN)
      params_token === token
    end

    def message_builder(text, id)
      {title: text, link: "#{NOTION_URL}/#{id}"}
    end

    def page_message_builder(text, page)
      message_builder(text, page["id"].as_s.gsub("-", ""))
    end

    def search_message_builder(result, fallback, index)
      text = ""
      begin
        if result["parent"]["type"] == "page_id"
          text = result["properties"]["title"]["title"][0]["plain_text"]
        elsif result["parent"]["type"] == "database_id"
          text = result["properties"]["Name"]["title"][0]["plain_text"]
        end
      rescue ex : KeyError
        text = "#{fallback} #{index}"
        Log.info { text }
      end

      id = result["id"].as_s.gsub("-", "")
      message_builder(text, id)
    end

    def send_to_rocket(room_id, message_id, message, text = nil)
      Log.info { message.to_json }

      begin
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
      rescue ex : Exception
        Log.error { "Error while performing response to Rocket chat" }
        Log.error { "Catched exception : #{ex}" }
        return nil
      end
    end

    def create_notion_page(searched_text)
      Crest::Request.execute(:post,
        NOTION_PAGE_URL,
        headers: {
          "Content-Type"   => "application/json",
          "Notion-Version" => NOTION_API_VERSION,
          "Authorization"  => NOTION_API_KEY,
        },
        form: {
          "parent": {
            "type":    "page_id",
            "page_id": FAQ_PAGE_ID,
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

    def search_in_notion(searched_text)
      Crest::Request.execute(:post,
        NOTION_SEARCH_URL,
        headers: {
          "Content-Type"   => "application/json",
          "Notion-Version" => NOTION_API_VERSION,
          "Authorization"  => NOTION_API_KEY,
        },
        form: {
          "query"   => searched_text,
          "page_size": NOTION_PAGE_SIZE,
          "sort":      {
            "direction" => "ascending",
            "timestamp" => "last_edited_time",
          },
        }.to_json
      )
    end

    def notion_results(content)
      return nil if content.nil?

      hash = JSON.parse(content)
      hash["results"].as_a unless hash["results"]?.nil?
    end
  end
end
