require 'spec_helper'

describe Spotlight::Exhibit do
  subject { Spotlight::Exhibit.new(name: 'test', title: "Sample") }

  it "should have a title" do
    subject.title = "Test title"
    expect(subject.title).to eq "Test title"
  end

  it "should have a subtitle" do
    subject.subtitle = "Test subtitle"
    expect(subject.subtitle).to eq "Test subtitle"
  end

  it "should have a description that strips html tags" do
    subject.description = "Test <b>description</b>"
    subject.save!
    expect(subject.description).to eq "Test description"
  end

  it "should have contact emails that validate format" do
    subject.contact_emails = ['chris@example.com', 'jesse@stanford.edu', '@-foo']
    expect(subject.contact_emails).to eq ['chris@example.com', 'jesse@stanford.edu', '@-foo']
    expect(subject).to_not be_valid
    expect(subject.errors[:contact_emails]).to eq ['@-foo is not valid']
  end

  describe "that is saved" do
    before { subject.save!  }

    it "should have searches" do
      search = Spotlight::Search.create!(exhibit: subject)
      Search.create! # it shouldn't get one of these
      expect(subject.searches).to eq [search]
    end

    it "should have a configuration" do
      expect(subject.blacklight_configuration).to be_kind_of Spotlight::BlacklightConfiguration
    end
  end

  describe "contacts" do
    before do
      subject.contacts_attributes= [
        {"show_in_sidebar"=>"0", "name"=>"Justin Coyne", "email"=>"jcoyne@justincoyne.com", "title"=>"", "location"=>"US"},
        {"show_in_sidebar"=>"0", "name"=>"", "email"=>"", "title"=>"Librarian", "location"=>""}]
    end
    it "should accept nested contacts" do
      expect(subject.contacts.size).to eq 2
    end
  end
end
