require 'redis'
require 'json'

# class names gotta start w/ a capital letter
#
class Workflowtype

	# retrieve workflows from redis hash w/ this key.
	# redis.hvals(REDIS_KEY)
	REDIS_KEY="h_workflowtypes"

	# retrive the next ID for a workflow type when creating a new workflowtype
	# id=redis.hincrby(REDIS_KEY, REDIS_HASH_KEY_IDGEN, 1)
	REDIS_ID_KEY="i_workflowtypes_idkey"

	attr_accessor :id, :name

	def initialize(options = {})
		@id=options[:id]
		@name=options[:name]
	end

	def save!
		redis = Redis.new
		if @id.nil?
			@id=redis.incrby(REDIS_ID_KEY, 1)
		end

		# this returns true if it's a new hash entry and false if it's an update
		# to an existing hash entry
		redis.hset(REDIS_KEY, @id, self.to_json)

		# if it doesn't barf, then the save succeeded
		true
	end

	# define equality.
	# not the same as == operator, which defines objects by their identity.
	# eql? is important b/c hashes use it to test key equality.
	# also note: instance_of? is more strict than is_a? - subclasses of
	# WorkflowType return false for instance_of?, but true for is_a?
	#
	# if you want == to behave the same as eql?, you could alias it like so:
	# alias == eql?
	# and then w1 == w2 or w1.eql?(w2) would do the same thing
	def eql?(other)
		if other.instance_of?(Workflowtype)
			other.name.eql?(@name) && other.id.eql?(@id)
		else
			false
		end
	end

	def to_json
		hash={}
		self.instance_variables.each do |x|
			hash[x]=self.instance_variable_get(x)
		end
		hash.to_json
	end

	def self.from_json(s)
		hash=JSON.parse(s)
		w=self.new
		hash.each do |x,y|
			w.instance_variable_set(x,y)
		end
		w
	end

	def self.all
		lstWorkflowtypes=[]
		redis = Redis.new
		redis.hvals(REDIS_KEY).each do |x|
			p "#{x}"
			lstWorkflowtypes.push(Workflowtype.from_json(x))
		end

		lstWorkflowtypes
	end


end
