# frozen_string_literal: true

describe Spotlight::Analytics::Ga do
  it 'does not be enabled without configuration' do
    expect(subject).not_to be_enabled
  end

  describe '#client' do
    it 'selects the correct profile based on the web property id' do
      allow(Spotlight::Engine.config).to receive_messages(ga_property_id: 'bar')
      expect(subject.send(:ga_property_id)).to eq 'bar'
    end
  end
end
