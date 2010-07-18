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
  HASH = /[^a-z0-9_]#([a-z0-9_]+)/i # not used yet, but perhaps soon?
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
    set :from, 'reviewthis@localhost'
  set :via, :sendmail
  set :via_options, {}
end

helpers do
  def mail(vars)
    body = mustache :email, {}, vars
    html_body = mustache :email_html, {}, vars    
    Pony.mail(:to => vars[:email], :from => options.from, :subject => "[#{vars[:repo_name]}] code review request from #{vars[:commit_author]}", :body => body,:html_body => html_body, :via => options.via, :via_options => options.via_options) 
  end
end

# test!
get '/' do
  "#reviewthis @github!"
end

# the meat
post '/' do
  push = JSON.parse(params[:payload])
  
  # check every commit, not just the first
  push['commits'].each do |commit|

    message = commit['message']

    if message.match(REVIEW)
    
      # set some template vars
      vars = {
        :commit_id => commit['id'],
        :commit_message => message,
        :commit_timestamp => commit['timestamp'],
        :commit_relative_time => Time.parse( commit['timestamp'] ).strftime("%m/%d/%Y at %I:%M%p"),
        :commit_author => commit['author']['name'],
        :commit_url => commit['url'],
        :repo_name => push['repository']['name'],
        :repo_url => push['repository']['url'],        
      }
    
      message.scan(USER) do |username|
        user = Octopussy.user(username) #github user info!
        vars[:username] = user.name
        vars[:email] = user.email
        mail(vars)
      end
  
      message.scan(EMAIL) do |email|
        vars[:username] = email
        vars[:email] = email
        mail(vars)
      end
  
    end
    
  end
  
  return
end