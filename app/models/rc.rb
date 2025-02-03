class Source < Ohm::Model; end
class Beat < Ohm::Model; end
class Story < Ohm::Model; end
class Publication < Ohm::Model; end

class Publication < Ohm::Model
	include Ohm::Timestamps

	attribute :name
	attribute :subject_area
	collection :sources, :Source
	collection :beats, :Beat
	collection :articles, :Article
end

class Beat < Ohm::Model
	include Ohm::Timestamps

	reference :publication, :Publication
	attribute :name
end

class Article < Ohm::Model
	include Ohm::Timestamps

	reference :publication, :Publication
	attribute :url
	reference :beat, :Beat
	attribute :beat_scores
end

class Source < Ohm::Model
	include Ohm::Timestamps

	reference :publication, :Publication
	attribute :rss_url
	attribute :home_url
	attribute :name
	attribute :active; index :active
end
