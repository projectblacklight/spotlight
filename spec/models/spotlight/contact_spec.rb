require 'spec_helper'

describe Spotlight::Contact, :type => :model do
  let(:exhibit) { stub_model(Spotlight::Exhibit) }
  before do
    subject.exhibit = exhibit
  end
  context "#show_in_sidebar" do
    it "should be an attribute" do
      subject.show_in_sidebar = false
      subject.save
      expect(subject.show_in_sidebar).to be_falsey
    end
    it "should be published by default" do
      subject.save
      expect(subject.show_in_sidebar).to be_truthy
    end
  end
  context "touch_about_pages" do
    let(:about_page) { stub_model(Spotlight::AboutPage) }
    before do
      exhibit.about_pages = [about_page]
    end
    it 'should touch about pages after save' do
      expect(about_page).to receive(:touch)
      subject.save
    end
  end
  context "#fields" do
    it 'show allow new fields to be configured' do
      expect(subject.class.fields).to_not have_key(:new_field)
      Spotlight::Contact.fields[:new_field] = {}
      expect(subject.class.fields).to have_key(:new_field)
    end
  end
end
