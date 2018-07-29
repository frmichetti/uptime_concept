# frozen_string_literal: true
require 'yaml'
require 'sequel'
require 'sequel/adapters/postgresql'

module DBConnection
  # Database constants belong to this module namespace:

  def load_db
    yaml = load_config_file
    connection = Sequel.postgres(yaml)
    if Sequel::Postgres.supports_streaming?
      # If streaming is supported, you can load the streaming support into the database:
      connection.extension(:pg_streaming)
      # If you want to enable streaming for all of a database's datasets, you can do the following:
      connection.stream_all_queries = true
      puts '[Startup Info] - Postgresql streaming was activated.'
    end
    connection
  end

  private

  def load_config_file
    file = 'database.conf.yml'
    file_path = File.dirname(__FILE__) + "/../config/#{file}"
    begin
      YAML.safe_load(File.open(file_path))
    rescue StandardError
      raise "[Startup Info] - Config file [#{file}] not found in this directory [#{file_path}]"
    end
  end
end
