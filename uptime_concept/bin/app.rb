# frozen_string_literal: true

require_relative '../lib/loadpath'
require 'models/base'

class App < Sinatra::Application
  register Sinatra::SequelExtension, Sinatra::ConfigFile
  config_file File.join("#{Dir.pwd}/lib/config/rack.conf.yml")
  use Rack::PostBodyContentTypeParser

  use Rack::Auth::Basic, 'Protected Area' do |username, password|
    username == 'kuadro' && password == 'kuadrodevops'
  end

  extend DBConnection

  ###############
  # Data Source #
  ###############

  DATASOURCE = load_db

  ################
  # Controller's #
  ################

  require 'requires'
  require 'aliases'

  %w[controllers].each { |folder| Dir["#{Dir.pwd}/lib/#{folder}/*.rb"].each { |file| require file } }

  Controllers.constants.each do |ctrl_sym|
    module_name = Kernel.const_get('Controllers::?'.gsub('?', ctrl_sym.to_s))
    include module_name
  end

  extend Inflector
  extend ConfigLoader

  #############
  # Endpoints #
  #############

  ENDPOINTS = load_config_file('instances.yml').freeze

  configure do
    set server: 'webrick'
    set :raise_errors, settings.raise_errors
    set :show_exceptions, settings.show_exceptions
    set :root, File.dirname(__FILE__)
    set :public_folder, File.join(root, '../', 'public')
  end

  before do
    content_type :html, 'charset' => 'utf-8'
    content_type :json, 'charset' => 'utf-8'
  end

  #############
  # Scheduler #
  #############

  @scheduler = Rufus::Scheduler.singleton

  ############
  # Notifier #
  ############

  @mail_sender = MailSender.new

  #############
  # ReactiveX #
  #############
  @downtime_queue = []
  @deliver_queue = []
  @alert_devs_observer = Rx::Observable.just(@deliver_queue)

  #####################
  # Common Block call #
  #####################

  ping_block = lambda do |instance|
    ping = Net::Ping::HTTP.new(instance['endpoint'], 80, 6)
    ping.get_request = true
    ping.ping?

    response = {
      endpoint: instance['endpoint'],
      code: ping.code,
      duration: ping.duration,
      port: ping.port,
      time_out: ping.timeout,
      warning: ping.warning
    }

    statistic = Statistic.find_or_create(server_name: instance['endpoint'])

    ##############
    # Observer's #
    ##############

    source = Rx::Observable.just(ping)
    source.subscribe(
      lambda { |x|
        puts 'On Next: ' + x.to_s
        puts response.to_json
        @downtime_queue << { instance: instance, instant: Time.new, exception: x.exception } if x.exception
        if (200..302).cover?(x&.code.to_i)
          statistic.update(uptime_count: statistic.uptime_count + 1)
        else
          statistic.update(downtime_count: statistic.downtime_count + 1)
        end
      },
      lambda { |err|
        puts 'On Error: ' + err.to_s
        @downtime_queue << { instance: instance, instant: Time.new, error: err }
      },
      -> { puts 'On Completed' }
    )
  end

  ########
  # Jobs #
  ########

  #####################
  # Common Block call #
  #####################

  job_factory = lambda do |endpoint_key|
    @scheduler.every '1s', job: true do
      ping_block.call(ENDPOINTS[endpoint_key])
    end
  end

  ENDPOINTS.each do |hash|
    original_name = hash.last['name']
    original_name.delete!(' ')
    var_name = "@#{underscore(original_name)}"
    instance_variable_set(var_name, job_factory.call(hash.first))
    attr_reader var_name.delete('@').to_sym
  end

  @alert_devs = @scheduler.every '1m', job: true do
    @deliver_queue = @deliver_queue.concat(@downtime_queue).uniq
    @downtime_queue = []

    begin
      @deliver_queue.each { |downtime| @mail_sender.alert!(downtime[:instance], downtime[:instant], production?) }
    rescue StandardError => e
      puts 'Unexpected Error on Send Mails'
      puts e.to_s
    ensure
      @deliver_queue = []
    end
  end

  ##############
  # Exit Block #
  ##############

  at_exit do
    puts 'Killing Rufus!'
    @mail_sender.message('Killing Kuadro Ping', 'Kuadro ping is Dead') if production?

    # let's unschedule all the at jobs

    @scheduler.at_jobs.each(&:unschedule)
    @scheduler.shutdown(:kill)

    exit true
  end
end
