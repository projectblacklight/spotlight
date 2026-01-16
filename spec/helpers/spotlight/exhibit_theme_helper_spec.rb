# frozen_string_literal: true

RSpec.describe Spotlight::ExhibitThemeHelper, type: :helper do
  describe '#exhibit_stylesheet_link_tag' do
    let(:exhibit) { FactoryBot.create(:exhibit) }

    before do
      allow(helper).to receive_messages(current_exhibit: exhibit)
    end

    context 'without an exhibit context' do
      let(:exhibit) { nil }

      it 'uses the standard stylesheet' do
        expect(helper.exhibit_stylesheet_link_tag('application')).to eq helper.stylesheet_link_tag('application')
      end
    end

    context 'for an exhibit without a selected theme' do
      before do
        exhibit.update(theme: nil)
      end

      it 'uses the standard stylesheet' do
        expect(helper.exhibit_stylesheet_link_tag('application')).to eq helper.stylesheet_link_tag('application')
      end
    end

    context 'for an exhibit with an invalid theme' do
      before do
        exhibit.update(theme: 'garbage')
      end

      it 'uses the standard stylesheet' do
        expect(helper.exhibit_stylesheet_link_tag('application')).to eq helper.stylesheet_link_tag('application')
      end
    end

    context 'for a themed exhibit' do
      before do
        allow(Spotlight::Engine.config).to receive(:exhibit_themes).and_return(%w[default modern])
        exhibit.update(theme: 'modern')
      end

      it 'uses a suffixed stylesheet name' do
        expect(helper.exhibit_stylesheet_link_tag('application')).to eq helper.stylesheet_link_tag('application_modern')
      end
    end
  end
end
