require 'rubygems'
require 'sinatra'
require 'json'


configure :production do
  # only run om Heroku
end

# test!
get '/' do
  "Reviewthis @github!"
end

post '/' do
  push = JSON.parse(params[:payload])
  "Commit message: #{push['commits'][0]['message']}"
end