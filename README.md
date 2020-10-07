# Sortable By

[![Build Status](https://travis-ci.org/bsm/sortable-by.png?branch=master)](https://travis-ci.org/bsm/sortable-by)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

ActiveRecord plugin to parse the sort order from a query parameter, match against a white-list and generate a scope. Useful for [JSON-API][jsonapi] compatibility.

[jsonapi]: http://jsonapi.org/format/#fetching-sorting

## Installation

Add `gem 'sortable-by'` to your Gemfile.

## Usage

Simple:

```ruby
class Post < ActiveRecord::Base
  sortable_by :title, :id
end

Post.sorted_by('title')     # => ORDER BY LOWER(posts.title) ASC
Post.sorted_by('-title')    # => ORDER BY LOWER(posts.title) DESC
Post.sorted_by('bad,title') # => ORDER BY LOWER(posts.title) ASC
Post.sorted_by(nil)         # => ORDER BY LOWER(posts.title) ASC
```

Case-sensitive:

```ruby
class Post < ActiveRecord::Base
  sortable_by do |x|
    x.field :title, case_sensitive: true
    x.field :id
  end
end

Post.sorted_by('title') # => ORDER BY posts.title ASC
```

With custom default:

```ruby
class Post < ActiveRecord::Base
  sortable_by :id, :topic, :created_at, default: 'topic,-created_at'
end

Post.sorted_by(nil) # => ORDER BY LOWER(posts.topic) ASC, posts.created_at DESC
```

Composition:

```ruby
class App < ActiveRecord::Base
  sortable_by :name, default: '-version' do |x|
    x.field :version, as: %i[major minor patch]]
  end
end

App.sorted_by('version') # => ORDER BY apps.major ASC, apps.minor ASC, apps.patch ASC
App.sorted_by(nil)       # => ORDER BY apps.major DESC, apps.minor DESC, apps.patch DESC
```

Associations (eager load):

```ruby
class Product < ActiveRecord::Base
  belongs_to :shop
  sortable_by do |x|
    x.field :name
    x.field :shop, as: Shop.arel_table[:name], eager_load: :shop
    x.default 'shop,name'
  end
end
```

Associations (custom scope):

```ruby
class Product < ActiveRecord::Base
  belongs_to :shop
  sortable_by do |x|
    x.field :shop, as: Shop.arel_table[:name], scope: -> { joins(:shop) }
  end
end
```
