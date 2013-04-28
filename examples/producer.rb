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

queue = Scarlett::Queue.new("jobs_queue")
(1..10).each do |name|
  job = Job.new(name)
  queue.push(job)
end
