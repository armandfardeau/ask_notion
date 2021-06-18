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
      pp result
      text = result["properties"]["title"]["title"][0]["plain_text"]
      id = result["id"].as_s.gsub("-", "")
      message_builder(text, id)
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

    def self.create_notion_page(searched_text)
      Crest::Request.execute(:post,
        AskNotion::Config::NOTION_PAGE_URL,
        headers: {
          "Content-Type"   => "application/json",
          "Notion-Version" => AskNotion::Config::NOTION_API_VERSION,
          "Authorization"  => AskNotion::Config::NOTION_API_KEY,
        },
        form: {
          "parent": {
            "type":    "page_id",
            "page_id": AskNotion::Config::FAQ_PAGE_ID,
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

    def self.search_in_notion(searched_text)
      Crest::Request.execute(:post,
        AskNotion::Config::NOTION_SEARCH_URL,
        headers: {
          "Content-Type"   => "application/json",
          "Notion-Version" => AskNotion::Config::NOTION_API_VERSION,
          "Authorization"  => AskNotion::Config::NOTION_API_KEY,
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

    def self.clean_up_results(results_arr)
      pp results_arr
      results_arr.select do |result|
        if has_parent_id?(result, AskNotion::Config::WIKI_PAGE_ID)
          result
        end
      end
    end

    def self.has_parent_id?(result, parent_id)
      if result["parent"]? && result["parent"]["page_id"]?
        result["parent"]["page_id"] == parent_id
      else
        false
      end
    end
  end
end
