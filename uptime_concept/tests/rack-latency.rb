require 'sinatra'
require 'rack-latency'


# config/initializers/rack-latency.rb
Rack::Latency.configure do |measure|
  # time a HEAD request for google.com.
  measure.head "http://www.google.com/"

  # time a GET request to a Yahoo IP, and rename the measurement to "yahoo".
  measure.get "http://98.138.253.109/", name: "yahoo"

  # set the delay time between measurement loops.
  measure.wait ENV["RACK-LATENCY-WAIT"] || 4

  # set the environment(s) in which to run, as defined by Rails.env or RACK_ENV.
  # By default, it will only run in production.
  measure.environment :production
  # or
  measure.environments :production, :staging
end