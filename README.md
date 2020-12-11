# Ruby Local Cache

Simple cache for Ruby services.

This is not a gem, but only one file that you can copy and use in your own project. This cache is not thread safe and is intended only for serving as a temporary memory cache for a single thread.
No database or storage service is required. In-memory, no dependency, just one file of Ruby Class.

1. Initialize the cache as global: `Cache = LocalCache.new`

That's it! Next, you can cache result of block execution:

```ruby
CACHE_KEY = 'Module::Class.calculation_result'
Cache.fetch(CACHE_KEY) do
  2 + 2
end
# => 4
```

or write/read on your own:

```ruby
CACHE_KEY = 'Module::Class.calculation_result'
if Cache.valid?(CACHE_KEY)
  Cache.read(CACHE_KEY)
else
  Cache.write(CACHE_KEY, 5)
end
# => 5
```

## Contributing

[Bug reports](/rspec-watcher/issues) and [pull requests](/rspec-watcher/pulls) are welcome. This project is intended to be a safe, welcoming space for collaboration. Everyone interacting in the project codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://www.contributor-covenant.org/version/2/0/code_of_conduct/).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
