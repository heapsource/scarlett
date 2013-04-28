begin
  require "rubinius/actor"
rescue RuntimeError
  require "scarlett/actor"
end
require "case"
require "bunny"
require "json"

class Scarlett
  FinishedWork = Case::Struct.new(:worker, :job)
  Work = Case::Struct.new(:job, :tag)
  @@buny_started = false

  def self.bunny
    @@bunny ||= Bunny.new
  end

  def self.start_bunny
    self.bunny.start unless @@buny_started
    @@buny_started = true
    self.bunny
  end

  class Consumer
    attr_accessor :active_workers, :inactive_workers, :workers, :queue

    def initialize(queue, workers = 20)
      @queue = Queue.new(queue)
      @inactive_workers = nil
      @active_workers = []
      @workers = workers
    end

    def start
      trap("INT") { stop }

      @supervisor = Rubinius::Actor.spawn do
        Rubinius::Actor.trap_exit = true
        begin
          supervisor_loop
        rescue Exception => error
          $stderr.puts "Error in supervisor loop"
          $stderr.puts "Exception: #{error}: \n#{error.backtrace.join("\n")}"
        end
      end

      puts "Starting to consume jobs in '#{@queue.name}' queue..."
      wait_queue_loop
    end

    def stop
      puts "Stopping consuming jobs in '#{@queue.name}' queue"
      @stopping = true
      Scarlett.bunny.stop
    end

    def inactive_workers
      @inactive_workers ||= Array.new(@workers) { Rubinius::Actor.spawn_link(&method(:work_loop)) }
    end

    private

    def supervisor_loop
      loop do
        case message = Rubinius::Actor.receive
        when Work
          worker = inactive_workers.pop
          puts "Work received, sending work to Worker (#{worker.object_id})"
          active_workers << worker
          worker << message
        when FinishedWork
          worker = message.worker
          @queue.ack(message[:tag])
          puts "Finished Work received, sending to Worker (#{worker.object_id}) to inactive workers"
          inactive_workers << worker
          active_workers.delete(worker)
        when Rubinius::Actor::DeadActorError
          $stderr.puts "Actor exited with message: #{message.reason}"
          inactive_workers << Rubinius::Actor.spawn_link(&method(:work_loop))
        end
      end
    end

    def work_loop
      loop do
        case message = Rubinius::Actor.receive
        when Work
          job = Marshal.load(message.job)
          job.run
          @supervisor << FinishedWork[Rubinius::Actor.current, message.job]
        end
      end
    end

    def wait_queue_loop
      loop do
        break if @stopping
        job = @queue.pop
        next unless job
        puts "New job received, sending work to Supervisor (#{@supervisor.object_id})"
        @supervisor << Work.new(job)
      end
    end
  end

  class Queue
    attr_reader :name

    def initialize(name, options = {})
      @name = name
      @connection = Scarlett.start_bunny
      @channel = @connection.create_channel
      @channel.prefetch(1)
      @queue = @channel.queue(@name)
    end

    def push(job, opts = {})
      @queue.publish({'job' => Marshal.dump(job)}.to_json, opts.merge({ content_type: "application/json" }))
    end

    def pop
      info, _, payload = @queue.pop
      return unless payload
      puts "This is the message: " + payload + "\n\n"
      { job: JSON.parse(payload)['job'], tag: info.delivery_tag}
    end

    def ack(tag)
      @channel.ack(tag, false)
    end
  end
end
