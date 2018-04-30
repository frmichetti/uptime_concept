########################################################################
# example_pingtcp.rb
#
# A short sample program demonstrating a tcp ping. You can run
# this program via the example:tcp task. Modify as you see fit.
########################################################################
require 'net/ping'
require 'json'

good = 'www.kuadro.com.br'
_bad = 'foo.bar.baz'

loop do
  p1 = Net::Ping::TCP.new(good, 'http', 3)
  sleep(1)
  p p1.ping?
  p ({duration: p1.duration, port: p1.port, time_out: p1.timeout, warning: p1.warning}.to_json)

  # p2 = Net::Ping::TCP.new(_bad)
  # p p2.ping?

end

