# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require

# require_relative 'lib/initializers/rack-latency'
require_relative 'bin/app'

ENV['TZ'] = 'America/Sao_Paulo'

Rack::Handler.default.run(App, Port: 8089, Host: '0.0.0.0')