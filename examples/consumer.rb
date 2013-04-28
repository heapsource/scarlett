$:.unshift(File.expand_path("../../lib", __FILE__))
require "scarlett"

class Job
  def initialize(name)
    @name = name
  end

  def run
    sleep 2
    puts @name
  end
end

n = 2
consumer = Scarlett::Consumer.new("jobs_queue", n)
puts "Starting consumer with queue 'jobs_queue' and #{n} workers"

consumer.start
