require 'rspec'
require 'rufus-scheduler'

describe 'My behaviour' do

  @scheduler = nil

  before do
    @scheduler ||= Rufus::Scheduler.new(frequency: 0)
  end

  it 'should do something' do
    expect(@scheduler).not_to be_nil


    job_one = @scheduler.every '1s' do
      puts 'Ping One'
    end

    job_two = @scheduler.every '1s' do
      puts 'Ping Two'
    end

    job_three = @scheduler.every '1s' do
      puts 'Ping Three'
    end
    
    expect(job_one).not_to be_nil
    expect(job_two).not_to be_nil
    expect(job_three).not_to be_nil

  end
end