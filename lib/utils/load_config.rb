module ConfigLoader
  def load_config_file(file_name)
    file = file_name
    file_path = Dir.pwd + "/lib/config/#{file}"
    begin
      YAML.safe_load(File.open(file_path))
    rescue Psych::SyntaxError => e
      puts "[Startup Info] - Config file #{e.message}"
    rescue StandardError
      raise "[Startup Info] - Config file [#{file}] not found in this directory [#{file_path}]"
    end
  end
end