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

   
end
