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
