require 'rx'

subject = Rx::Subject.new
source = Rx::Observable.range(0, 3)
    .multicast(subject)

observer = Rx::Observer.create(
    lambda {|x|
        puts 'Next: ' + x.to_s
    },
    lambda {|err|
        puts 'Error: ' + err.to_s
    },
    lambda {
        puts 'Completed'
    }
)

subscription = source.subscribe(observer)
subject.subscribe(observer)

connected = source.connect

subscription.dispose

# => Next: 0
# => Next: 0
# => Next: 1
# => Next: 1
# => Next: 2
# => Next: 2
# => Completed
