ENV['RACK_ENV'] ||= 'test'
require 'sortable-by'
require 'rspec'

ActiveRecord::Base.configurations['test'] = {
  'adapter' => 'sqlite3',
  'database' => ':memory:',
}
ActiveRecord::Base.establish_connection :test
ActiveRecord::Base.connection.create_table :foos do |t|
  t.string :title
  t.integer :age

  t.integer :major
  t.integer :minor
end

ActiveRecord::Base.connection.create_table :bars do |t|
  t.string :title
end

ActiveRecord::Base.connection.create_table :boos do |t|
  t.string :title
end

class Foo < ActiveRecord::Base
  sortable_by :title, :age,
              insensitive: Arel::Nodes::NamedFunction.new('LOWER', [arel_table[:title]]),
              semver: %i[major minor],
              default: { title: :asc }
end

class Bar < ActiveRecord::Base
end

Foo.create! title: 'A', age: 25, major: 10, minor: 1
Foo.create! title: 'B', age: 24, major: 8, minor: 3
Foo.create! title: 'b', age: 26, major: 0, minor: 2
Foo.create! title: 'C', age: 27, major: 8, minor: 6

Bar.create! title: 'Y'
Bar.create! title: 'X'
