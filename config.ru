require './app'
run App.freeze.app

use Rack::Cors do
	allow do
		origins '*'
		resource '*', :headers => :any, :methods => [:get, :post, :options]
	end
end
