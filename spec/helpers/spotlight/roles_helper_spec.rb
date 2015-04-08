require 'spec_helper'

describe Spotlight::RolesHelper, type: :helper do
  it 'is a list of options' do
    expect(helper.roles_for_select).to eq('Admin' => 'admin', 'Curator' => 'curator')
  end
end
