describe Spotlight::LanguagesHelper, type: :helper do
  let(:current_exhibit) { FactoryBot.create(:exhibit) }
  describe '#add_exhibit_language_dropdown_options' do
    it 'returns a sorted Array of locales and their names' do
      allow(helper).to receive_messages(current_exhibit: current_exhibit)
      expect(helper.add_exhibit_language_dropdown_options).to match_array(
        [
          ['Albanian', :sq],
          ['Chinese', :zh],
          ['Dutch', :nl],
          ['French', :fr],
          ['German', :de],
          ['Hungarian', :hu],
          ['Italian', :it],
          ['Portugese - Brazil', :'pt-BR'],
          ['Spanish', :es]
        ]
      )
    end
  end

  describe '#locale_selecter_dropown_options' do
    before do
      allow(helper).to receive_messages(current_ability: Ability.new(nil))
      allow(helper).to receive_messages(current_exhibit: current_exhibit)

      current_exhibit.languages = [
        FactoryBot.create(:language, public: true, locale: 'es'),
        FactoryBot.create(:language, public: true, locale: 'de')
      ]
      current_exhibit.save
    end

    it 'includes the default locale (when it is not current)' do
      allow(I18n).to receive(:locale).and_return(:es)
      expect(helper.locale_selecter_dropown_options.last).to be_a(Spotlight::Language)
      expect(helper.locale_selecter_dropown_options.last).not_to be_persisted
      expect(helper.locale_selecter_dropown_options.last.locale).to eq 'en'
    end

    it 'does not include the current locale' do
      expect(
        helper.locale_selecter_dropown_options.map(&:locale)
      ).not_to include(I18n.locale.to_s)
    end

    it 'sorts by the native translation' do
      allow(I18n).to receive(:locale).and_return(:it)

      expect(
        helper.locale_selecter_dropown_options.map(&:to_native)
      ).to eq %w[Deutsch English Español]
    end
  end

  describe '#default_language?' do
    context 'when using default locale' do
      it do
        expect(helper.default_language?).to eq true
      end
      it do
        expect(helper).to receive_messages(params: { locale: :en })
        expect(helper.default_language?).to eq true
      end
    end
    context 'when using a different locale' do
      it do
        expect(helper).to receive_messages(params: { locale: :it })
        expect(helper.default_language?).to eq false
      end
    end
  end
end
