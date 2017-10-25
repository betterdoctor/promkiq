require "prometheus/client"
require "prometheus/client/push"

module Promkiq
  class Middleware
    attr_reader :app, :env, :gateway, :client, :metrics

    def initialize(options={})
      raise ArgumentError, "missing :gateway option" unless options[:gateway]
      raise ArgumentError, "missing :app option" unless options[:app]
      raise ArgumentError, "missing :env option" unless options[:env]

      @gateway = options[:gateway]
      @app = options[:app]
      @env = options[:env]
      @metrics = {
        jobs_completed_count: Prometheus::Client::Counter.new(:sidekiq_jobs_completed_count, "Sidekiq jobs completed"),
        jobs_failed_count: Prometheus::Client::Counter.new(:sidekiq_jobs_failed_count, "Sidekiq jobs failed"),
        jobs_completed_ms: Prometheus::Client::Gauge.new(:sidekiq_jobs_completed_ms, "milliseconds Sidekiq jobs completed in"),
      }
    end

    def call(worker, msg, queue)
      start = Time.now
      begin
        yield
      rescue
        metrics[:jobs_failed_count].increment({app: app, env: env})
        raise
      end
      metrics[:jobs_completed_ms].set({app: app, env: env}, (Time.now - start) * 1000.0)
      metrics[:jobs_completed_count].increment({app: app, env: env})
      push_metrics(worker)
    end

    def client
      @client ||= begin
        client = Prometheus::Client.registry
        metrics.each do |_,metric|
          client.register(metric)
        end
        client
      end
    end

    private

    def push_metrics(worker)
      @push ||= Prometheus::Client::Push.new("sidekiq-#{app}-#{env}", worker.class.to_s, gateway)
      @push.add(client)
    end
  end
end
