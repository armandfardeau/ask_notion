require "./spec_helper"

describe "AskNotion" do
  context "when body is invalid" do
    it "returns 500 status code" do
      post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: "")

      response.status_code.should eq 500
      response.content_type.should eq "application/json"
      response.body.should eq "Error when parsing body request, please ensure your body request is correct"
    end
  end

  context "when body is valid" do
    context "and token is invalid" do
      it "returns unauthorized response" do
        token = "dummy_token_unauthorized"
        post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: rocket_chat_sample("dummy text", token))

        response.content_type.should eq "application/json"
        response.status_code.should eq 401
        response.body.should eq "Unauthorized"
      end
    end

    context "and tmid is provided" do
      it "returns 200 status code" do
        token = ""
        p AskNotion::Config::ROCKET_SECRET_TOKEN
        post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: rocket_chat_sample("dummy text", token))

        response.content_type.should eq "application/json"
        response.status_code.should eq 200
        response.body.should eq "tmid provided, doing nothing"
      end
    end

    context "and tmid is not provided" do
      it "returns 200 status code" do
        web_mock_notion_search
        web_mock_notion_pages
        web_mock_rocket_message

        post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: rocket_chat_sample("dummy text", "", tmid: nil))

        response.content_type.should eq "application/json"
        response.status_code.should eq 200
        response.body.should eq "{\"results\" => [\"dummy\"], \"id\" => \"dummy_id\"}"
        WebMock.reset
      end
    end
  end
end

def web_mock_notion_search
  WebMock.stub(:post, "https://api.notion.com/v1/search").with(
    body: "{\"query\":\"dummy text\",\"page_size\":10,\"sort\":{\"direction\":\"ascending\",\"timestamp\":\"last_edited_time\"}}",
    headers: {"Content-Type" => "application/json", "Notion-Version" => "2021-05-13", "Authorization" => "", "User-Agent" => "Crest/0.27.0 (Crystal/1.0.0)"}
  ).to_return(
    body: "{\"object\":\"list\",\"results\":[],\"next_cursor\":\"null\",\"has_more\":false}"
  )
end

def web_mock_notion_pages
  WebMock.stub(:post, "https://api.notion.com/v1/pages").with(
    body: "{\"parent\":{\"type\":\"page_id\",\"page_id\":\"639e6e8d-73ab-45c8-a1b0-bf829d17c5e4\"},\"properties\":{\"title\":[{\"type\":\"text\",\"text\":{\"content\":\"dummy text\"}}]}}",
    headers: {"Content-Type" => "application/json", "Notion-Version" => "2021-05-13", "Authorization" => "", "User-Agent" => "Crest/0.27.0 (Crystal/1.0.0)"}
  ).to_return(
    body: "{\"object\":\"page\",\"id\":\"35cebbee-3ab2-4e50-812f-e558d5fdc273\",\"created_time\":\"2021-06-24T15:10:38.213Z\",\"last_edited_time\":\"2021-06-24T15:10:38.213Z\",\"parent\":{\"type\":\"page_id\",\"page_id\":\"639e6e8d-73ab-45c8-a1b0-bf829d17c5e4\"},\"archived\":false,\"properties\":{\"title\":{\"id\":\"title\",\"type\":\"title\",\"title\":[{\"type\":\"text\",\"text\":{\"content\":\"dummy text\",\"link\":\"null\"},\"annotations\":{\"bold\":false,\"italic\":false,\"strikethrough\":false,\"underline\":false,\"code\":false,\"color\":\"default\"},\"plain_text\":\"dummy text\",\"href\":\"null\"}]}}}"
  )
end

def web_mock_rocket_message
  WebMock.stub(:post, "https://osp.rocket.chat/api/v1/chat.sendMessage").with(
    body: "{\"message\":{\"msg\":\"Bonjour @here, une question a besoin de votre réponse. Si l'un-e d'entre vous a la réponse, n'hésitez pas à la compléter.\",\"rid\":\"AzertYuiop4\",\"tmid\":\"dummy_message_id_1\",\"alias\":\"AskNotion\",\"avatar\":\"https://upload.wikimedia.org/wikipedia/commons/4/45/Notion_app_logo.png\",\"attachments\":[{\"title\":\"dummy text\",\"title_link\":\"/35cebbee3ab24e50812fe558d5fdc273\",\"collapsed\":false}]}}",
    headers: {"Content-Type" => "application/json", "X-Auth-Token" => "", "X-User-Id" => "", "User-Agent" => "Crest/0.27.0 (Crystal/1.0.0)"}
  ).to_return(
    body: "{\"results\": [\"dummy\"], \"id\": \"dummy_id\"}"
  )
end
