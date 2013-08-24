
class OEMIn<Mongooz::MongoozHash
end

get '/service/oem/in' do
	json OEMIn.db_get_paged
end

get '/service/oem/in/:id' do |id|
	json OEMIn.db_get_with_id :_id=>id
end

post '/service/oem/in' do
	response=OEMIn.new
	response.update(params)
	begin
		response[:_id]=response.db_insert
	rescue Exception => e
		status 400
		response={:error => e.message}
	end

	json response
end
