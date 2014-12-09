require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'
require 'pry'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/' do
  erb :index
end

get '/meetups_list' do
  @meetups = Meetup.all
  erb :meetups_list
end

get '/meetups/:id' do
  @meetups = Meetup.find(params[:id])

  erb :meetups
end

get '/create_meetup' do

  erb :create_meetup
end

post '/create_meetup' do
  @name = params[:name]
  @description = params[:description]
  @location = params[:location]
  @all = Meetup.create(name: @name, description: @description, location: @location)
  # The params come from the form name section on index.erb.

  if @name.empty? || @description.empty? || @location.empty?
    flash[:notice] = "You must enter information in every field"

    redirect "/create_meetup"
  else
     flash[:notice] = "You have successfully created a meetup."
     redirect "/meetups/#{@all[:id]}"
  end
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/meetups_list'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end
