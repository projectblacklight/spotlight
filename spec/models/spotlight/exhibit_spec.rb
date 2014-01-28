require 'spec_helper'

describe Spotlight::Exhibit do
  it "should have facets" do
    expect(subject.facets).to eq []
    subject.facets << 'title_facet' << 'author_facet'
    expect(subject.facets).to eq ['title_facet', 'author_facet']
  end
   
end
