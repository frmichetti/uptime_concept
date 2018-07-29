require 'rx'

context = { value: 42 }

source = Rx::Observable.start(
    lambda {
        return self[:value]
    },
    context,
    Rx::DefaultScheduler.instance
)

subscription = source.subscribe(
    lambda {|x|
        puts 'Next: ' + x.to_s
    },
    lambda {|err|
        puts 'Error: ' + err.to_s
    },
    lambda {
        puts 'Completed'
    })

# => Next: 42
# => Completed

while Thread.list.size > 1
  (Thread.list - [Thread.current]).each &:join
end
