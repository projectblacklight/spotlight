require 'spec_helper'

describe Spotlight::IndexingCompleteMailer do
  let(:user) { double(email: 'test@example.com') }
  let(:exhibit) { double(title: 'Exhibit title') }
  subject { described_class.documents_indexed [1, 2, 3], exhibit, user }

  it 'renders the receiver email' do
    expect(subject.to).to eql([user.email])
  end

  it 'includes a title' do
    expect(subject.body.encoded).to match 'Your CSV file has just finished being processed'
  end

  it 'describes how many documents were indexed' do
    expect(subject.body.encoded).to match '3 documents'
  end

  context 'single item' do
    subject { described_class.documents_indexed [1], exhibit, user }

    it 'handles pluralization when only a single item was indexed' do
      expect(subject.body.encoded).to match '1 document has'
    end
  end

  it 'includes the exhibit title' do
    expect(subject.body.encoded).to match exhibit.title
  end
end
