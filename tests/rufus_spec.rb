require 'rufus-scheduler'

require 'rspec'

describe 'My behaviour' do

  it 'should do something' do

    scheduler = Rufus::Scheduler.singleton()

    job1 = scheduler.every '1s', job: true do
      puts 'Ping'
      # do something every 3 hours
      end

    job2 = scheduler.every '1s', job: true do
      puts 'Pong'
      # do something every 3 hours
    end
    sleep 30
    true.should == true
  end
end