require 'gmail'

class MailSender
  include ConfigLoader

  def initialize
    config = load_config_file('email.config.yml')
    config.each {|k, v| instance_variable_set("@#{k}", v)}
    configure
  end

  def configure
    @gmail ||= Gmail.connect(instance_variable_get('@mail_user'), instance_variable_get('@mail_passwd'))
  end

  def logout!
    @gmail.logout
  end

  def alert!(instance, timestamp, send_mail)
    email = @gmail.compose {
      to instance_variable_get('@mail_to')
      subject instance_variable_get('@mail_subject') + instance['name']
      composed_message = instance_variable_get('@down_message').clone
      composed_message.gsub!('{instance_name}', instance['name']).gsub!('{target}', instance['endpoint']).gsub!('{timestamp}', timestamp.to_s)

      body composed_message
    }

    puts 'Alert Message: ' + email.to_s
    email.deliver! if send_mail
  end

  def message(subject, body)
    @gmail.compose {
      to instance_variable_get('@mail_to')
      subject subject
      body body
    }.deliver!
  end
end