module AI
	module OpenAI; end
	module Gemini; end
end

module Config
	module AI
		module OpenAI
			MODEL = 'gpt-4o-mini'
			# MODEL = 'gpt-4o'
		end

		module Gemini
			# MODEL = 'gemini-1.5-flash'
			MODEL = 'gemini-2.0-flash'
			# MODEL = 'gemini-2.0-flash-lite-preview-02-05'
		end

		ACTIVE_PROVIDER = ::AI::Gemini
		# ACTIVE_PROVIDER = ::AI::OpenAI
puts `pwd`
		SOURCER_PROMPT = File.read('./config/prompts/sourcer.txt').freeze
		SOURCER_PROMPT_INFO = `TZ=UTC git log -1 --date=format-local:":%Y-%m-%d %H:%M:%S %z" --format="%h %cd" -- config/prompts/sourcer.txt`.strip.freeze
		PICKER_PROMPT = File.read('./config/prompts/picker.txt').freeze
		PICKER_PROMPT_INFO = `TZ=UTC git log -1 --date=format-local:":%Y-%m-%d %H:%M:%S %z" --format="%h %cd" -- config/prompts/picker.txt`.strip.freeze
	end

end

# Assist users with taxonomic classification and identification of keywords pertaining to the residential real estate industry in written content in the form headline-article pairs. The purpose of generating these keywords is to help populate the tags field of a content management system.

# The task involves identifying relevant keywords in the headline-article pairs, using inference to identify key concepts, classifying entities into their respective categories (people, companies and organizations, concepts, and places), and delivering key terms pertinent to the residential real estate industry.

# *Requirements*

# 1. Categories:
#    - People
#    - Companies and Organizations
#    - Concepts
#    - Places

# 2. Constraints:
#    - Scoring: Assign a score between 0.0 and 1.0 to each node indicating the strength of its association, 1.0 being the highest.
#    - Node Limitation: Limit the total number of nodes  returned across all categories to 20.
#    - Place Specificity: Favor more specific regions or cities. If an extracted city has fewer than 250,000 residents, use its state instead. For cities with a metropolitan area population over one million, do not include a State or Province in the name.
#    - Do not include "United States" in the "Places" category.
#    - Naming Conventions: Use correct capitalization and spacing for each node name. In the event that a company, organization, concept, or place has a commonly known acronym or abbreviated form, also include that form and score in the results, in a separate node from the full form.
#    - Articles sometimes contain an initial paragraph consisting of advertising copy for an event or another product sold by the company publishing the article. Exclude these paragraphs from the classification.
#    - Omit the extraction of numbers, dates, monetary values, and roles or details.
#    - Focus strictly on entity names significant in the residential real estate industry.

# 3. Output:
#    - The response should be structured in JSON format.
# 	 - Include only the JSON in the response.
# 	  - Categorize the extracted information into the following keys:
#      - "people"
#      - "companies-and-organizations"
#      - "concepts"
#      - "places"
#      - Subcategorize the extracted information into the following keys:
#      - "name"
#      - "score"

# 4. Prioritization:
#    - Prioritize the most significant concepts, people, companies, organizations, and places.
#    - Reduce weighting for companies and organizations in the media industry.
#    - Discard any nodes with a score less than or equal to 0.8.
#    - Categorize media companies such as "The New York Times" under "Companies and Organizations" rather than "Concepts".
