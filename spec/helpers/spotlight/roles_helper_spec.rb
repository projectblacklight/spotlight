# frozen_string_literal: true

RSpec.describe Spotlight::RolesHelper, type: :helper do
  it 'is a list of options' do
    expect(helper.roles_for_select).to eq('Admin' => 'admin', 'Curator' => 'curator', 'Viewer' => 'viewer')
  end
end
