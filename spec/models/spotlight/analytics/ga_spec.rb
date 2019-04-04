# frozen_string_literal: true

describe Spotlight::Analytics::Ga do
  it 'does not be enabled without configuration' do
    expect(described_class.enabled?).to be_falsey
  end
end
