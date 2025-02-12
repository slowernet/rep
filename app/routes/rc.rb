require "./app/helpers/helpers"

class RCApp < Roda
	plugin :render, views: 'app/views'
	plugin :halt
	plugin :json_parser
	plugin :all_verbs

	include Helpers
	include Sourcer

	route do |r|
		r.root do
			r.redirect 'publications/1'
		end

		r.on 'publications' do
			r.on :id do |id|
				@publication = Publication[id]
				view :rc
			end
		end

		r.on 'api' do
			response['Content-Type'] = 'application/json'

			r.on 'subscribers' do
				r.post 'webhook' do
					# https://developers.mailerlite.com/docs/webhooks.html#security
					# https://developers.mailerlite.com/docs/webhooks.html#payloads
puts r.env['Signature']
digest = OpenSSL::Digest.new('sha256')
puts OpenSSL::HMAC.hexdigest(digest, ENV['MAILERLITE_WEBHOOK_SECRET'], request.POST.to_s)
puts request.POST
					# from mailerlite, data may be batched
				end
			end

			r.on 'publications' do
				r.on :id do |id|
					@publication = Publication[id]
					r.on 'sources' do
						r.get do
							@publication.sources.to_a.map { |s| s.attributes.merge(id: s.id) }.to_json
						end
					end

					r.on 'beats' do
						r.get do
							@publication.beats.to_a.map { |s| s.attributes.merge(id: s.id) }.to_json
						end
					end

					r.on 'articles' do
						r.put do
							source = Source[request.POST['source_id']]
							feed = get_feed(source.feed_url)

							prompt = Config::AI::SOURCER_PROMPT % {
								subject_area: @publication.subject_area,
								beat_descriptions: @publication.beats.map { |b| { b.slug => b.description } }.to_json,
								json: feed.reduce([]) { |acc, i| acc << {
									headline: i['headline'],
									article: i['article']
								} }.to_json
							}
puts prompt	# return
							ai = (Config::AI::ACTIVE_PROVIDER).completion(prompt)
puts ai.to_json; return
# ai.each { |a| puts a['tags'].to_json } # return
							rv = feed.map.with_index do |item, i|
								item['source'] = source.name
								item.merge(ai[i])
							end
# ai.each { |i| puts i.keys.to_s }
# pp rv[0].to_json; return

							now = Time.now.utc.to_s
							sheet_data = rv.reduce([]) do |acc, item|
# puts item['tags'].to_json
								# item.delete('article')
								['beat_relevance', 'celebrities', 'tags'].each { |k| item[k] = item[k].to_a.to_s }
								item = item.values
								acc << (item.unshift(Config::AI::ACTIVE_PROVIDER.model) << now)
							end
puts sheet_data.to_json
# url:, spreadsheet_id:, worksheet_id:, sheet_data
							send_to_sheet(
								url: Config::Pipedream::ARRAY_TO_SHEET_URL,
								spreadsheet_id: Config::Pipedream::GOOGLE_SHEET_ID,
								worksheet_id: 0,
								sheet_data: sheet_data
							)

# puts "**#{source.name}**<br>"
# puts "#{Config::AI::ACTIVE_PROVIDER.model}"; puts; puts
							rv.each do |item|
# puts "#{item['top_concept']}"
# puts "**#{item['headline']}** [#{source.name}]"
# puts "#{item['combined_summary']}"; puts
# puts "- " + item['article']
# puts "- " + item['summary']
# puts; puts
								Article.create(
									publication_id: @publication.id,
									source_id: source.id,
									ai_model: Config::AI::ACTIVE_PROVIDER.model,
									prompt_info: Config::AI::SOURCER_PROMPT_INFO,
									url: item['url'],
									json: item.to_json
								)
							end

							rv.to_json
						end
					end
				end
			end
		end
	end
end
