require File.dirname(__FILE__) + '/spec_helper'

describe ActiveRecord::SortableByHelper do

  it 'should have config' do
    expect(Foo._sortable_by_scope_options).to eq(default: {title: :asc}, whitelist: Set.new(["title", "age"]))
    expect(Bar._sortable_by_scope_options).to eq(default: {id: :asc}, whitelist: Set.new)
  end

  it 'should generate scopes' do
    expect(Foo.sorted_by("title").pluck(:title)).to eq(["A", "B", "B", "C"])
    expect(Foo.sorted_by("-title").pluck(:title)).to eq(["C", "B", "B", "A"])
    expect(Foo.sorted_by("age,title").pluck(:title)).to eq(["B", "A", "B", "C"])
    expect(Foo.sorted_by("invalid , -age").pluck(:title)).to eq(["C", "B", "A", "B"])
    expect(Foo.sorted_by("").pluck(:title)).to eq(["A", "B", "B", "C"])
    expect(Foo.sorted_by(nil).pluck(:title)).to eq(["A", "B", "B", "C"])

    expect(Bar.sorted_by("").pluck(:title)).to eq(["Y", "X"])
    expect(Bar.sorted_by("title").pluck(:title)).to eq(["Y", "X"])
    expect(Bar.where(title: "X").sorted_by("title").pluck(:title)).to eq(["X"])
  end

end
