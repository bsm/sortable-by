ENV['RACK_ENV'] ||= "test"
require 'sortable-by'
require 'rspec'

ActiveRecord::Base.configurations["test"] = { 'adapter' => 'sqlite3', 'database' => ":memory:" }
ActiveRecord::Base.establish_connection :test
ActiveRecord::Base.connection.create_table :foos do |t|
  t.string :title
  t.integer :age
end

ActiveRecord::Base.connection.create_table :bars do |t|
  t.string :title
end

class Foo < ActiveRecord::Base
  sortable_by :title, :age, default: {title: :asc}
end

class Bar < ActiveRecord::Base
end

Foo.create! title: 'A', age: 25
Foo.create! title: 'B', age: 24
Foo.create! title: 'B', age: 26
Foo.create! title: 'C', age: 27

Bar.create! title: 'Y'
Bar.create! title: 'X'
