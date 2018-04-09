require "prometheus/client"
require "prometheus/client/push"

module Promkiq
  class Middleware
    attr_reader :app, :env, :gateway, :client, :metrics

    def initialize(options={})
      raise ArgumentError, "missing :gateway option" unless options[:gateway]
      raise ArgumentError, "missing :app option" unless options[:app]
      raise ArgumentError, "missing :env option" unless options[:env]

      @gateway, @app, @env = options[:gateway], options[:app], options[:env]

      @jobs_completed_ms = Prometheus::Client::Gauge.new(
        :sidekiq_jobs_completed_ms,
        "milliseconds Sidekiq jobs completed in"
      )
      @client = Prometheus::Client.registry
      begin
        @client.register(@jobs_completed_ms)
      rescue Prometheus::Client::Registry::AlreadyRegisteredError
      end
    end

    def call(worker, msg, queue)
      start = Time.now
      yield
      @jobs_completed_ms.set({app: app, env: env}, (Time.now - start) * 1000.0)
      push_metrics(worker)
    end

    private

    def push_metrics(worker)
      @push = Prometheus::Client::Push.new("sidekiq-#{app}-#{env}", worker.class.to_s, gateway)
      @push.replace(client)
    end
  end
end
