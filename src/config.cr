module AskNotion
  module Config
    HOST                 = ENV["HOST"]?.try(&.to_s) || "0.0.0.0"                                                                                       # Host of Kemal server
    PORT                 = ENV["PORT"]?.try(&.to_i) || 8080                                                                                            # Port of Kemal server
    NOTION_API_KEY       = ENV["NOTION_API_KEY"]?.try(&.to_s) || ""                                                                                    # Notion integration API key
    ROCKET_SECRET_TOKEN  = ENV["ROCKET_SECRET_TOKEN"]?.try(&.to_s) || ""                                                                               # Rocket Chat Secret API token
    NOTION_URL           = ENV["NOTION_URL"]?.try(&.to_s) || ""                                                                                        # Notion workspace base url
    NOTION_SEARCH_URL    = ENV["NOTION_SEARCH_URL"]?.try(&.to_s) || "https://api.notion.com/v1/search"                                                 # Notion base search url
    NOTION_PAGE_URL      = ENV["NOTION_PAGE_URL"]?.try(&.to_s) || "https://api.notion.com/v1/pages"                                                    # Notion base page url
    NOTION_API_VERSION   = ENV["NOTION_API_VERSION"]?.try(&.to_s) || "2021-05-13"                                                                      # Notion API version
    NOTION_PAGE_SIZE     = ENV["NOTION_PAGE_SIZE"]?.try(&.to_i) || 10                                                                                # Number of results returned by notion API
    ROCKET_CHAT_URL      = ENV["ROCKET_CHAT_URL"]?.try(&.to_s) || "https://osp.rocket.chat"                                                            # Rocket chat server base url
    ROCKET_API_TOKEN     = ENV["ROCKET_API_TOKEN"]?.try(&.to_s) || ""                                                                                  # Rocket chat API token
    ROCKET_API_ID        = ENV["ROCKET_API_ID"]?.try(&.to_s) || ""                                                                                     # Rocket chat API ID
    WIKI_PAGE_ID         = ENV["WIKI_PAGE_ID"]?.try(&.to_s) || "4df27551-820f-49ef-838d-cf2047110f47"                                                  # Notion Parent page ID, used for search
    FAQ_PAGE_ID          = ENV["FAQ_PAGE_ID"]?.try(&.to_s) || "639e6e8d-73ab-45c8-a1b0-bf829d17c5e4"                                                   # Notion FAQ page ID, used for writing unknown questions
    CREATED_PAGE_MESSAGE = "Bonjour @here, une question a besoin de votre réponse. Si l'un-e d'entre vous a la réponse, n'hésitez pas à la compléter." # Default message sent on Rocket chat
    ENVIRONNEMENT        = ENV["KEMAL_ENV"]?.try(&.to_s) || "production"                                                                               # Kemal environnement, allows to run in production mode or running tests
  end
end
