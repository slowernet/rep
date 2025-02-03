# frozen-string-literal: true

require 'bundler'
Bundler.require

%w(config/initializers).each { |p| Dir["./#{p}/**/*.rb"].each  { |rb| require rb } }
%w(lib app/models app/routes app/helpers).each { |p| Dir["./#{p}/**/*.rb"].each  { |rb| require rb } }

class App < Roda
	plugin :render, views: 'app/views'
	plugin :public

	plugin :all_verbs
	plugin :json_parser

	plugin :multi_run
	App.run "unlock", UnlockApp
	App.run "events", EventsApp

	include Helpers

	route do |r|
		r.public

		r.multi_run

		r.on 'rc' do

			r.is do
				@publication = Publication[1]
				view :rc
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
								rss = URI.open(request.POST['feed_url']).read
								now = Time.now.utc
								rv = RSS::Parser.parse(rss).items.reduce([]) do |acc, item|
									next acc if (now - item.pubDate.utc) > (5 * 86400)

									i = {}
									i['headline'] = item.title
									i['unique_id'] = item.guid.content
									i['publication_date'] = item.pubDate
									i['url'] = item.link
									i['article'] = item.description.strip
									acc << i
								end
return rv.to_json
								prompt = AI::ARTICLE_PROMPT % {
									subject_area: @publication.subject_area,
									beat_array: @publication.beats.map(&:name).to_s,
									json: rv.reduce([]) { |acc, i| acc << { headline: i['headline'], article: i['article'] } }.to_json
								}

								response = $openai.chat(
									parameters: {
										model: AI::OPENAI::MODEL,
										response_format: AI::OPENAI::RESPONSE_FORMAT,
										messages: [{ role: "user", content: prompt }]
									}
								)
								ai = response.dig("choices", 0, "message", "content")
								ai = JSON.parse(ai).dig('results')

								rv.map.with_index { |item, i| item.merge(ai[i]) }.to_json
							end
						end
					end
				end
			end
		end

		r.root do
			view :index
		end
	end
end
