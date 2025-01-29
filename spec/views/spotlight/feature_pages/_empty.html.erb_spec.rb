# frozen_string_literal: true

RSpec.describe 'spotlight/feature_pages/_empty.html.erb', type: :view do
  let(:can?) { false }

  before do
    allow(view).to receive_messages(can?: can?)
    render
  end

  describe 'when a user cannot edit' do
    it 'does not render an ordered list of steps' do
      expect(rendered).to have_no_css('ol')
    end
  end

  describe 'when a user can edit' do
    let(:can?) { true }

    it 'renders a heading' do
      expect(rendered).to have_css('h2', text: 'Building this feature page')
    end

    it 'renders an ordered list of steps' do
      expect(rendered).to have_css('ol li', count: 6)
    end
  end
end
