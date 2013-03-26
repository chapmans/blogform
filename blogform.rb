require 'rubygems'
require 'data_mapper'
require 'dm-migrations'
require 'compass'
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


# Routes!

get '/' do
  @posts = Post.all(:status => 1, :order => [ :id.desc ], :limit => 20)
  haml :index
end

get '/movement' do
  if request.cookies[settings.username] == settings.token
    redirect '/movement/'
  else 
    haml :login
  end
end

post '/movement/login' do
  if params['username'] == settings.username && 
        params['password'] == settings.password
    response.set_cookie(settings.username, settings.token)
    redirect '/movement/post'
  else
    "Username or Password Incorrect"
  end
end

get '/movement/logout' do
  response.set_cookie(settings.username, false)
  redirect '/movement'
end

get '/:id' do
  haml :post
end

get '/movement/*' do
  # authenticate
  pass unless request.cookies[settings.username] != settings.token
  redirect '/movement'
end

get '/movement/post' do
  haml :adminpost
end

post '/movement/post' do
  status = if params['status'] == "Submit" then 1
           elsif params['status'] == "Save" then 2
           else 0 end
  post = Post.create(:title => params['title'], :body => params['body'], 
                     :date => Time.now, :status => status)
  
  redirect '/movement/post/:post-id'
  # haml :adminpost
end

get '/movement/post/:id' do
  post = Post.get(:id)
  haml :adminpost
end

put '/movement/post/:id' do
  post = Post.get(:id)
  post.update(:title => params['title'], :body => params['body'], 
                     :date => Time.now, :status => params['status'])
  haml :adminpost
end

delete '/movement/post/:id' do
  post = Post.get(:id)
  post.destroy
  haml :adminpost
end

