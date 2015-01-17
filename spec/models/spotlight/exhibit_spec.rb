require 'spec_helper'

describe Spotlight::Exhibit, :type => :model do
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

    it "should have main navigations" do
      expect(subject.main_navigations).to have(3).main_navigations
      expect(subject.main_navigations.map(&:label).compact).to be_blank
      expect(subject.main_navigations.map(&:weight)).to eq [0, 1, 2]
    end
  end

  describe "contacts" do
    before do
      subject.contacts_attributes= [
        {"show_in_sidebar"=>"0", "name"=>"Justin Coyne", "contact_info" => {"email"=>"jcoyne@justincoyne.com", "title"=>"", "location"=>"US"}},
        {"show_in_sidebar"=>"0", "name"=>"", "contact_info" => {"email"=>"", "title"=>"Librarian", "location"=>""}}]
    end
    it "should accept nested contacts" do
      expect(subject.contacts.size).to eq 2
    end
  end

  describe "import" do
    it "should remove the default browse category" do
      subject.save
      expect { subject.import({}) }.to change {subject.searches.count}.by(0)
      expect { subject.import({"searches_attributes" => [{"title" => "All Exhibit Items","slug" => "all-exhibit-items"}]}) }.to change {subject.searches.count}.by(0)
    end

    it "should import nested attributes from the hash" do
      subject.save
      some_value = {}
      expect(subject).to receive(:update).with(some_value)
      subject.import some_value
    end

    it "should munge taggings so they can be imported easily" do
      subject.save
      expect do
        subject.import("owned_taggings_attributes"=>[{"taggable_type"=>"SolrDocument", "context"=>'tags', "created_at"=>"2015-01-16T18:23:27.340Z", "taggable_id"=>"1", "tag_attributes"=>{"name"=>"xyz"}}])
      end.to change { subject.owned_taggings.count }.by(1)
      tag = subject.owned_taggings.last
      expect(tag.taggable_id).to eq "1"
      expect(tag.tag.name).to eq "xyz"
    end
  end

  describe "#blacklight_config" do
    subject { FactoryGirl.create(:exhibit) }
    before do
      subject.blacklight_configuration.index = { timestamp_field:  "timestamp_field" }
      subject.save!
      subject.reload
    end

    it "should create a blacklight_configuration from the database" do
      expect(subject.blacklight_config.index.timestamp_field).to eq 'timestamp_field'
    end
  end

  describe "#destroy" do
    subject { FactoryGirl.create(:exhibit) }
    let(:default_exhibit) { double }
    it "should touch the default exhibit when it is destroyed" do
      allow(Spotlight::Exhibit).to receive_messages(default: default_exhibit)
      expect(default_exhibit).to receive(:touch)
      subject.destroy
    end
  end

end
