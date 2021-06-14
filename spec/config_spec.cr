require "./spec_helper"

describe "Asknotion::Config" do

  context "port config" do
      it "sets default port to 8080" do
        Asknotion::Config::PORT.should eq 8080
      end

      context "when using ENV to override default value" do
          it "overrides default PORT" do
            Asknotion::Config::PORT.should eq 3000
          end
      end
  end

  it "sets default host to 0.0.0.0" do
    Asknotion::Config::HOST.should eq "0.0.0.0"
  end

  it "sets default notion_endpoint" do
    Asknotion::Config::NOTION_ENDPOINT.should eq "https://api.notion.com/v1/search"
  end

  it "sets default notion_api_version" do
    Asknotion::Config::NOTION_API_VERSION.should eq "2021-05-13"
  end

  it "sets default notion_api_key" do
    Asknotion::Config::NOTION_API_KEY.should eq ""
  end

  it "sets default rocket_secret_token" do
    Asknotion::Config::ROCKET_SECRET_TOKEN.should eq ""
  end
end
