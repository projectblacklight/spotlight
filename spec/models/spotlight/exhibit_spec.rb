require 'spec_helper'

describe Spotlight::Exhibit do
  subject { Spotlight::Exhibit.new(title: "Sample") }

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
  describe "contact_emails" do
    before do
      subject.contact_emails_attributes= [ { "email"=>"chris@example.com"}, {"email"=>"jesse@stanford.edu"}]
    end
    it "should accept nested contact_emails" do
      expect(subject.contact_emails.size).to eq 2
    end
  end

  it "should have a #to_s" do
    expect(subject.to_s).to eq "Sample"
    subject.title = "New Title"
    expect(subject.to_s).to eq "New Title"
  end

  describe "that is saved" do
    before { subject.save!  }

    it "should have a configuration" do
      expect(subject.blacklight_configuration).to be_kind_of Spotlight::BlacklightConfiguration
    end

    it "should have an unpublished search" do
      expect(subject.searches).to have(1).search
      expect(subject.searches.published).to be_empty
      expect(subject.searches.first.query_params).to be_empty
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

  describe "import" do
    it "should remove the default browse category" do
      subject.save
      expect { subject.import({}) }.to change {subject.searches.count}.by(-1)
      expect(subject.searches.map { |x| x.title }).not_to include "Browse All Exhibit Items"
    end

    it "should import nested attributes from the hash" do
      subject.save
      some_value = double
      subject.should_receive(:update).with(some_value)
      subject.import some_value
    end
  end
end
