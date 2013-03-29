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
  property :created_at, DateTime
  property :status, Integer
  property :private, Boolean, :default => false
  
  has n, :tags, :through => Resource
end

class Link
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :url, String,      :length => 255
  property :desc, Text
  property :created_at, DateTime
end

class Tag
  include DataMapper::Resource
  property :id, Serial
  property :tag, String
  
  has n, :posts, :through => Resource
end

DataMapper.finalize
DataMapper.auto_upgrade!


# For authentication. (This is a single user personal blog, so whatever.)
set :username, 'username'
set :password, 'password'
set :token, 'f4rB3Nl0v#)hLO^3tEX75+@r'


# Routes!

# Home

get '/' do
  @posts = Post.all(:status => 1, :order => [ :id.desc ], :limit => 5)
  haml :index
end

get '/post/:id' do
  haml :post, :locals => {:id => params[:id]}
end

# Login
get '/movement/login' do
  if request.cookies[settings.username] == settings.token
    redirect '/movement/dash'
  else 
    haml :login
  end
end

post '/movement/login' do
  if params[:username] == settings.username && 
        params[:password] == settings.password
    response.set_cookie(settings.username, settings.token)
    redirect '/movement/dash'
  else
    "Username or Password Incorrect"
  end
end

get '/movement/logout' do
  response.set_cookie(settings.username, false)
  redirect '/movement/login'
end

get '/movement/*' do
  # authenticate
  pass unless request.cookies[settings.username] != settings.token
  redirect '/movement/login'
end

# Admin Panel

# Dashboard

get '/movement/dash' do
  @sides = Link.all(:order => [ :created_at.desc ], :limit => 10)
  @notes = Post.all(:status => 0, :order => [ :date.desc ], :limit => 10)
  @drafts = Post.all(:status => 1, :order => [ :date.desc ], :limit => 10)
  @published = Post.all(:status => 2, :order => [ :date.desc ], :limit => 10)
  haml :dashboard
end

post '/movement/dash/note' do
  @post = Post.create(:title => "", :body => params[:note],
              :date => Time.now, :created_at => Time.now,
              :status => 0, :private => false)
  haml "#{@post[:id]}"
end

post '/movement/dash/note/update' do
  @post = Post.get(params[:id])
  @post.update(:body => params[:note], :date => Time.now)
  haml "#{@post[:id]}"
end

# New Post

get '/movement/new' do
  haml :adminpost
end

post '/movement/new' do
  status = if params[:status] == "Publish." then 2
           elsif params[:status] == "Save." then 1
           else 0 end
  post = Post.create(:title => params[:title], :body => params[:body], 
                     :date => Time.now, :created_at => Time.now, 
                     :status => status, :private => false)
  redirect "/movement/edit/#{post.id}"
  # haml :adminpost
end

# Update Post

get '/movement/edit/:id' do
  @post = Post.get(params[:id])
  haml :adminedit
end

post '/movement/edit/:id' do
  status = if params[:status] == "Publish" then 2
           elsif params[:status] == "Update" then 2
           elsif params[:status] == "Save" then 1
           else 0 end
  @post = Post.get(params[:id])
  @post.update(:title => params[:title], :body => params[:body], 
                     :date => Time.now, :status => status,
                     :private => params[:private])
  #params[:tags].each do |tag|
  #  @post.tags << tag
  #end
  @post.save
  haml :adminedit
end

delete '/movement/edit/:id' do
  post = Post.get(params[:id])
  post.destroy
  redirect '/movement/posts'
end

#tags

post '/movement/tag/add' do
  @tag = Tag.first_or_create(:tag => params[:tag])
  @post = Post.get(:tag => params[:postid])
  @post.tags << @tag
  @post.save
  haml "#{@tag[:id]}"
end

post '/movement/tag/remove' do
  tag = Tag.get(:id => params[:tagid])
  link = post.post_tags.first(:tag => tag)
  link.destroy
end

# Post Listing

get '/movement/posts' do
  haml :adminpost
end

# Sidebar Editing

get '/movement/sidebar' do
  @links = Link.all(:order => [ :created_at.desc ], :limit => 10)
  haml :adminside
end

post '/movement/sidebar/add' do
  @link = Link.create(:title => params[:title], :url => params[:url],
              :desc => params[:desc], :created_at => Time.now)
  haml "#{@link[:id]}"
end

# Options

get '/movement/options' do
  haml :adminpost
end
