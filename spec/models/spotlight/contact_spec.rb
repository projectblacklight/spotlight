require 'spec_helper'

describe Spotlight::Contact, type: :model do
  context '#show_in_sidebar' do
    it 'is an attribute' do
      subject.show_in_sidebar = false
      subject.save
      expect(subject.show_in_sidebar).to be_falsey
    end
    it 'is published by default' do
      subject.save
      expect(subject.show_in_sidebar).to be_truthy
    end
  end
  context '#fields' do
    it 'show allow new fields to be configured' do
      expect(subject.class.fields).to_not have_key(:new_field)
      described_class.fields[:new_field] = {}
      expect(subject.class.fields).to have_key(:new_field)
    end
  end

  describe '#contact_info' do
    it 'persisted symbolized keys' do
      subject.contact_info = { 'some' => 'value' }
      subject.save
      expect(subject.contact_info).to include some: 'value'
    end
  end
end
