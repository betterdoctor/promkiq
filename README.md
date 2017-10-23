promkiq
=======

Sidekiq middleware for collecting metrics in Prometheus

This middleware will track the following metrics:

```
# (gauge) milliseconds job took to complete
sidekiq_jobs_completed_ms

# (counter) count of completed jobs
sidekiq_jobs_completed_count

# (counter) count of failed jobs
sidekiq_jobs_failed_count
```

### Installation

In Gemfile add the following

```ruby
gem "promkiq"
```

### Configuration

In your `config/initializers/sidekiq.rb` add the following

```ruby
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Promkiq::Middleware, app: "myapp",
      env: ENV["RAILS_ENV"], gateway: ENV["PROMETHEUS_PUSHGATEWAY"]
  end
end
```
