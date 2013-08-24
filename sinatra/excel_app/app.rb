require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'mongooz'

Mongooz.defaults :db=>'oem_agreements'

configure :production do
	puts "in prod"
end
configure :development do
	puts "in dev"
end


require './oem_in.rb'

# my first (shitty) piece of rack middleware!
class Midz
	def initialize(app,*args,&bl)
		@app=app
		@envstr=args[0] || "no string was provided to the ctor of Midz"
		yield if bl
	end

	def call(env)
		env["foo"]="barz"
		env["fooz"]=@envstr if @envstr
		@app.call(env)
	end
end

use Midz do
	puts "hi there, from midz init block" # should get called once when the server fires up
end


# this'll catch all 400s you try to return.
# the bad thing is, if you try to return 400 from a json
# endpoint, you'll still invoke this on the status code
# and you'll really piss off the browser ...
#
# error 400 do
# 	haml :error404
# end



# return an error code?
# get '/baz' do
# 	status 400
# 	haml :error404
# 	# if the 404 handler above was enabled, you'd be able to just return the integer 400 here
# 	# and it'd take care of the rest ...
# end

# # return an error code and msg?
# # ... and json?
# get '/bar' do
# 	status 400
# 	json :foo=>'bar'
# end

# # return json? - this requires sinatra/json above (and gem install sinatra-contrib)
# get '/foo' do
# 	json :foo=>'bar'
# end

get '/' do
	haml :index
end
