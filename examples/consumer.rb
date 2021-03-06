$:.unshift(File.expand_path("../../lib", __FILE__))
require "scarlett"

class Job
  def initialize(name)
    @name = name
  end

  def run
    sleep 5
    puts @name
  end
end

n = 20
consumer = Scarlett::Consumer.new("jobs_queue", n)
puts "Starting consumer with queue 'jobs_queue' and #{n} workers"

consumer.start
