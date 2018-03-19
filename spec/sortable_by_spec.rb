require File.dirname(__FILE__) + '/spec_helper'

describe ActiveRecord::SortableByHelper do
  it 'should have config' do
    expect(Foo._sortable_by_scope_options).to include(:default, :scopes)
    expect(Foo._sortable_by_scope_options[:default]).to eq(title: :asc)
    expect(Foo._sortable_by_scope_options[:scopes]).to be_instance_of(Hash)
    expect(Foo._sortable_by_scope_options[:scopes]).to include('title', 'age', 'semver', 'insensitive')
    expect(Bar._sortable_by_scope_options).to eq(default: { id: :asc }, scopes: {})
  end

  it 'should generate scopes' do
    expect(Foo.sorted_by('title').pluck(:title)).to eq(%w[A B C b])
    expect(Foo.sorted_by('-title').pluck(:title)).to eq(%w[b C B A])
    expect(Foo.sorted_by('age,title').pluck(:title)).to eq(%w[B A b C])
    expect(Foo.sorted_by('invalid , -age').pluck(:title)).to eq(%w[C b A B])
    expect(Foo.sorted_by('insensitive,age').pluck(:title)).to eq(%w[A B b C])
    expect(Foo.sorted_by('-insensitive,age').pluck(:title)).to eq(%w[C B b A])
    expect(Foo.sorted_by('semver').pluck(:title)).to eq(%w[b B C A])
    expect(Foo.sorted_by('-semver').pluck(:title)).to eq(%w[A C B b])
    expect(Foo.sorted_by('').pluck(:title)).to eq(%w[A B C b])
    expect(Foo.sorted_by(nil).pluck(:title)).to eq(%w[A B C b])

    expect(Bar.sorted_by('').pluck(:title)).to eq(%w[Y X])
    expect(Bar.sorted_by('title').pluck(:title)).to eq(%w[Y X])
    expect(Bar.where(title: 'X').sorted_by('title').pluck(:title)).to eq(%w[X])
  end
end
