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
							feed = get_feed(source.rss_url)

							prompt = Config::AI::ARTICLE_PROMPT % {
								subject_area: @publication.subject_area,
								beat_descriptions: @publication.beats.map { |b| { b.slug => b.description } }.to_json,
								json: feed.reduce([]) { |acc, i| acc << { headline: i['headline'], article: i['article'] } }.to_json
							}
# puts prompt	# return
							ai = (Config::AI::ACTIVE_PROVIDER).completion(prompt)
ai.each { |a| puts a['tags'].to_json } # return
							rv = feed.map.with_index { |item, i| item.merge(ai[i]) }
# puts ai.to_json; # return
# ai.each { |i| puts i.keys.to_s }
							now = Time.now.utc.to_s
							sheet_data = rv.reduce([]) do |acc, item|
# puts item['tags'].to_json
								item.delete('article')
								['beat_relevance', 'celebrities', 'tags'].each { |k| item[k] = item[k].to_a.to_s }
								item = item.values
								acc << (item.unshift(Config::AI::ACTIVE_PROVIDER.model) << now)
							end
# puts sheet_data.to_json
# url:, spreadsheet_id:, worksheet_id:, sheet_data
							send_to_sheet(
								url: Config::Pipedream::ARRAY_TO_SHEET_URL,
								spreadsheet_id: Config::Pipedream::GOOGLE_SHEET_ID,
								worksheet_id: 0,
								sheet_data: sheet_data
							)

							rv.each do |item|
								Article.create(
									publication_id: @publication.id,
									source_id: source.id,
									ai_model: Config::AI::ACTIVE_PROVIDER.model,
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
