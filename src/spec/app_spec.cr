require "./spec_helper"

describe "App" do
  it "renders /" do
    post "/"
    response.body.should eq "Hello World!"
  end

  it "reads request" do
    post("/", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: rocket_chat_sample.to_s)
    response.body.should eq("texte")
  end
end
