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

post '/' do
  email = EmailReceiver.receive request
  subject = EmailReceiver.scrub_fwd(email.subject)
  email_body = SimpleScrubber.scrub(
    EmailReceiver.scrub_space(email.body.decoded.strip),
    [:email, :phone]
  )

  body = EmailReceiver.convert(
    EmailReceiver.clean_lines(
      EmailReceiver.clean_google_group_footer(email_body)
    )
  )

  puts "==========================="
  puts "HEY LET'S DEBUG THIS SHIT"
  puts body
  puts "==========================="

  post = client.create_post(
    headline: "Subject: #{subject}",
    body: body,
    status: "PUBLISHED",
    defaultBlogId: 1634480626
  )
  puts post
  url = post["data"]["permalink"]
  if url.scan(/^https?:\/\//).length > 0
    puts url.scan(/^https?:\/\//)
    puts url.scan(/^https?:\/\//).length
    puts "url good as is"
  else
    puts url.scan(/^https?:\/\//)
    puts "need to add domain to url"
    url = "http://publicpool.kinja.com#{post["data"]["permalink"]}"
  end
  puts url
  if subject.length > 117
    overage = subject.length - 117
    subject = subject[0...-overage]
  end
  twitter.update "#{subject} #{url}"
  status 200
end
