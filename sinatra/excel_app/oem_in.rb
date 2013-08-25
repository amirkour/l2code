
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

put '/service/oem/in' do
	response=OEMIn.new
	response.update(params)

	if response[:_id].nil?
		status 400
		break json({:error=>"Cannot update without _id param"})
	end

	# when mongo objects serialize out to json, BSON IDs end up looking like
	# this in javascript land:
	# {_id: {"$oid":"123123123"}}
	#
	# will attempt to parse bson out of the _id key if it's a hash
	if response[:_id].kind_of?(Hash)
		if response[:_id]["$oid"].nil?
			status 400
			break json({:error=>"Expected _id hash to have an $oid property"})
		end

		begin
			response[:_id]=BSON::ObjectId(response[:_id]["$oid"])
		rescue
			status 400
			break json({:error=>"Could not parse $oid of _id to bson"})
		end
	end

	begin
		if response.db_update
			response={:success=>true}
		else
			status 400
			response={:error=>"Failed to update"}
		end
	rescue Exception=>e
		status 400
		response={:error=>e.message}
	end

	json response
end
