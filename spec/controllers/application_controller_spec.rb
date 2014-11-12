require 'spec_helper'

describe ApplicationController, :type => :controller do
  it { is_expected.to be_a_kind_of Spotlight::Controller }
end