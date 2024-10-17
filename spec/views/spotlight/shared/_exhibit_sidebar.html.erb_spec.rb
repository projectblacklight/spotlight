# frozen_string_literal: true

describe 'spotlight/shared/_exhibit_sidebar', type: :view do
  let(:current_exhibit) { FactoryBot.create(:exhibit) }

  before do
    allow(view).to receive_messages(current_exhibit:, exhibit_root_path: '/some/path')
  end

  context 'with a configured analytics integration' do
    before do
      allow(current_exhibit).to receive(:analytics_provider).and_return(double(Spotlight::Analytics::Ga, enabled?: true))
    end

    it 'has an analytics link in the sidebar' do
      render

      expect(rendered).to have_link 'Analytics'
    end
  end

  context 'without a configured analytics integration' do
    it 'does not have an analytics link in the sidebar' do
      render

      expect(rendered).to have_no_link 'Analytics'
    end
  end
end
