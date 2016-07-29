ENV['RACK_ENV'] ||= 'development'
require 'sinatra/base'
require 'sinatra/flash'
require_relative 'data_mapper_setup'

class BookmarkManager < Sinatra::Base
  enable :sessions
  set :session_secret, 'super secret'
  register Sinatra::Flash

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end
  end

  get '/' do
    'Hello BookmarkManager!'
  end

  get '/links' do
    @links = Link.all
    erb :'links/index'
  end

  get '/links/new' do
    erb :'links/new'
  end

  get '/tags/:name' do
    tag = Tag.first(name: params[:name])
    @links = tag ? tag.links : []
    erb :'links/index'
  end


  post '/links' do
    link = Link.new(title: params[:title], url: params[:url])
    tags = params[:tag].split(", ")
    tag = tags.each do |tag|
      tag = Tag.first_or_create(name: tag)
      link.tags << tag
    end
    link.save
    redirect '/links'
  end

  get '/sign-up' do
    @user = User.new
    erb :'links/userform'
  end

  post '/newuser' do
    @user = User.new(
      username: params['username'],
      email: params['email'],
      password: params['password'],
      password_confirmation: params['password confirmation'])
    if @user.save
      session[:user_id] = @user.id
      redirect '/welcome'
    else
      flash.now[:notice] = "Please enter matching passwords, dumbass"
      erb :'links/userform'
    end
  end

  get '/welcome' do
    erb :'links/welcome'
  end
  # start the server if ruby file executed directly
  run! if app_file == $0
end
