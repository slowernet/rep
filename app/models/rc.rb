class Source < Ohm::Model; end
class Beat < Ohm::Model; end
class Story < Ohm::Model; end
class Article < Ohm::Model; end

class Publication < Ohm::Model
	include Ohm::Timestamps

	attribute :name
	attribute :subject_area
	attribute :mailerlite_group_id
	collection :sources, :Source
	collection :beats, :Beat
	collection :articles, :Article
end

class Beat < Ohm::Model
	include Ohm::Timestamps

	reference :publication, :Publication
	attribute :name
	attribute :slug
	attribute :description
end

class Article < Ohm::Model
	include Ohm::Timestamps

	reference :publication, :Publication
	reference :source, :Source
	attribute :url
	attribute :ai_model
	attribute :json
end

class Source < Ohm::Model
	include Ohm::Timestamps

	reference :publication, :Publication
	attribute :rss_url
	attribute :feed_url
	attribute :home_url
	attribute :name
	attribute :shortname
	attribute :active; index :active
end

class Subscriber < Ohm::Model
	include Ohm::Timestamps

	attribute :email
	attribute :mailerlite_id
	attribute :mailerlite_groups
end
