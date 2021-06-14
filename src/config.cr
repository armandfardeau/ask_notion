module Asknotion
  module Config
    HOST                = ENV["HOST"]?.try(&.to_s) || "0.0.0.0"
    PORT                = ENV["PORT"]?.try(&.to_i) || 8080
    NOTION_ENDPOINT     = ENV["NOTION_ENDPOINT"]?.try(&.to_s) || "https://api.notion.com/v1/search"
    NOTION_API_VERSION  = ENV["NOTION_API_VERSION"]?.try(&.to_s) || "2021-05-13"
    NOTION_API_KEY      = ENV["NOTION_API_KEY"]?.try(&.to_s) || ""
    ROCKET_SECRET_TOKEN = ENV["ROCKET_SECRET_TOKEN"]?.try(&.to_s) || ""
  end
end
