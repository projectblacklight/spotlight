# frozen_string_literal: true

describe Spotlight::MainAppHelpers, type: :helper do
  describe '#show_contact_form?' do
    subject { helper }
    let(:exhibit) { FactoryBot.create :exhibit }
    let(:exhibit_with_contacts) { FactoryBot.create :exhibit }
    context 'with an exhibit with confirmed contacts' do
      before do
        exhibit_with_contacts.contact_emails.create(email: 'cabeer@stanford.edu').tap do |e|
          if e.respond_to? :confirm
            e.confirm
          else
            e.confirm!
          end
        end
      end

      before { allow(helper).to receive_messages current_exhibit: exhibit_with_contacts }

      its(:show_contact_form?) { should be_truthy }
    end

    context 'with an exhibit with only unconfirmed contacts' do
      before { exhibit_with_contacts.contact_emails.build email: 'cabeer@stanford.edu' }

      before { allow(helper).to receive_messages current_exhibit: exhibit_with_contacts }

      its(:show_contact_form?) { should be_falsey }
    end

    context 'with an exhibit without contacts' do
      before { allow(helper).to receive_messages current_exhibit: exhibit }

      its(:show_contact_form?) { should be_falsey }
    end

    context 'outside the context of an exhibit' do
      before { allow(helper).to receive_messages current_exhibit: nil }

      its(:show_contact_form?) { should be_falsey }
    end

    context 'with a default contact address' do
      before { allow(Spotlight::Engine.config).to receive_messages default_contact_email: 'root@localhost' }

      before { allow(helper).to receive_messages current_exhibit: exhibit }

      its(:show_contact_form?) { should be_truthy }
    end
  end

  describe '#themed_stylesheet_link_tag' do
    let(:exhibit) { FactoryBot.create(:exhibit) }
    let(:site) { Spotlight::Site.instance }

    before do
      allow(helper).to receive_messages(current_exhibit: exhibit)
      allow(helper).to receive_messages(current_site: site)

      allow(Spotlight::Engine.config).to receive(:exhibit_themes).and_return(%w(modern fancy))
    end

    context 'without an exhibit context and without a site-wide theme' do
      let(:exhibit) { nil }
      before do
        site.update(theme: nil)
      end

      it 'uses the standard stylesheet' do
        expect(helper.themed_stylesheet_link_tag('application')).to eq helper.stylesheet_link_tag('application')
      end
    end

    context 'without an exhibit context and with a site-wide theme' do
      let(:exhibit) { nil }
      before do
        site.update(theme: 'fancy')
      end

      it 'uses the themed stylesheet' do
        expect(helper.themed_stylesheet_link_tag('application')).to eq helper.stylesheet_link_tag('application_fancy')
      end
    end

    context 'for an exhibit without a theme and without a site-wide theme' do
      before do
        exhibit.update(theme: nil)
      end

      it 'uses the standard stylesheet' do
        expect(helper.themed_stylesheet_link_tag('application')).to eq helper.stylesheet_link_tag('application')
      end
    end

    context 'for an exhibit without a theme and with a site-wide theme' do
      before do
        exhibit.update(theme: nil)
        site.update(theme: 'fancy')
      end

      it 'uses the themed stylesheet' do
        expect(helper.themed_stylesheet_link_tag('application')).to eq helper.stylesheet_link_tag('application_fancy')
      end
    end

    context 'for an exhibit with a theme and without a site-wide theme' do
      before do
        exhibit.update(theme: 'modern')
        site.update(theme: nil)
      end

      it 'uses the themed stylesheet' do
        expect(helper.themed_stylesheet_link_tag('application')).to eq helper.stylesheet_link_tag('application_modern')
      end
    end

    context 'for an exhibit with a theme and with a site-wide theme' do
      before do
        exhibit.update(theme: 'modern')
        site.update(theme: 'fancy')
      end

      it 'uses the exhibit themed stylesheet' do
        expect(helper.themed_stylesheet_link_tag('application')).to eq helper.stylesheet_link_tag('application_modern')
      end
    end

    context 'for an exhibit with an invalid theme' do
      before do
        exhibit.update(theme: 'garbage')
        site.update(theme: nil)
      end

      it 'uses the standard stylesheet' do
        expect(helper.themed_stylesheet_link_tag('application')).to eq helper.stylesheet_link_tag('application')
      end
    end
  end
end
