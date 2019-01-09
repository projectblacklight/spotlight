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
        allow(Spotlight::Engine.config).to receive(:exhibit_themes).and_return(%w(default modern))
        exhibit.update(theme: 'modern')
      end

      it 'uses a suffixed stylesheet name' do
        expect(helper.exhibit_stylesheet_link_tag('application')).to eq helper.stylesheet_link_tag('application_modern')
      end
    end
  end
end
