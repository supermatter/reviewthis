require 'rubygems'
require 'sinatra'
require 'json'
require 'mustache/sinatra'
require 'pony'
require 'octopussy'

configure do
  set :mustache, {
     :views     => 'views/',
     :templates => 'templates/'
   }
   
  # regex's
  USER = /[^a-z0-9_]@([a-z0-9_]+)/i
  HASH = /[^a-z0-9_]#([a-z0-9_]+)/i
  REVIEW = /[^a-z0-9_](#reviewthis)[^a-z0-9_]+/i
  EMAIL = /\b([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4})\b/i
end

configure :production do
  # only run om Heroku
  set :from, ENV['SENDGRID_USERNAME']
  set :via, :smtp
  set :via_options, {
    :address        => "smtp.sendgrid.net",
    :port           => "25",
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => ENV['SENDGRID_DOMAIN'],
  }
  
end

configure :development, :test do
  set :from, 'info@localhost'
  set :via, :sendmail
  set :via_options, {}
end

helpers do
  def mail(params)
    body = mustache :email, {}, params
    Pony.mail(:to => params[:email], :from => options.from, :subject => "Code Review Request: from #{params[:commit_author]}", :body => body, :via => options.via, :via_options => options.via_options) 
  end
end

# test!
get '/' do
  "#reviewthis @github!"
end

# the meat
post '/' do
  push = JSON.parse(params[:payload])
  commit = push['commits'][0]
  message = commit['message']

  if message.match(REVIEW)
    
    # set some template vars
    vars = {
      :message => message,
      :commit_author => commit['author']['name'],
      :commit_url => commit['url'],
      :repo_name => push['repository']['name']
    }
    
    message.scan(USER) { |username|
      user = Octopussy.user(username) #github user info!
      vars[:username] = user.name
      vars[:email] = user.email
      mail(vars)
    }
  
    message.scan(EMAIL) { |email|
      vars[:username] = email
      vars[:email] = email
      mail(vars)
    }
  
  end
  
  return
end