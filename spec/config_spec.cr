require "./spec_helper"

describe "AskNotion::Config" do
  context "port config" do
    it "sets default port to 8080" do
      AskNotion::Config::PORT.should eq 8080
    end
  end

  it "sets default host to 0.0.0.0" do
    AskNotion::Config::HOST.should eq "0.0.0.0"
  end

  it "sets default notion_api_version" do
    AskNotion::Config::NOTION_API_VERSION.should eq "2021-05-13"
  end

  it "sets default notion_search_url" do
    AskNotion::Config::NOTION_SEARCH_URL.should eq "https://api.notion.com/v1/search"
  end

  it "sets default notion_page_url" do
    AskNotion::Config::NOTION_PAGE_URL.should eq "https://api.notion.com/v1/pages"
  end

  it "sets default rocket_chat_url" do
    AskNotion::Config::ROCKET_CHAT_URL.should eq "https://osp.rocket.chat"
  end

  it "sets default rocket chat message" do
    AskNotion::Config::CREATED_PAGE_MESSAGE.should eq "Bonjour @here, une question a besoin de votre réponse. Si l'un-e d'entre vous a la réponse, n'hésitez pas à la compléter."
  end

  it "sets default notion_api_key" do
    AskNotion::Config::NOTION_API_KEY.should eq ""
  end

  it "sets default rocket_secret_token" do
    AskNotion::Config::ROCKET_SECRET_TOKEN.should eq ""
  end
end
