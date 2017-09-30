# Sinatra REST API [![Gem Version](https://badge.fury.io/rb/sinatra-rest-api.svg)](https://badge.fury.io/rb/sinatra-rest-api)

A Sinatra component that generates CRUD routes for database ORM models.

Features:
- supports Active Record, Mongoid and Sequel ORMs
- default actions already setup
- nested resources available

Install: `gem install sinatra-rest-api` (or in Gemfile)

### Example

```rb
class Book < ActiveRecord::Base
end

class App < Sinatra::Application
  register Sinatra::RestApi

  resource Book
  resource Category do
    actions [ :list, :read ]
  end
end
```

Generates:
```
GET: /books/:id.?:format?
PUT: /books/:id.?:format?
DELETE: /books/:id.?:format?
PUT: /books/?.?:format?
POST: /books/?.?:format?
DELETE: /books/?.?:format?
GET: /books/?.?:format?
GET: /categories/:id.?:format?
GET: /categories/?.?:format?
```

## More examples

See [examples](examples/). Execute: `thin start` in the folder of an example.

### Tests

Run individual example apps tests:
- `rspec spec/app_active_record_spec.rb`
- `rspec spec/app_mongoid_spec.rb`
- `rspec spec/app_sequel_spec.rb`

## Do you like it? Star it!

If you use this component just star it. A developer is more motivated to improve a project when there is some interest.

## Contributors

- [Mattia Roccoberton](http://blocknot.es) - creator, maintainer

## License

[ISC](LICENSE)
