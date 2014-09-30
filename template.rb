gem 'ember-rails'
gem 'ember-source'
gem 'emblem-rails'
gem_group :development, :test do
  gem "rspec-rails"
end

gsub_file "Gemfile", /^.*Turbolinks makes following links.*$/,''
gsub_file "Gemfile", /^gem\s+["']turbolinks["'].*$/,''
gsub_file "Gemfile", /^.*CoffeeScript for \.js\.coffee.*$/,''
gsub_file "Gemfile", /^gem\s+["']coffee-rails["'].*$/,''

run "bundle install"

rake "db:create"
rake "db:migrate"

run "rails g ember:bootstrap -n App --javascript-engine js"
run "rails g ember:install --tag=v1.7.0 --ember"

gsub_file "app/assets/javascripts/application.js", /\/\/\= require turbolinks\s+/,''
gsub_file "app/views/layouts/application.html.erb", /,\s*'data-turbolinks-track' => true/,''


insert_into_file 'config/environments/test.rb',
  "\n  config.ember.variant = :development\n",
  after: "# Settings specified here will take precedence over those in config/application.rb.\n"

insert_into_file 'config/environments/development.rb',
  "\n  config.ember.variant = :development\n",
  after: "# Settings specified here will take precedence over those in config/application.rb.\n"

insert_into_file 'config/environments/production.rb',
  "\n  config.ember.variant = :production\n",
  after: "# Settings specified here will take precedence over those in config/application.rb.\n"

insert_into_file 'config/routes.rb',
  "\n  root to: 'home#index'",
  after: "# The priority is based upon order of creation: first created -> highest priority.\n"

run "rails g controller home index  --no-template-engine --no-helper --no-assets --no-controller-specs --no-view-specs"
run "mkdir -p app/views/home"
run "touch app/views/home/index.html.erb"
def source_paths
  Array(super) +
    [File.join(File.expand_path(File.dirname(__FILE__)),'rails_root')]
end

inside 'app/assets/javascripts/templates' do
  copy_file "application.js.emblem"
end

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
