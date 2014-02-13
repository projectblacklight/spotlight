require 'spec_helper'

describe Spotlight::RolesHelper do
  it "should be a list of options" do
    expect(helper.roles_for_select).to eq({"Admin"=>"admin", "Curator"=>"curator"})
  end
end
