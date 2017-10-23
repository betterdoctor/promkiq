promkiq
=======

Sidekiq middleware for collecting metrics in Prometheus

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
