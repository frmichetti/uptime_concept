module Controllers
  # module BaseController
  module BaseController
    class << self
      def included(app)
        _current_dir = Dir.pwd

        app.get('/') do
          content_type :html
          file_path = File.join(settings.public_folder, 'index.html')
          if File.exist?(file_path) && File.readable?(file_path)
            send_file file_path
          else
            'File not Found!'
          end
        end

        app.get '/status' do
          content_type :json
          variables = app.instance_variables.select {|var| var.to_s.include?('ping')}
          endpoints = []
          variables.each {|v|
            var = app.instance_variable_get(v.to_s)
            endpoints << {"#{v.to_s.delete('@')}": {running: !var.paused?, repeat_every: var.original, previous_time: var.previous_time, next_time: var.next_time, paused_at: var.paused_at}}
          }

          [200, {endpoints: endpoints}.to_json]
        end

        app.post '/switch' do
          content_type :json

          endpoint = params['endpoint']

          begin
            raise ArgumentError.new('Invalid Payload') if endpoint.nil?

            scheduler = app.instance_variable_get("@#{endpoint}")
            raise ArgumentError.new('Invalid Endpoint') unless scheduler

            is_paused = scheduler.paused?

            if is_paused
              scheduler.resume
            else
              scheduler.pause
            end

            response = {"#{endpoint}": {paused: is_paused}}

            [200, response.to_json]
          rescue StandardError => e
            [400, {msg: e.message}.to_json]
          end
        end
      end
    end
  end
end
