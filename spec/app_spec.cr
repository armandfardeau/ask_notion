require "./spec_helper"

describe "AskNotion" do
  it "renders /" do
    post "/"
    response.status.should eq 401
  end
end
