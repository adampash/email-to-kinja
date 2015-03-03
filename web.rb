require 'sinatra'
require 'kinja'
require 'json'
require_relative './lib/post_client'
require_relative './lib/email_receiver'

client = Kinja::Client.new(
  user: ENV["KINJA_USER"],
  password: ENV["KINJA_PASSWORD"]
)

post '/' do
  email = EmailReceiver.receive request
  post = client.post(
    headline: email.subject,
    body: email.body.decoded,
    status: "DRAFT",
    source: 'markdown'
  )
  status 200
  # content_type :json
  # { url: post["data"]["permalink"] }.to_json
end
