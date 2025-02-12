require 'open-uri'

module Sourcer
	def get_feed(url)
		feed = URI.open(url).read
		now = Time.now.utc
		items = SimpleRSS.parse(feed).items
		# RSS::Parser.parse(rss).items.reduce([]) do |acc, item|
		items.reduce([]) do |acc, item|
			next acc if (now - item.pubDate.utc) > (5 * 86400)
			i = {}
			i['headline'] = item.title
			i['article'] = item.description.strip
			i['unique_id'] = item.guid.is_a?(String) ? item.guid : item.guid.content
			i['publication_date'] = item.pubDate
			i['url'] = item.link
			acc << i
		end
	end

	def send_to_sheet(url:, spreadsheet_id:, worksheet_id:, sheet_data:)
		Faraday.new(
			headers: { 'Content-Type' => 'application/json' }
		).post(url) do |req|
			req.body = {
				spreadsheet_id: spreadsheet_id,
				worksheet_id: worksheet_id,
				rows: sheet_data
			}.to_json
		end
	end
end

module Picker
end
