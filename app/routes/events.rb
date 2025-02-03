require "./app/helpers/helpers"

class EventsApp < Roda
	plugin :halt
	# plugin :json_parser

	include Helpers

	$nest = Nest.new('events')

	route do |r|
		response['Content-Type'] = 'application/json'

		r.post do
			events = JSON.parse(request.body.read)
			events.map do |e|
				Ohm.redis.call('xadd', 'events', '*', 'type', e.delete('type'), 'data', e.to_json)
			end.size.to_json
		end

	end
end
