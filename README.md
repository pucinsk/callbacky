# Callbacky

**Callbacky** is a lightweight Ruby gem that allows you to define and run custom lifecycle callbacks like `before` and `after` in a clean, expressive way.

## ✨ Features

- Define custom `before_*` and `after_*` hooks
- Supports callbacks as method names, lambdas, or blocks
- Declarative syntax inspired by Rails
- Easily extensible for any lifecycle events in your application

## Installation

Add this line to your Gemfile:

```ruby
gem "callbacky"
```

Or install manually:

```sh
gem install callbacky
```

## Usage

### 1. Extend `Callbacky` in your class
```ruby
class MyService
  class << self
    extend Callbacky

    callbacky_after :init
  end
end
```
### 2. Define a callback

***Using method name:***
```ruby
class MyService
  callbacky_after_init :handle_after_init

  def handle_after_init
    puts "After init"
  end
end
```

***Using a lambda or proc:***
```ruby
class MyService
  callbacky_after_init ->(obj) { obj.log_event }
end
```

***Using a block:***
```ruby
class MyService
  callbacky_after_init do |instance|
    instance.send_metrics
  end
end
```

### 3. Trigger the callback

```ruby
class MyService
  def initializer
    ### callbacky_init will run before and after hooks
    callbacky_init do |instance|
      instance.do_some_other_things_inside
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pucinsk/callbacky. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/pucinsk/callbacky/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Callbacky project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/callbacky/blob/main/CODE_OF_CONDUCT.md).
