# Sinatra REST API [![Gem Version](https://badge.fury.io/rb/sinatra-rest-api.svg)](https://badge.fury.io/rb/sinatra-rest-api)

A Sinatra component that generates CRUD routes for database ORM models.

Features:
- supports Active Record, Mongoid and Sequel ORMs
- default actions already setup
- nested resources available

Install: `gem install sinatra-rest-api` (or in Gemfile)

## Options

For *resource* DSL keyword:
- **actions**: list of actions to enable (array of symbols)
- **include**: list of associations to expose in list/read actions (array of symbols) or false to skip every association
- **plural**: plural model name used for routes (string)
- **singular**: singular model name for resource key (string)

## Examples

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
GET:    /books/:id.?:format?
PUT:    /books/:id.?:format?
DELETE: /books/:id.?:format?
PUT:    /books/?.?:format?
POST:   /books/?.?:format?
DELETE: /books/?.?:format?
GET:    /books/?.?:format?
GET:    /categories/:id.?:format?
GET:    /categories/?.?:format?
```

#### More examples

See [examples](examples/). Execute: `thin start` in the folder of an example.

#### Using inside a Rails app

Let's create an Importer class to import data between 2 Rails app.

A simple way to add an API for every model on the source app:

- create a sinatra app in: `lib/sinatra_app/app.rb`:

```rb
Rails.application.eager_load!  # if cache_classes is off

class MySinatraApp < Sinatra::Base
  register Sinatra::RestApi

  ActiveRecord::Base.descendants.each do |model|  # Iterate all models
    next if model.abstract_class
    resource model, actions: [ :list, :read ], include: false
  end
end
```

- load the sinatra app editing `config/application.rb`:

```rb
module RailsSinatra
  class Application < Rails::Application
    config.after_initialize do
      require_relative '../lib/sinatra_app/app'
    end
  end
end
```

- setup the routes editing `config/routes.rb`:

```rb
Rails.application.routes.draw do
  mount MySinatraApp.new => '/sinatra'
end
```

- now you can access to every model under 'sinatra' path, example: '/sinatra/posts.json'

- on the destination app you can access these models using *ActiveResource* gem:

```rb
class Importer < ActiveResource::Base
  self.site = 'http://127.0.0.1:3000/sinatra'  # first app path

  def self.init( collection_name )
    set_collection_name collection_name
    self
  end
end

# List of tags names:
Importer.init( 'tags' ).all.map( &:name )
```

## Tests

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
