describe Translation, type: :model do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  describe 'is unique by key, locale, and exhibit' do
    it 'fails validation' do
      Translation.create(exhibit_id: exhibit.id, key: 'abc', locale: 'fr', value: 'yo')
      expect do
        Translation.create(exhibit_id: exhibit.id, key: 'abc', locale: 'fr', value: 'lo')
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
