require 'sinatra'
require 'sinatra/reloader'

get '/' do
	haml :index
end
