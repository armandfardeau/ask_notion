require "spec-kemal"
require "../app"

def rocket_chat_sample(text="dummy text")
    {
      "method": "POST",
      "path": "/",
      "query": {"data" => "data"},
      "headers": {
        "x-forwarded-for": "xxx.xxx.x.xx",
        "x-forwarded-proto": "https",
        "x-forwarded-port": "443",
        "host": "xxxxxxxxx.xxxxxx.xxx",
        "x-amzn-trace-id": "User=xxxxxxxxxxxxxxxx",
        "content-length": "305",
        "content-type": "application/json",
        "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36"
      },
      "bodyRaw": "{\"token\":\"dummy_token\",\"bot\":false,\"channel_id\":\"AzertYuiop4\",\"channel_name\":\"dummy_channel\",\"message_id\":\"dummy_message_id_1\",\"timestamp\":\"2021-06-10T13:47:49.425Z\",\"user_id\":\"user_id_1\",\"user_name\":\"user_name\",\"text\":\"dummy text\",\"siteUrl\":\"https://dummy.host.com\",\"tmid\":\"azertyuiop1\"}",
      "body": {
        "token": "dummy_token",
        "bot": false,
        "channel_id": "AzertYuiop4",
        "channel_name": "dummy_channel",
        "message_id": "dummy_message_id_1",
        "timestamp": "2021-06-10T13:47:49.425Z",
        "user_id": "user_id_1",
        "user_name": "user_name",
        "text": text,
        "siteUrl": "https://dummy.host.com",
        "tmid": "azertyuiop1"
      }
    }
end

