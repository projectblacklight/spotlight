require 'spec_helper'

describe Spotlight::MainNavigation, type: :model do
  before do
    subject.exhibit = FactoryGirl.create(:exhibit)
  end

  it 'has a default_label' do
    subject.nav_type = :curated_features
    expect(subject.default_label).to eq 'Curated Features'
  end

  it 'returns the use the default label in the absence of a label' do
    expect(subject.label).to be_blank
    expect(subject.label_or_default).to eq subject.default_label
    subject.label = 'something else'
    expect(subject.label_or_default).to eq 'something else'
  end
end
