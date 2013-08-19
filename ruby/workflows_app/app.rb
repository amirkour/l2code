require 'sinatra'
require 'sinatra/reloader'

# tell haml engine to default to html5 declaration when you use "!!!" at the top of your .haml
set :haml, :format=>:html5

get '/' do
	haml :index, :locals => {:foo=>'baradsf'}
end