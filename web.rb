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
  puts params
  puts EmailReceiver.receive request
  # url = params[:url]
  # post_json = PostClient.get_post_json(url)
  # post = client.post(
  #   headline: '',
  #   body: PostClient.format_body(post_json),
  #   status: "PUBLISHED"
  # )
  status 200
  # content_type :json
  # { url: post["data"]["permalink"] }.to_json
end
