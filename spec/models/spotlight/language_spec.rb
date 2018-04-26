# frozen_string_literal: true

RSpec.describe Spotlight::Language do
  describe '#to_native' do
    it 'is the native translation of the locale' do
      expect(described_class.new(locale: 'de').to_native).to eq 'Deutsch'
    end

    it 'is a blank string when the locale does not exist (for string comparison)' do
      expect(described_class.new(locale: 'xx').to_native).to eq ''
    end
  end

  describe 'when being destroyed' do
    let(:exhibit) { FactoryBot.create(:exhibit) }
    let(:language) { described_class.create(locale: 'es', exhibit: exhibit) }
    before { Translation.current_exhibit = exhibit }

    it 'also destroys its locale related pages' do
      page_es = exhibit.home_page.clone_for_locale('es').tap(&:save)

      expect(Spotlight::Page.exists?(page_es.id)).to be true

      expect do
        language.destroy
      end.to change(Spotlight::Page, :count).by(-1)

      expect(Spotlight::Page.exists?(page_es.id)).to be false
    end

    it 'also destroys its locale related translations' do
      translation = FactoryBot.create(:translation, key: 'some.key', exhibit: exhibit, locale: 'es')

      expect do
        language.destroy
      end.to change(Translation, :count).by(-1)

      expect(Translation.exists?(translation.id)).to be false
    end
  end
end
