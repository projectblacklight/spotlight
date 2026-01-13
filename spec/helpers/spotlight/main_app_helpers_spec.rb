# frozen_string_literal: true

RSpec.describe Spotlight::MainAppHelpers, type: :helper do
  describe '#show_contact_form?' do
    subject { helper }

    let(:exhibit) { FactoryBot.create(:exhibit) }
    let(:exhibit_with_contacts) { FactoryBot.create(:exhibit) }

    context 'with an exhibit with confirmed contacts' do
      before do
        exhibit_with_contacts.contact_emails.create(email: 'cabeer@stanford.edu').tap do |e|
          if e.respond_to? :confirm
            e.confirm
          else
            e.confirm!
          end
        end
        allow(helper).to receive_messages current_exhibit: exhibit_with_contacts
      end

      its(:show_contact_form?) { is_expected.to be_truthy }
    end

    context 'with an exhibit with only unconfirmed contacts' do
      before do
        exhibit_with_contacts.contact_emails.build email: 'cabeer@stanford.edu'
        allow(helper).to receive_messages current_exhibit: exhibit_with_contacts
      end

      its(:show_contact_form?) { is_expected.to be_falsey }
    end

    context 'with an exhibit without contacts' do
      before { allow(helper).to receive_messages current_exhibit: exhibit }

      its(:show_contact_form?) { is_expected.to be_falsey }
    end

    context 'outside the context of an exhibit' do
      before { allow(helper).to receive_messages current_exhibit: nil }

      its(:show_contact_form?) { is_expected.to be_falsey }
    end

    context 'with a default contact address' do
      before do
        allow(Spotlight::Engine.config).to receive_messages default_contact_email: 'root@localhost'
        allow(helper).to receive_messages current_exhibit: exhibit
      end

      its(:show_contact_form?) { is_expected.to be_truthy }
    end
  end

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

  describe '#html_tag_attributes' do
    subject { helper.html_tag_attributes }

    context 'when rtl_enabled? is false' do
      before { allow(helper).to receive(:rtl_enabled?).and_return(false) }

      it 'does not set dir' do
        expect(subject).not_to have_key(:dir)
      end
    end

    context 'when rtl_enabled? is true' do
      before { allow(helper).to receive(:rtl_enabled?).and_return(true) }

      context 'with an RTL locale' do
        before { allow(helper).to receive(:rtl_locale?).and_return(true) }

        it 'sets dir to rtl' do
          expect(subject[:dir]).to eq 'rtl'
        end
      end

      context 'with an LTR locale' do
        before { allow(helper).to receive(:rtl_locale?).and_return(false) }

        it 'does not set dir' do
          expect(subject).not_to have_key(:dir)
        end
      end
    end
  end

  describe '#rtl_enabled?' do
    subject { helper.rtl_enabled? }

    context 'when rtl_enabled is false' do
      before { allow(Spotlight::Engine.config).to receive_messages(rtl_enabled: false) }

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when rtl_enabled is true' do
      before { allow(Spotlight::Engine.config).to receive_messages(rtl_enabled: true) }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when rtl_enabled is unset' do
      before { allow(Spotlight::Engine.config).to receive_messages(rtl_enabled: nil) }

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#rtl_locale?' do
    subject { helper.rtl_locale? }

    before { allow(Spotlight::Engine.config).to receive_messages(rtl_locales: %i[ar]) }

    context 'when the locale is in the rtl_locales list' do
      before { allow(I18n).to receive(:locale).and_return(:ar) }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when the locale is not in the rtl_locales list' do
      before { allow(I18n).to receive(:locale).and_return(:en) }

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end
end
