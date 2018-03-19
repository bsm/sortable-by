# Sortable By

[![Build Status](https://travis-ci.org/bsm/sortable-by.png?branch=master)](https://travis-ci.org/bsm/sortable-by)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

ActiveRecord plugin to parse the sort order from a query parameter, match against a white-list and generate a scope. Useful for [JSON-API][jsonapi] compatibility.

[jsonapi]: http://jsonapi.org/format/#fetching-sorting

## Installation

Add `gem 'sortable-by'` to your Gemfile.

## Usage

Simple use case:

```ruby
class Foo < ActiveRecord::Base
  sortable_by :title, :updated_at, default: { updated_at: :desc }
end

Foo.sorted_by "-updated_at,title" # => ORDER BY foos.updated_at DESC, foos.title ASC
Foo.sorted_by "bad,title"         # => ORDER BY foos.title ASC
Foo.sorted_by nil                 # => ORDER BY foos.updated_at DESC
```

Aliases and composition:

```ruby
class Foo < ActiveRecord::Base
  sortable_by semver: %i[major minor patch], default: { id: :asc }
end

Foo.sorted_by "semver"   # => ORDER BY foos.major ASC, foos.minor ASC, foos.patch ASC
Foo.sorted_by "-semver"  # => ORDER BY foos.major DESC, foos.minor DESC, foos.patch DESC
Foo.sorted_by nil        # => ORDER BY foos.id ASC
```

Custom functions:

```ruby
class Foo < ActiveRecord::Base
  sortable_by insensitive: Arel::Nodes::NamedFunction.new('LOWER', [arel_table[:title]]), default: { id: :asc }
end

Foo.sorted_by "insensitive"   # => ORDER BY LOWER(foos.title) ASC
Foo.sorted_by "-insensitive"  # => ORDER BY LOWER(foos.title) DESC
Foo.sorted_by nil             # => ORDER BY foos.id ASC
```
