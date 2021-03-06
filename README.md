# Scarlett

Scarlett is a simple background system for Ruby.

## Features/Problems

  - Uses Rubinius Actors API (and a port for MRI) for jobs processing.
  - Uses RabbitMQ as backend for jobs queue.
  - Uses a reliable queue maintaining jobs saved in a backup queue when the workers crash.
  - Use a simple API for jobs, Jobs are Marshallable objects that respond to #run method

## Installation

Add this line to your application's Gemfile:

    gem 'scarlett'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scarlett

## Usage

### Queue

You must set a queue in your application to save jobs:

```ruby
JobQueue = Scarlett::Queue.new(:jobs)
```

### Jobs

The jobs should be Ruby objects that respond to `run` method (without
arguments, the arguments should be set in other method, ex. initialize), there is a simple example:

```ruby
class ComputationJob
  def initialize(seconds)
    @seconds = seconds
  end

  def run
    sleep @seconds
  end
end
```

Then you can insert jobs in the queue:

```ruby
job = ComputationJob.new(10)
JobQueue.push(job)
```

### Consumers
One or multiple workers should be started to consume jobs, this can be
done for example in a rake task:

```ruby
# jobs.rake
namespace :jobs do
  desc "Run worker for jobs"
  task :work => :environment do
    consumer = Scarlett::Consumer.new(:jobs)
    consumer.start
  end
end
```

## Acknowledges

This libraby is done thanks to the work of:

  - MenTaLguY and his awesome work in Rubinius Actors API
  - mperham and his posts about Rubinius Actors and his work in GirlFriday
  - All Rubinius team and contributors

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
