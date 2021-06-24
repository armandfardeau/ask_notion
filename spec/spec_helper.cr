require "spec-kemal"
require "log"
require "webmock"

require "../src/app"
require "../src/config"
require "../src/core"

Spec.before_each &->WebMock.reset

def rocket_chat_sample(text : String = "dummy text", token : String = "dummy_token", tmid : String | Nil = "azertyuiop1")
  sample = {
    "token"        => token,
    "bot"          => false,
    "channel_id"   => "AzertYuiop4",
    "channel_name" => "dummy_channel",
    "message_id"   => "dummy_message_id_1",
    "timestamp"    => "2021-06-10T13:47:49.425Z",
    "user_id"      => "user_id_1",
    "user_name"    => "user_name",
    "text"         => text,
    "siteUrl"      => "https://dummy.host.com",
  }
  sample["tmid"] = tmid if !tmid.nil?
  sample.to_json
end
