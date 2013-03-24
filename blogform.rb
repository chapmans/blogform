require 'rubygems'
require 'data_mapper'
require 'dm-migrations'
require 'sinatra'
require 'haml'

# Database stuff

DataMapper::setup(:default, 'postgres://username:pass@localhost/blogform')

class User
  include DataMapper::Resource
  property :id, Serial
  property :username, String
  property :password, String
  property :email, String
end

class Post
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :body, Text
  property :date, DateTime
  property :status, Integer
end

class Link
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :url, String,    :length => 255
  property :desc, Text
  property :created_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!


# For authentication. (This is a single user personal blog, so whatever.)
set :username, 'username'
set :password, 'password'
set :token, 'f4rB3Nl0v#)hLO^3tEX75+@r'

# Partial
helpers do
  def partial(page, options={})
    haml page, options.merge!(:layout => false)
  end
end


# Routes!

get '/' do
  @posts = Post.all(:order => [ :id.desc ], :limit => 20)
  haml :index
end

get '/movement' do
  haml :admin
end

post '/movement' do
  if params['username'] == settings.username && 
        params['password'] == settings.password
    response.set_cookie(settings.username, settings.token)
    redirect '/movement/post'
  else
    "Username or Password Incorrect"
  end
end

get '/:id' do
  haml :post
end

get '/movement/*' do
  # authenticate
  pass unless request.cookies[settings.username] != settings.token
    halt [401, 'Not Authorized']
end

get '/movement/post' do
  haml :adminpost
end

post '/movement/post' do
  post = Post.create(:title => title, :body => body, 
                     :date => Time.now, :status => status)
  haml :adminpost
end

put '/movement/post/:id' do
  post = Post.get(:id)
  post.update(:title => title, :body => body, 
                     :date => Time.now, :status => status)
  haml :adminpost
end

delete '/movement/post/:id' do
  post = Post.get(:id)
  post.destroy
  haml :adminpost
end

