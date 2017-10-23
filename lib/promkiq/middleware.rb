require "prometheus/client"
require "prometheus/client/push"

module Promkiq
  class Middleware
    attr_reader :prometheus, :jobs_completed_count, :jobs_failed_count, :jobs_completed_ms

    def initialize(options={})
      raise ArgumentError, "missing :gateway option" unless options[:gateway]
      raise ArgumentError, "missing :app option" unless options[:app]

      @gateway = options[:gateway]
      @app = options[:app]
      @prometheus = Prometheus::Client.registry
      @jobs_completed_count = Prometheus::Client::Counter.new(:sidekiq_jobs_completed_count,
                                                             "Sidekiq jobs completed")
      @jobs_failed_count = Prometheus::Client::Counter.new(:sidekiq_jobs_failed_count,
                                                          "Sidekiq jobs failed")
      @jobs_completed_ms = Prometheus::Client::Gauge.new(:sidekiq_jobs_completed_ms,
                                                        "milliseconds Sidekiq jobs completed in")
      @prometheus.register(@jobs_completed_count)
      @prometheus.register(@jobs_failed_count)
      @prometheus.register(@jobs_completed_ms)
    end

    def call(worker, msg, queue)
      start = Time.now
      begin
        yield
      rescue
        jobs_failed_count.increment({app: app, worker: worker})
        raise
      end
      jobs_completed_ms.set({app: app, worker: worker}, (Time.now - start) * 1000.0)
      jobs_completed_count.increment({app: app, worker: worker})
      Prometheus::Client::Push.new("promkiq-#{app}-#{env}", worker, gateway)
    end
  end
end
