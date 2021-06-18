module AskNotion
  module Config
    HOST                 = ENV["HOST"]?.try(&.to_s) || "0.0.0.0"
    PORT                 = ENV["PORT"]?.try(&.to_i) || 8080
    NOTION_API_KEY       = ENV["NOTION_API_KEY"]?.try(&.to_s) || ""
    ROCKET_SECRET_TOKEN  = ENV["ROCKET_SECRET_TOKEN"]?.try(&.to_s) || ""
    NOTION_URL           = ENV["NOTION_URL"]?.try(&.to_s) || ""
    NOTION_SEARCH_URL    = ENV["NOTION_SEARCH_URL"]?.try(&.to_s) || "https://api.notion.com/v1/search"
    NOTION_PAGE_URL      = ENV["NOTION_PAGE_URL"]?.try(&.to_s) || "https://api.notion.com/v1/pages"
    NOTION_API_VERSION   = ENV["NOTION_API_VERSION"]?.try(&.to_s) || "2021-05-13"
    ROCKET_CHAT_URL      = ENV["ROCKET_CHAT_URL"]?.try(&.to_s) || "https://osp.rocket.chat"
    ROCKET_API_TOKEN     = ENV["ROCKET_API_TOKEN"]?.try(&.to_s) || ""
    ROCKET_API_ID        = ENV["ROCKET_API_ID"]?.try(&.to_s) || ""
    WIKI_PAGE_ID         = ENV["WIKI_PAGE_ID"]?.try(&.to_s) || "4df27551-820f-49ef-838d-cf2047110f47"
    FAQ_PAGE_ID          = ENV["FAQ_PAGE_ID"]?.try(&.to_s) || "639e6e8d-73ab-45c8-a1b0-bf829d17c5e4"
    CREATED_PAGE_MESSAGE = "Bonjour @here, une question a besoin de votre réponse. Si l'un-e d'entre vous a la réponse, n'hésitez pas à la compléter."
    ENVIRONNEMENT        = ENV["KEMAL_ENV"]?.try(&.to_s) || "production"
  end
end
