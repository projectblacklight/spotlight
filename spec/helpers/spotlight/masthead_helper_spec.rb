# frozen_string_literal: true

RSpec.describe Spotlight::MastheadHelper, type: :helper do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:site) { Spotlight::Site.instance }

  before do
    allow(helper).to receive(:current_exhibit).and_return(nil)
    allow(helper).to receive(:current_site).and_return(site)
  end

  describe '#masthead_heading_content' do
    context 'when there is a current exhibit' do
      before { allow(helper).to receive(:current_exhibit).and_return(exhibit) }

      it { expect(helper.masthead_heading_content).to eq exhibit.title }
    end

    context 'when there is no current exhibit' do
      it { expect(helper.masthead_heading_content).to eq 'Blacklight' } # the application_name
    end
  end

  describe '#masthead_subheading_content' do
    context 'when there is a current exhibit' do
      before { allow(helper).to receive(:current_exhibit).and_return(exhibit) }

      context 'when the exhibit has a subtitle' do
        before { exhibit.subtitle = 'MastheadHelper Spec Exhibit' }

        it { expect(helper.masthead_subheading_content).to eq 'MastheadHelper Spec Exhibit' }
      end

      context 'when the exhibit does not have a subtitle' do
        it { expect(helper.masthead_subheading_content).to be_nil }
      end
    end

    context 'when there is no current exhibit' do
      context 'when the site has a subtitle' do
        before { site.subtitle = "The site's subtitle" }

        it { expect(helper.masthead_subheading_content).to eq "The site's subtitle" }
      end

      context 'when the site does not have a subtitle' do
        it { expect(helper.masthead_subheading_content).to be_nil }
      end
    end
  end
end
