require "./spec_helper"

describe "AskNotion::Core" do
  describe "#valid_rocket_token?" do
    token = "dummy_token"
    context "when params_token is invalid" do
      context "and token is nil" do
        it "returns false" do
          subject = nil
          AskNotion::Core.valid_rocket_token?(subject, token).should be_false
        end
      end

      context "and token is empty" do
        it "returns false" do
          subject = ""
          AskNotion::Core.valid_rocket_token?(subject, token).should be_false
        end
      end
    end

    context "when params_token is valid" do
      it "returns true" do
        subject = "dummy_token"
        AskNotion::Core.valid_rocket_token?(subject, token).should be_true
      end
    end
  end


  describe "#message_builder" do
    it "returns a Hash with title and link" do
       AskNotion::Core.message_builder("A simple text", "123456").should eq({ title: "A simple text", link: "/123456" })
    end

    it "link always begins by NOTION_URL" do
        hash = AskNotion::Core.message_builder("A simple text", "123456")
        hash["link"][0].should eq '/'
    end
  end
end
