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
    context "when there is no result" do
      it "creates a page" do
        web_mock_notion_search("{\"object\":\"list\",\"results\":[],\"next_cursor\":\"null\",\"has_more\":false}")
        web_mock_notion_pages("{\"object\":\"page\",\"id\":\"35cebbee-3ab2-4e50-812f-e558d5fdc273\",\"created_time\":\"2021-06-24T15:10:38.213Z\",\"last_edited_time\":\"2021-06-24T15:10:38.213Z\",\"parent\":{\"type\":\"page_id\",\"page_id\":\"639e6e8d-73ab-45c8-a1b0-bf829d17c5e4\"},\"archived\":false,\"properties\":{\"title\":{\"id\":\"title\",\"type\":\"title\",\"title\":[{\"type\":\"text\",\"text\":{\"content\":\"dummy text\",\"link\":\"null\"},\"annotations\":{\"bold\":false,\"italic\":false,\"strikethrough\":false,\"underline\":false,\"code\":false,\"color\":\"default\"},\"plain_text\":\"dummy text\",\"href\":\"null\"}]}}}")
        web_mock_rocket_message(
        "{\"message\":{\"msg\":\"Bonjour @here, une question a besoin de votre réponse. Si l'un-e d'entre vous a la réponse, n'hésitez pas à la compléter.\",\"rid\":\"AzertYuiop4\",\"tmid\":\"dummy_message_id_1\",\"alias\":\"AskNotion\",\"avatar\":\"https://upload.wikimedia.org/wikipedia/commons/4/45/Notion_app_logo.png\",\"attachments\":[{\"title\":\"dummy text\",\"title_link\":\"/35cebbee3ab24e50812fe558d5fdc273\",\"collapsed\":false}]}}",
        "{\"results\": [\"dummy\"], \"id\": \"dummy_id\"}"
        )

        post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: rocket_chat_sample("dummy text", "", tmid: nil))

        response.content_type.should eq "application/json"
        response.status_code.should eq 200
        response.body.should eq "{\"results\" => [\"dummy\"], \"id\" => \"dummy_id\"}"
      end
    end

    context "when results contains a database_id parent" do
          context "when there is no name properties" do
            it "returns a generic message" do
              web_mock_notion_search("{\"object\":\"list\",\"results\":[{\"object\":\"database\",\"id\":\"7075c820-d70b-42e6-b487-e598afa63672\",\"created_time\":\"2019-08-28T08:35:45.910Z\",\"last_edited_time\":\"2019-08-28T09:39:00.000Z\",\"title\":[{\"type\":\"text\",\"text\":{\"content\":\"Historique des interventions\",\"link\":\"null\"},\"annotations\":{\"bold\":false,\"italic\":false,\"strikethrough\":false,\"underline\":false,\"code\":false,\"color\":\"default\"},\"plain_text\":\"Historique des interventions\",\"href\":\"null\"}],\"properties\":{\"Organisateur\":{\"id\":\")\\\\{^\",\"type\":\"rich_text\",\"rich_text\":{}},\"Intervenant\":{\"id\":\",UK&\",\"type\":\"people\",\"people\":{}},\"Date\":{\"id\":\"VZe)\",\"type\":\"date\",\"date\":{}},\"Conf\":{\"id\":\"title\",\"type\":\"title\",\"title\":{}}},\"parent\":{\"type\":\"page_id\",\"page_id\":\"a647ff98-493e-479f-bf35-d0f072c44bd0\"}}],\"next_cursor\":\"null\",\"has_more\":false}")
              web_mock_notion_pages("{\"object\":\"page\",\"id\":\"35cebbee-3ab2-4e50-812f-e558d5fdc273\",\"created_time\":\"2021-06-24T15:10:38.213Z\",\"last_edited_time\":\"2021-06-24T15:10:38.213Z\",\"parent\":{\"type\":\"page_id\",\"page_id\":\"639e6e8d-73ab-45c8-a1b0-bf829d17c5e4\"},\"archived\":false,\"properties\":{\"title\":{\"id\":\"title\",\"type\":\"title\",\"title\":[{\"type\":\"text\",\"text\":{\"content\":\"dummy text 0\",\"link\":\"null\"},\"annotations\":{\"bold\":false,\"italic\":false,\"strikethrough\":false,\"underline\":false,\"code\":false,\"color\":\"default\"},\"plain_text\":\"dummy text 0\",\"href\":\"null\"}]}}}")
              web_mock_rocket_message(
              "{\"message\":{\"msg\":null,\"rid\":\"AzertYuiop4\",\"tmid\":\"dummy_message_id_1\",\"alias\":\"AskNotion\",\"avatar\":\"https://upload.wikimedia.org/wikipedia/commons/4/45/Notion_app_logo.png\",\"attachments\":[{\"title\":\"dummy text 0\",\"title_link\":\"/7075c820d70b42e6b487e598afa63672\",\"collapsed\":false}]}}",
              "{\"results\": [\"dummy\"], \"id\": \"dummy_id\"}"
              )

              post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: rocket_chat_sample("dummy text", "", tmid: nil))

              response.content_type.should eq "application/json"
              response.status_code.should eq 200
              response.body.should eq "[{\"results\":[\"dummy\"],\"id\":\"dummy_id\"}]"
            end
          end
        end

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
        post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: rocket_chat_sample("dummy text", ""))

        response.content_type.should eq "application/json"
        response.status_code.should eq 200
        response.body.should eq "tmid provided, doing nothing"
      end
    end

    context "and tmid is not provided" do
      it "returns 200 status code" do
        web_mock_notion_search("{\"object\":\"list\",\"results\":[],\"next_cursor\":\"null\",\"has_more\":false}")
        web_mock_notion_pages("{\"object\":\"page\",\"id\":\"35cebbee-3ab2-4e50-812f-e558d5fdc273\",\"created_time\":\"2021-06-24T15:10:38.213Z\",\"last_edited_time\":\"2021-06-24T15:10:38.213Z\",\"parent\":{\"type\":\"page_id\",\"page_id\":\"639e6e8d-73ab-45c8-a1b0-bf829d17c5e4\"},\"archived\":false,\"properties\":{\"title\":{\"id\":\"title\",\"type\":\"title\",\"title\":[{\"type\":\"text\",\"text\":{\"content\":\"dummy text\",\"link\":\"null\"},\"annotations\":{\"bold\":false,\"italic\":false,\"strikethrough\":false,\"underline\":false,\"code\":false,\"color\":\"default\"},\"plain_text\":\"dummy text\",\"href\":\"null\"}]}}}")
        web_mock_rocket_message("{\"message\":{\"msg\":\"Bonjour @here, une question a besoin de votre réponse. Si l'un-e d'entre vous a la réponse, n'hésitez pas à la compléter.\",\"rid\":\"AzertYuiop4\",\"tmid\":\"dummy_message_id_1\",\"alias\":\"AskNotion\",\"avatar\":\"https://upload.wikimedia.org/wikipedia/commons/4/45/Notion_app_logo.png\",\"attachments\":[{\"title\":\"dummy text\",\"title_link\":\"/35cebbee3ab24e50812fe558d5fdc273\",\"collapsed\":false}]}}", "{\"results\": [\"dummy\"], \"id\": \"dummy_id\"}")

        post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: rocket_chat_sample("dummy text", "", tmid: nil))

        response.content_type.should eq "application/json"
        response.status_code.should eq 200
        response.body.should eq "{\"results\" => [\"dummy\"], \"id\" => \"dummy_id\"}"
      end
    end
  end
