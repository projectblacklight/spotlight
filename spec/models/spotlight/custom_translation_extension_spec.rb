# frozen_string_literal: true

describe Spotlight::CustomTranslationExtension do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  subject do
    Class.new(ActiveRecord::Base) do
      include Spotlight::CustomTranslationExtension
    end
  end

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
