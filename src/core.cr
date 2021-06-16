module AskNotion
  module Core
    # Ensure ROCKET_CHAT_TOKEN and given token are equals
    def self.valid_rocket_token?(params_token : String | Nil, token : String = AskNotion::Config::ROCKET_SECRET_TOKEN)
      params_token === token
    end

    def self.message_builder(text, id)
      {title: text, link: "#{Config::NOTION_URL}/#{id}"}
    end

    def self.page_message_builder(text, page)
      message_builder(text, page["id"].as_s.gsub("-", ""))
    end

    def self.search_message_builder(result)
      message_builder(result["properties"]["title"]["title"][0]["plain_text"], result["id"].as_s.gsub("-", ""))
    end
  end
end
