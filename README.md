# Sortable By

ActiveRecord plugin to parse the sort order from a query parameter and generate a scope.
Useful for [JSON-API][jsonapi] compatibility.

[jsonapi]: http://jsonapi.org/format/#fetching-sorting

## Installation

Add `gem 'sortable'` to your Gemfile.

## Usage

Simple use cases:

```ruby
class Foo < ActiveRecord::Base
  sortable_by :title, :updated_at
end

Foo.sort_by "-updated_at,title" # => ORDER BY updated_at DESC, title ASC
Foo.sort_by "bad,title" # => ORDER BY title ASC
```

## LICENSE

```
Copyright (c) 2015 Black Square Media

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
