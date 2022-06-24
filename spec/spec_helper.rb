ENV['RACK_ENV'] ||= 'test'
require 'sortable-by'
require 'rspec'

ActiveRecord::Base.configurations = {
  'test' => {
    'adapter'  => 'sqlite3',
    'database' => ':memory:',
  },
}
ActiveRecord::Base.establish_connection :test

ActiveRecord::Base.connection.instance_eval do
  create_table :posts do |t|
    t.string :type
    t.string :title, null: false
    t.timestamp :created_at, null: false
  end

  create_table :apps do |t|
    t.string :name, null: false
    t.integer :major, null: false
    t.integer :minor, null: false
    t.integer :patch, null: false
  end

  create_table :shops do |t|
    t.string :name, null: false
  end

  create_table :products do |t|
    t.string :name, null: false
    t.integer :shop_id, null: false
    t.boolean :active, null: false, default: true
    t.foreign_key :shops
  end
end

class App < ActiveRecord::Base
  sortable_by :name do |s|
    s.field :version, as: %i[major minor patch]
  end
end

class Post < ActiveRecord::Base
  sortable_by :title, default: '-created', case_sensitive: true do |s|
    s.field :created, as: arel_table[:created_at]
  end
end

class SubPost < Post
  sortable_by do |s|
    s.field :title
  end
end

class Shop < ActiveRecord::Base
end

class Product < ActiveRecord::Base
  belongs_to :shop

  sortable_by do |s|
    s.field :name
    s.field :shop, as: Shop.arel_table[:name], scope: -> { includes(:shop) }
    s.default 'shop,name'
  end
end
