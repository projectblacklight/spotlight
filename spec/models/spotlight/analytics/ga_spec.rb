# frozen_string_literal: true

describe Spotlight::Analytics::Ga do
  it 'does not be enabled without configuration' do
    expect(described_class).not_to be_enabled
  end
end
