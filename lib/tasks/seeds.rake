namespace :seeds do
	desc 'create publications'
	task :publications => :environment do
		Publication.create({"name"=>"Real Estate", "subject_area"=>"The residential real estate industry, including brokers, agents, mortgages, regulations, inventory, technology, and the transaction."})
	end

	desc 'create beats'
	task :beats => :environment do
		Beat.create({"publication_id"=>"1", "name"=>"Real Estate Agents", "slug"=>"agents", "description"=>"Pertaining to the job of being a residential real estate agent."})
		Beat.create({"publication_id"=>"1", "name"=>"Real Estate Brokers", "slug"=>"brokers", "description"=>"Pertaining to the job of being a residential real estate broker."})
		Beat.create({"slug"=>"mortgages", "name"=>"Mortgages", "publication_id"=>"1", "description"=>"Pertaining to rates, lenders, underwriters, market trends, regulations, programs, innovation, and professional development in the residential real estate mortgage industry."})
		Beat.create({"slug"=>"technology", "name"=>"Real Estate Technology", "publication_id"=>"1", "description"=>"Pertaining to technological innovations affecting residential real estate."})
		Beat.create({"slug"=>"marketing", "name"=>"Real Estate Marketing", "publication_id"=>"1", "description"=>"Pertaining to marketing strategies for residential agents and brokers, including social media, referrals, advertising, portals, brands, data, and marketing technology."})
		Beat.create({"slug"=>"mls-and-associations", "name"=>"Real Estate MLS and Associations", "publication_id"=>"1", "description"=>"Pertaining to real estate multiple listing services or professional organizations in the residential real estate industry."})
		Beat.create({"slug"=>"market-conditions", "name"=>"Real Estate Market Conditions", "publication_id"=>"1", "description"=>"Pertaining to factors affecting the residential real estate market, including interest rates, inventory and demand, policy, and overall macroeconomic conditions."})
		Beat.create({"slug"=>"crime", "name"=>"Real Estate Crime", "publication_id"=>"1", "description"=>"Pertaining to criminal activity in the residential real estate industry."})
	end

	desc 'create sources'
	task :sources => :environment do
		Source.create({"name"=>"Inman", "publication_id"=>"1", "feed_url"=>"https://feeds.feedburner.com/inmannews", "home_url"=>"https://www.inman.com"})
		Source.create({"publication_id"=>"1", "feed_url"=>"https://www.thesisdriven.com/feed", "home_url"=>"https://www.thesisdriven.com", "name"=>"Thesis Driven"})
	end
end
