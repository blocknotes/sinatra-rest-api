# Sinatra REST API

A Sinatra component that generates CRUD routes for database ORM models.
This is an *alpha* version, structure could change in future release.

Features:
- small and compact
- supports Active Record, Mongoid and Sequel ORMs
- default actions already setup
- nested resources

Example:
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

### More examples

See [examples](examples/). Execute: `thin start` in one of the examples dir.

### Tests

Run individual example apps tests:
- `rspec spec/app_active_record_spec.rb`
- `rspec spec/app_mongoid_spec.rb`
- `rspec spec/app_sequel_spec.rb`

### To Do

- Improve documentation
- Sequel: improve nested attributes assignment (model_ids parameter)
- Add fields to models (singular name OK, plural name OK, enabled actions, etc.)
- Add more relations like (second_category on books)
- Add model like CoverImage
- Improve tests (more examples, check relations, check every option, etc.)
- ng-admin example: manage one_to_many and many_to_many relations
- Improve security
- Support nested resources? (ex. /books/1/authors)

### ISC License

Copyright (c) 2016, [Mattia Roccoberton](http://blocknot.es)

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
