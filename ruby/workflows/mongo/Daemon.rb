#
# this is a bunch of pseudo code for now - gotta give it some love!
#
class Daemon

	def initialize
		@redis=bla, init redis
		@list=bla, define the list to consume
	end

	def Process
		@redis.rblocklpop do |raw_item_as_json|
			item=nil
			begin
				item=WorkflowItem.from_json(raw_item_as_json)
			rescue => e
				log e
				return
			end

			if item.nil?
				log it and return
			end

			begin
				if !item.ready?
					item.save do
						item.feedback << "daemon encountered unready item #{item}"
						item.error
					end
					return
				end

				item.processing!
				item.each_step do |step|
					if !step.validates?(item) # the 'validates' function should start by adding feedback to the effect of "now executing foo step"
						item.save do
							item.step=step
							item.error
							item.feedback << "item #{item} failed at step #{step}"
						end
						return
					else
						item.step=step
						item.save
					end
				end
				
				# can only have gotten here if it went all the way to last step uninterrupted
				item.complete!
			rescue => e
				item.save do
					item.error
					item.feedback << "item #{item} failed with unexpected exception #{e}"
				end
			end
		end
	end#Process

	def RunForever
		while(true)
			begin
				Process
			rescue => e
				log e
			end
		end
	end
end
