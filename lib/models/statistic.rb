require 'sequel'

class Statistic < Sequel::Model

  def validate
    super
    errors.add(:server_name, 'cannot be empty') if !server_name || server_name.empty?
    errors.add(:invalid_uptime, 'invalid uptime') if up && !duration
    errors.add(:invalid_downtime, 'invalid downtime') if !up && !duration && !warning
  end
end