# Redis::Replicator

Ruby wrapper that acts as a Redis client but instead writes to several Redis
instances.

Originally built to handle switching Redis instances for a Ruby on Rails app
with user sessions in Redis and not disconnecting anyone.

## Installation

Add to your Gemfile:

```rb
# Ruby wrapper that acts as a Redis client but instead writes to several Redis
# instances.
gem "redis-replicator", github: "cults/redis-replicator"
```

## Usage

Initialize it with an array of Redis instance URLs:

```rb
redis = Redis::Replicator.new(
  urls: [
    "redis://localhost:7777/0",
    "redis://localhost:8888/0",
  ],
)
```

Use it where Redis instances are expected.

E.g. for Rails sessions:

```rb
Rails.application.config.session_store :redis_session_store,
                                       serializer: :json,
                                       redis: {client: redis}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cults/redis-replicator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/cults/redis-replicator/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Redis::Replicator project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cults/redis-replicator/blob/main/CODE_OF_CONDUCT.md).
