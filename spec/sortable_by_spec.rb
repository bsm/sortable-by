require File.expand_path('./spec_helper', __dir__)

describe ActiveRecord::SortableBy do
  before do
    c = ActiveRecord::Base.connection
    c.tables.each do |t|
      c.update "DELETE FROM #{t}"
    end
  end

  it 'should have config' do
    expect(Post._sortable_by_config._fields.keys).to match_array(%w[title created])
    expect(Post._sortable_by_config._default).to eq('-created')
    expect(SubPost._sortable_by_config._fields.keys).to match_array(%w[title created])
    expect(SubPost._sortable_by_config._default).to eq('-created')

    expect(App._sortable_by_config._fields.keys).to match_array(%w[name version])
    expect(App._sortable_by_config._default).to eq('name')

    expect(Shop._sortable_by_config._fields.keys).to be_empty
    expect(Shop._sortable_by_config._default).to be_nil

    expect(Product._sortable_by_config._fields.keys).to match_array(%w[name shop])
    expect(Product._sortable_by_config._default).to eq('shop,name')
  end

  it 'should simply order' do
    Post.create! title: 'A', created_at: Time.at(1515151500)
    Post.create! title: 'b', created_at: Time.at(1515151600)
    Post.create! title: 'C', created_at: Time.at(1515151400)

    expect(Post.sorted_by(nil).pluck(:title)).to eq(%w[b A C])
    expect(Post.sorted_by('').pluck(:title)).to eq(%w[b A C])
    expect(Post.sorted_by('invalid').pluck(:title)).to eq(%w[b A C])

    expect(Post.sorted_by('-created').pluck(:title)).to eq(%w[b A C])
    expect(Post.sorted_by('created').pluck(:title)).to eq(%w[C A b])

    expect(Post.sorted_by('title').pluck(:title)).to eq(%w[A C b])
    expect(Post.sorted_by('-title').pluck(:title)).to eq(%w[b C A])
    expect(Post.sorted_by('   title ').pluck(:title)).to eq(%w[A C b])
  end

  it 'should support STI inheritance and overrides' do
    SubPost.create! title: 'A', created_at: Time.at(1515151700)
    SubPost.create! title: 'b', created_at: Time.at(1515151600)
    Post.create! title: 'C', created_at: Time.at(1515151400)
    SubPost.create! title: 'D', created_at: Time.at(1515151500)

    expect(Post.sorted_by(nil).pluck(:title)).to eq(%w[A b D C])
    expect(SubPost.sorted_by(nil).pluck(:title)).to eq(%w[A b D])
    expect(SubPost.sorted_by('-created').pluck(:title)).to eq(%w[A b D])
    expect(SubPost.sorted_by('created').pluck(:title)).to eq(%w[D b A])

    expect(Post.sorted_by('title').pluck(:title)).to eq(%w[A C D b])
    expect(SubPost.sorted_by('title').pluck(:title)).to eq(%w[A b D])
  end

  it 'should support composition' do
    App.create! name: 'E', major: 0, minor: 9, patch: 2
    App.create! name: 'A', major: 1, minor: 0, patch: 1
    App.create! name: 'D', major: 1, minor: 0, patch: 6
    App.create! name: 'C', major: 1, minor: 1, patch: 0
    App.create! name: 'B', major: 2, minor: 2, patch: 0

    expect(App.sorted_by(nil).pluck(:name)).to eq(%w[A B C D E])
    expect(App.sorted_by('version').pluck(:name)).to eq(%w[E A D C B])
    expect(App.sorted_by('-version').pluck(:name)).to eq(%w[B C D A E])
  end

  it 'should support associations' do
    y = Shop.create! name: 'Y'
    x = Shop.create! name: 'X'

    Product.create! name: 'a', shop_id: y.id
    Product.create! name: 'B', shop_id: y.id, active: false
    Product.create! name: 'c', shop_id: x.id
    Product.create! name: 'D', shop_id: y.id
    Product.create! name: 'e', shop_id: x.id
    Product.create! name: 'f', shop_id: x.id, active: false

    expect(Product.sorted_by(nil).pluck(:name)).to eq(%w[c e f a B D])
    expect(Product.where(active: true).sorted_by(nil).pluck(:name)).to eq(%w[c e a D])
    expect(Product.sorted_by('name').pluck(:name)).to eq(%w[a B c D e f])
  end
end
