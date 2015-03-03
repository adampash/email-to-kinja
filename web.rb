require 'sinatra'
require 'kinja'
require 'json'
require_relative './lib/post_client'
require_relative './lib/email_receiver'

client = Kinja::Client.new(
  user: ENV["KINJA_USER"],
  password: ENV["KINJA_PASSWORD"]
)
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

post '/' do
  email = EmailReceiver.receive request
  post = client.post(
    headline: email.subject,
    body: markdown.render(email.body.decoded),
    status: "DRAFT"
  )
  status 200
  # content_type :json
  # { url: post["data"]["permalink"] }.to_json
end
