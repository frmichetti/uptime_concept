require 'rspec'

describe 'My behaviour' do

  before{
    # config.expect_with(:rspec) { |c| c.syntax = :should }
    # config.raise_errors_for_deprecations!
  }

  it('should do something') {

    require 'rubygems'
    require 'net/ping'

    loop do
      break if system('ping www.kuadro.com.br -c 1')
      sleep 1
      puts 'Internet working!'
    end


    # if Net::Ping.new('http://www.google.com/').ping
    #   puts "Pong!"
    # else
    #   puts "No response"
    # end

    # true.should == false
  }
end