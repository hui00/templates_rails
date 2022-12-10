gem_group :development, :test do
 gem "annotate"
 gem "solargraph"
 gem "solargraph-rails"
 gem "prettier"
 gem "rails_live_reload"
 gem "rubocop-rails", require: false
end
gem 'dotenv-rails'
gem 'devise'

file '.rubocop.yml', <<-CODE
 require: rubocop-rails
 inherit_from:
  - node_modules/@prettier/plugin-ruby/rubocop.yml
CODE

file '.solargraph.yml', <<-CODE
---
include:
  - "**/*.rb"
exclude:
  - spec/**/*
  - test/**/*
  - vendor/**/*
  - ".bundle/**/*"
require: []
domains: []
reporters:
  - rubocop
  - require_not_found
formatter:
  rubocop:
    cops: safe
    except: []
    only: []
    extra_args: []
require_paths: []
plugins:
  - solargraph-rails
max_files: 5000
CODE

file '.gitignore', <<-CODE
# Ignore bundler config.
/.bundle

# Ignore all logfiles and tempfiles.
/log/*
/tmp/*
!/log/.keep
!/tmp/.keep

# Ignore pidfiles, but keep the directory.
/tmp/pids/*
!/tmp/pids/
!/tmp/pids/.keep

# Ignore uploaded files in development.
/storage/*
!/storage/.keep
/tmp/storage/*
!/tmp/storage/
!/tmp/storage/.keep

/public/assets

# Ignore master key for decrypting credentials and more.
/config/master.key

.env
node_modules
CODE

file '.env', <<-CODE
POSTGRES_USER='new_user'
# If you declared a password when creating the database:
POSTGRES_PASSWORD='password'

POSTGRES_HOST='localhost'

POSTGRES_DB='your_database_name'

POSTGRES_TEST_DB='your_database_name_test'
CODE


after_bundle do
  run "rm config/database.yml"
  file 'config/database.yml', <<-CODE
  # PostgreSQL. Versions 9.3 and up are supported.
  #
  # Install the pg driver:
  #   gem install pg
  # On macOS with Homebrew:
  #   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
  # On macOS with MacPorts:
  #   gem install pg -- --with-pg-config=/opt/local/lib/postgresql84/bin/pg_config
  # On Windows:
  #   gem install pg
  #       Choose the win32 build.
  #       Install PostgreSQL and put its /bin directory on your path.
  #
  # Configure Using Gemfile
  # gem "pg"
  #
  default: &default
    adapter: postgresql
    encoding: unicode
    # For details on connection pooling, see Rails configuration guide
    # https://guides.rubyonrails.org/configuring.html#database-pooling
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    username: <%= ENV['POSTGRES_USERNAME'] %>
    password: <%= ENV['POSTGRES_PASSWORD'] %>
    pool: 5
    timeout: 5000
    host: <%= ENV['POSTGRES_HOST'] %>

  development:
    <<: *default
    database: <%= ENV['POSTGRES_DB'] %>

    # The specified database role being used to connect to postgres.
    # To create additional roles in postgres see `$ createuser --help`.
    # When left blank, postgres will use the default role. This is
    # the same name as the operating system user running Rails.
    #username: private_events

    # The password associated with the postgres role (username).
    #password:

    # Connect on a TCP socket. Omitted by default since the client uses a
    # domain socket that doesn't need configuration. Windows does not have
    # domain sockets, so uncomment these lines.
    #host: localhost

    # The TCP port the server listens on. Defaults to 5432.
    # If your server runs on a different port number, change accordingly.
    #port: 5432

    # Schema search path. The server defaults to $user,public
    #schema_search_path: myapp,sharedapp,public

    # Minimum log levels, in increasing order:
    #   debug5, debug4, debug3, debug2, debug1,
    #   log, notice, warning, error, fatal, and panic
    # Defaults to warning.
    #min_messages: notice

  # Warning: The database defined as "test" will be erased and
  # re-generated from your development database when you run "rake".
  # Do not set this db to the same as development or production.
  test:
    <<: *default
    database: <%= ENV['POSTGRES_TEST_DB'] %>

  # As with config/credentials.yml, you never want to store sensitive information,
  # like your database password, in your source code. If your source code is
  # ever seen by anyone, they now have access to your database.
  #
  # Instead, provide the password or a full connection URL as an environment
  # variable when you boot the app. For example:
  #
  #   DATABASE_URL="postgres://myuser:mypass@localhost/somedatabase"
  #
  # If the connection URL is provided in the special DATABASE_URL environment
  # variable, Rails will automatically merge its configuration values on top of
  # the values provided in this file. Alternatively, you can specify a connection
  # URL environment variable explicitly:
  #
  #   production:
  #     url: <%= ENV["MY_APP_DATABASE_URL"] %>
  #
  # Read https://guides.rubyonrails.org/configuring.html#configuring-a-database
  # for a full overview on how database connection configuration can be specified.
  #
  production:
    <<: *default
    database: <%= ENV['POSTGRES_DB'] %>
    username: <%= ENV['POSTGRES_USER'] %>
    password: <%= ENV["PRIVATE_EVENTS_DATABASE_PASSWORD"] %>
  CODE
  run "rails g annotate:install"
  run "bundle exec annotate "
  run "solargraph bundle"
  run "yard gems", sudo: true
  run "yard docs"
  run "npm install --save-dev prettier @prettier/plugin-ruby"
  run "bundle install"


  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
