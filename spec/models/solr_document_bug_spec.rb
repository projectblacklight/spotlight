describe SolrDocument, type: :model do
  subject { described_class.new(id: 'abcd123') }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_alt) { FactoryGirl.create(:exhibit) }

  describe '#save' do
    context 'when filter_resources_by_exhibit is true' do
      before do
        Spotlight::Engine.config.filter_resources_by_exhibit = true
        Spotlight::SolrDocumentSidecar.create! document: subject, exhibit: exhibit,
                                               data: { 'a_tesim' => 1, 'b_tesim' => 2, 'c_tesim' => 3 }
        Spotlight::SolrDocumentSidecar.create! document: subject, exhibit: exhibit_alt,
                                               data: { 'd_tesim' => 1, 'e_tesim' => 2, 'f_tesim' => 3 }
      end
      it 'includes filter fields' do
        expectation = hash_including(:"spotlight_exhibit_slug_#{exhibit.slug}_bsi", :"spotlight_exhibit_slug_#{exhibit_alt.slug}_bsi")
        expect(subject).to receive('hash_for_solr_update').with(expectation)
        subject.save
      end
    end
  end
end
