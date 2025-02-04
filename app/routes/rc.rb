require "./app/helpers/helpers"

class RCApp < Roda
	plugin :render, views: 'app/views'
	plugin :halt
	plugin :json_parser
	plugin :all_verbs

	include Helpers

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
							rss = URI.open(request.POST['feed_url']).read
							now = Time.now.utc
							rv = RSS::Parser.parse(rss).items.reduce([]) do |acc, item|
								next acc if (now - item.pubDate.utc) > (1 * 86400)
								i = {}
								i['headline'] = item.title
								i['unique_id'] = item.guid.content
								i['publication_date'] = item.pubDate
								i['url'] = item.link
								i['article'] = item.description.strip
								acc << i
							end

							prompt = Config::AI::ARTICLE_PROMPT % {
								subject_area: @publication.subject_area,
								beat_array: @publication.beats.map(&:name).to_s,
								json: rv.reduce([]) { |acc, i| acc << { headline: i['headline'], article: i['article'] } }.to_json
							}
							ai = (Config::AI::ACTIVE_PROVIDER).completion(prompt)
# puts prompt
# puts ai.to_json; # return
# ai.each { |i| puts i.keys.to_s }

							rv = rv.map.with_index { |item, i| item.merge(ai[i]) }

							sheet_data = rv.reduce([]) do |acc, item|
								item.delete('article')
								['beat_relevance', 'celebrities'].each { |k| item[k] = item[k].to_a.to_s }
								acc << item.values.unshift(Time.now.utc.to_s, Config::AI::ACTIVE_PROVIDER.model)
							end
# puts sheet_data.to_json
							Faraday.new(
								headers: { 'Content-Type' => 'application/json' }
							).post('https://eog0lukzxhxoozf.m.pipedream.net') do |req|
								req.body = {
									spreadsheet_id: '1SIfu-9CnbCGBDUJZdKfv7LomJp5cArABHpeAHp54Izw',
									worksheet_id: 0,
									rows: sheet_data
								}.to_json
							end

							rv.to_json
						end
					end
				end
			end
		end
	end
end