end

def web_mock_notion_search(response)
  WebMock.stub(:post, "https://api.notion.com/v1/search").with(
    body: "{\"query\":\"dummy text\",\"page_size\":10,\"sort\":{\"direction\":\"ascending\",\"timestamp\":\"last_edited_time\"}}",
    headers: {"Content-Type" => "application/json", "Notion-Version" => "2021-05-13", "Authorization" => "", "User-Agent" => "Crest/0.27.0 (Crystal/1.0.0)"}
  ).to_return(body: response)
end

def web_mock_notion_pages(response)
  WebMock.stub(:post, "https://api.notion.com/v1/pages").with(
    body: "{\"parent\":{\"type\":\"page_id\",\"page_id\":\"639e6e8d-73ab-45c8-a1b0-bf829d17c5e4\"},\"properties\":{\"title\":[{\"type\":\"text\",\"text\":{\"content\":\"dummy text\"}}]}}",
    headers: {"Content-Type" => "application/json", "Notion-Version" => "2021-05-13", "Authorization" => "", "User-Agent" => "Crest/0.27.0 (Crystal/1.0.0)"}
  ).to_return(body: response)
end

def web_mock_rocket_message(body, response)
  WebMock.stub(:post, "https://osp.rocket.chat/api/v1/chat.sendMessage").with(
    body: body,
    headers: {"Content-Type" => "application/json", "X-Auth-Token" => "", "X-User-Id" => "", "User-Agent" => "Crest/0.27.0 (Crystal/1.0.0)"}
  ).to_return(body: response)
end
