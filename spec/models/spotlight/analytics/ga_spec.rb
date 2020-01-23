# frozen_string_literal: true

describe Spotlight::Analytics::Ga do
  it 'does not be enabled without configuration' do
    expect(subject).not_to be_enabled
  end

  describe '#site' do
    it 'selects the correct profile based on the web property id' do
      allow(Spotlight::Engine.config).to receive_messages(ga_web_property_id: 'bar')
      allow(subject).to receive_message_chain(
        :user,
        :accounts,
        :first,
        profiles: [
          double('profile1', web_property_id: 'foo'), double('profile2', web_property_id: 'bar')
        ]
      )
      expect(subject.site.web_property_id).to eq 'bar'
    end
  end
end
