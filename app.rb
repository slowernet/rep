# frozen-string-literal: true

require 'bundler'
Bundler.require

%w(config/initializers).each { |p| Dir["./#{p}/**/*.rb"].each  { |rb| require rb } }
%w(lib app/models app/routes app/helpers).each { |p| Dir["./#{p}/**/*.rb"].each  { |rb| require rb } }

class App < Roda
	plugin :render, views: 'app/views'
	plugin :public

	plugin :multi_run
	App.run "unlock", UnlockApp

	include Helpers

	route do |r|
		r.public

		r.multi_run

		r.root do
			view :index
		end
	end
end
