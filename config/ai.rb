module AI
	module OpenAI; end
	module Gemini; end
end

module Config
	module AI
		module OpenAI
			# MODEL = 'gpt-4o-mini'
			MODEL = 'gpt-4o'
		end

		module Gemini
			MODEL = 'gemini-1.5-flash'
			# MODEL = 'gemini-2.0-flash-exp'	# does not handle JSON yet?
		end

		# ACTIVE_PROVIDER = ::AI::Gemini
		ACTIVE_PROVIDER = ::AI::OpenAI

		ARTICLE_PROMPT = <<~EOT
Please process the below headline-article pairs, returning the following for each content pair:
* "subject_relevance"
	** A score on a scale 0 to 1 indicating the relevance of the the content to the subject area: %{subject_area}.
* "newsworthiness"
	* A score on a scale 0 to 1 indicating the newsworthiness of the the content in the context of the subject area.
		* The following are factors in newsworthiness:
			* the number of people likely to be affected by the news
			* the amount of disruption the news could cause,
			* how unexpected the news is in the context of the subject area,
* "sponsoredness"
		A score on a scale 0 to 1 indicating the probability that the content is sponsored content or paid advertising.
	* Return this as "sponsoredness"
* "beat_relevance"
	* An object of describing the strength of association of the content to each of these concepts: %{beat_array} on a scale of 0 to 1
* "celebrities"
	* An array of names of all well-known people or celebrities in the United States associated with the content
	* If none are present, return an empty array
* "summary"
	* A one sentence summary of the article content, that
		* does not repeat the language of the headline or the article
		* adds interesting information and detail about the item from the article that is not present in the headline
		* uses a voice indicating some expertise of the content subject area
		* is not prefaced with introductory language like "The piece discusses..." or "The article explores..".

```json
%{json}
```
EOT
	end
end
