require 'spec_helper'

describe Spotlight::AboutPage do
  it {should_not be_feature_page}
  it {should be_about_page}
end
