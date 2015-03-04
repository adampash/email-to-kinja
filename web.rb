require 'sinatra'
require 'kinja'
require 'json'
require 'redcarpet'
require 'simple_scrubber'
require_relative './lib/post_client'
require_relative './lib/email_receiver'

client = Kinja::Client.new(
  user: ENV["KINJA_USER"],
  password: ENV["KINJA_PASSWORD"]
)
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(autolink: true, hard_wrap: true))

post '/' do
  email = EmailReceiver.receive request
  post = client.post(
    headline: "Subject: #{email.subject}",
    body: markdown.render(SimpleScrubber.scrub(email.body.decoded, [:email, :phone])),
    status: "DRAFT"
  )
  puts post
  status 200
end
