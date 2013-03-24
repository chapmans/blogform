require 'rubygems'
require 'data_mapper'
require 'sinatra'
require 'haml'

# Partial

def partial(page, options={})
  haml page, options.merge!(:layout => false)
end


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
  property :created_at, DateTime
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

User.auto_upgrade!
Post.auto_upgrade!
Link.auto_upgrade!

get '/' do
  @posts = Post.all(:order => [ :id.desc ], :limit => 20)
  haml :index
end

get '/movement' do
  haml :admin
end

