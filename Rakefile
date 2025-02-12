require 'rake'
require 'dotenv/tasks'

Dir["./lib/tasks/**/*.rake"].each { |r| load r}

task :environment do
	load 'app.rb'
end
