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

  context "when body is valid but not token" do
    it "returns unauthorized response" do
      token = "dummy_token_unauthorized"
      post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: rocket_chat_sample("dummy text", token).to_s)

      response.content_type.should eq "application/json"
      response.status_code.should eq 401
      response.body.should eq "Unauthorized"
    end
  end
end
