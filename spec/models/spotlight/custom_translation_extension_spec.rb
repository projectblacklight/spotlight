# frozen_string_literal: true

RSpec.describe Spotlight::CustomTranslationExtension do
  subject do
    Class.new(ActiveRecord::Base) do
      include Spotlight::CustomTranslationExtension
    end
  end

  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe '.current_exhibit' do
    it 'sets the current exhibit' do
      subject.current_exhibit = exhibit
      expect(subject.current_exhibit).to eq exhibit
    end

    it 'reloads the i18n' do
      allow(I18n.backend).to receive(:reload!)

      subject.current_exhibit = exhibit
    end
  end
end
