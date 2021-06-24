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
        post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: rocket_chat_sample("dummy text", token).to_s)

        response.content_type.should eq "application/json"
        response.status_code.should eq 401
        response.body.should eq "Unauthorized"
      end
    end

    context "and tmid is provided" do
      it "returns 200 status code" do
        token = ""
        p AskNotion::Config::ROCKET_SECRET_TOKEN
        post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: rocket_chat_sample("dummy text", token).to_s)

        response.content_type.should eq "application/json"
        response.status_code.should eq 200
        response.body.should eq "tmid provided, doing nothing"
      end
    end

    context "and tmid is not provided" do
      it "returns 200 status code" do
        web_mock_notion_search
        web_mock_notion_pages

        WebMock.stub(:post, "https://osp.rocket.chat/api/v1/chat.sendMessage")
          .with(body: "{\"message\":{\"msg\":\"#{AskNotion::Config::CREATED_PAGE_MESSAGE}\",\"rid\":\"AzertYuiop4\",\"tmid\":\"dummy_message_id_1\",\"alias\":\"AskNotion\",\"avatar\":\"https://upload.wikimedia.org/wikipedia/commons/4/45/Notion_app_logo.png\",\"attachments\":[{\"title\":\"dummy text\",\"title_link\":\"/dummy_id\",\"collapsed\":false}]}}", headers: {"Content-Type" => "application/json", "X-Auth-Token" => AskNotion::Config::ROCKET_SECRET_TOKEN, "X-User-Id" => AskNotion::Config::ROCKET_API_ID, "Content-Length" => "381", "Host" => "osp.rocket.chat", "User-Agent" => "Crest/0.27.0 (Crystal/1.0.0)"})
          .to_return(body: {"results": ["dummy"] of String, "id": "dummy_id"}.to_json)

        token = ""
        post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: rocket_chat_sample("dummy text", token, tmid: nil).to_s)

        response.content_type.should eq "application/json"
        response.status_code.should eq 200
        response.body.should eq "{\"results\" => [\"dummy\"], \"id\" => \"dummy_id\"}"
        WebMock.reset
      end
    end
    context "when request is unauthorized" do
      it "returns no responses" do
        web_mock_notion_search
        web_mock_notion_pages
        WebMock.stub(:post, "https://osp.rocket.chat/api/v1/chat.sendMessage")
          .with(body: "{\"message\":{\"msg\":\"#{AskNotion::Config::CREATED_PAGE_MESSAGE}\",\"rid\":\"AzertYuiop4\",\"tmid\":\"dummy_message_id_1\",\"alias\":\"AskNotion\",\"avatar\":\"https://upload.wikimedia.org/wikipedia/commons/4/45/Notion_app_logo.png\",\"attachments\":[{\"title\":\"dummy text\",\"title_link\":\"/dummy_id\",\"collapsed\":false}]}}", headers: {"Content-Type" => "application/json", "X-Auth-Token" => AskNotion::Config::ROCKET_SECRET_TOKEN, "X-User-Id" => AskNotion::Config::ROCKET_API_ID, "Content-Length" => "381", "Host" => "osp.rocket.chat", "User-Agent" => "Crest/0.27.0 (Crystal/1.0.0)"})
          .to_return(status: 401)

        response.content_type.should eq "application/json"
        response.status_code.should eq 200
        response.body.should eq "No response sent"
        WebMock.reset
      end
    end
  end
end

def web_mock_notion_search
  WebMock.stub(:post, "https://api.notion.com/v1/search")
    .with(body: "{\"query\":\"dummy text\",\"page_size\":5,\"sort\":{\"direction\":\"ascending\",\"timestamp\":\"last_edited_time\"}}", headers: {"Content-Type" => "application/json", "Notion-Version" => AskNotion::Config::NOTION_API_VERSION, "Authorization" => AskNotion::Config::NOTION_API_KEY, "User-Agent" => "Crest/0.27.0 (Crystal/1.0.0)"})
    .to_return(body: {"results": [] of String}.to_json)
end

def web_mock_notion_pages
  WebMock.stub(:post, "https://api.notion.com/v1/pages")
    .with(body: "{\"parent\":{\"type\":\"page_id\"},\"properties\":{\"title\":[{\"type\":\"text\",\"text\":{\"content\":\"dummy text\"}}]}}", headers: {"Content-Type" => "application/json", "Notion-Version" => AskNotion::Config::NOTION_API_VERSION, "Authorization" => AskNotion::Config::NOTION_API_KEY, "User-Agent" => "Crest/0.27.0 (Crystal/1.0.0)"})
    .to_return(body: {"results": [] of String, "id": "dummy_id"}.to_json)
end
