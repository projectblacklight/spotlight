# frozen_string_literal: true

RSpec.describe 'spotlight/exhibits/_exhibit_card.html.erb', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:p) { 'spotlight/exhibits/exhibit_card' }

  before do
    allow(view).to receive_messages(exhibit_path: '/')
  end

  context 'when the exhibit has no thumbnail' do
    before do
      exhibit.update(thumbnail_id: nil)
    end

    it 'has a placeholder thumbnail' do
      render(p, exhibit:)

      expect(rendered).to have_css 'img.default-thumbnail'
    end
  end

  it 'has a thumbnail' do
    render(p, exhibit:)

    expect(rendered).to have_css 'img'
  end

  it 'has a title' do
    render(p, exhibit:)

    expect(rendered).to have_css '.card-title', text: exhibit.title
  end

  context 'when the exhibit has a description' do
    before do
      exhibit.update(description: 'Test <b>description</b> & more.')
    end

    it 'has a description that strips html tags' do
      render(p, exhibit:)

      expect(rendered).to have_css '.description', text: 'Test description & more.'
    end
  end

  context 'when the exhibit is unpublished' do
    before do
      exhibit.update(published: false)
    end

    it 'has an unpublished banner' do
      render(p, exhibit:)

      expect(rendered).to have_css '.badge.unpublished', text: 'Unpublished'
    end
  end

  context 'when the exhibit is previewable' do
    before do
      exhibit.update(published: true, discovery_enabled: false)
    end

    it 'has a preview banner' do
      render(p, exhibit:)

      expect(rendered).to have_css '.badge.previewable', text: 'Preview'
      expect(rendered).to have_no_css '.badge.unpublished'
    end
  end

  context 'when the exhibit is discoverable' do
    it 'has no banner' do
      render(p, exhibit:)

      expect(rendered).to have_no_css '.badge'
    end
  end
end
