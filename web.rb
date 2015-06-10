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
  body = markdown.render(SimpleScrubber.scrub(email.body.decoded.strip, [:email, :phone]))
  footer = "<hr><p><em>Public Pool is an automated feed of <a href=\"http://politburo.kinja.com/here-are-all-the-white-house-pool-reports-1691913651\">White House press pool reports</a>. For live updates, follow <a href=\"https://twitter.com/whpublicpool\">@WHPublicPool</a> on Twitter.</em></p>"
  post = client.create_post(
    headline: "Subject: #{subject}",
    body: "#{body} #{footer}",
    status: "PUBLISHED",
    defaultBlogId: 1634480626
  )
  if url.scan(/^https?:\/\//).length > 0
    puts url.scan(/^https?:\/\//)
    puts url.scan(/^https?:\/\//).length
    puts "url good as is"
    url = post["data"]["permalink"]
  else
    puts url.scan(/^https?:\/\//)
    puts "need to add domain to url"
    url = "http://publicpool.gawker.com#{post["data"]["permalink"]}"
  end
  puts url
  if subject.length > 117
    overage = subject.length - 117
    subject = subject[0...-overage]
  end
  twitter.update "#{subject} #{url}"
  status 200
end
