require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'


# this'll catch all 400s you try to return.
# the bad thing is, if you try to return 400 from a json
# endpoint, you'll still invoke this on the status code
# and you'll really piss off the browser ...
# error 400 do
# 	haml :error404
# end

# return an error code?
get '/baz' do
	status 400
	haml :error404
	# if the 404 handler above was enabled, you'd be able to just return the integer 400 here
	# and it'd take care of the rest ...
end

# return an error code and msg?
# ... and json?
get '/bar' do
	status 400
	json :foo=>'bar'
end

# return json? - this requires sinatra/json above (and gem install sinatra-contrib)
get '/foo' do
	json :foo=>'bar'
end

get '/' do
	haml :index
end
