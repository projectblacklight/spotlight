describe Spotlight::LanguagesHelper, type: :helper do
  let(:current_exhibit) { FactoryBot.create(:exhibit) }
  describe '#add_exhibit_language_dropdown_options' do
    it 'returns a sorted Array of locales and their names' do
      allow(helper).to receive_messages(current_exhibit: current_exhibit)
      expect(helper.add_exhibit_language_dropdown_options).to match_array(
        [
          ['Albanian', :sq],
          ['Chinese', :zh],
          ['French', :fr],
          ['German', :de],
          ['Italian', :it],
          ['Portugese - Brazil', :'pt-BR'],
          ['Spanish', :es]
        ]
      )
    end
  end
end
