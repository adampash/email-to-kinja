require 'sinatra'
require 'kinja'
require 'json'
require 'redcarpet'
require 'simple_scrubber'
require 'twitter'
# require 'dotenv'
# Dotenv.load
require_relative './lib/post_client'
require_relative './lib/email_receiver'

client = Kinja::Client.new(
  user: ENV["KINJA_USER"],
  password: ENV["KINJA_PASSWORD"]
)

twitter = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
  config.access_token        = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_SECRET"]
end

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(autolink: true, hard_wrap: true))

post '/' do
  email = EmailReceiver.receive request
  subject = EmailReceiver.scrub_fwd(email.subject)
  post = client.create_post(
    headline: "Subject: #{subject}",
    body: markdown.render(SimpleScrubber.scrub(email.body.decoded.strip, [:email, :phone])),
    status: "PUBLISHED",
    defaultBlogId: "1634480626"
  )
  url = post["data"]["permalink"]
  puts url
  twitter.update "#{subject} #{url}"
  status 200
end
