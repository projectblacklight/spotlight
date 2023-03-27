# frozen_string_literal: true

describe Spotlight::IndexingCompleteMailer do
  subject { described_class.documents_indexed [1, 2, 3], exhibit, user, 3, {} }

  let(:user) { double(email: 'test@example.com') }
  let(:exhibit) { double(title: 'Exhibit title') }

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
    subject { described_class.documents_indexed [1], exhibit, user, nil, {} }

    it 'handles pluralization when only a single item was indexed' do
      expect(subject.body.encoded).to match '1 document has'
    end
  end

  it 'includes the exhibit title' do
    expect(subject.body.encoded).to match exhibit.title
  end

  context 'with errors' do
    subject { described_class.documents_indexed [], exhibit, user, 0, { 1 => ['missing title'], 20 => ['whatever'] } }

    it 'includes some errors' do
      expect(subject.body.encoded).to match 'Errors'
      expect(subject.body.encoded).to match 'Row 1: missing title'
      expect(subject.body.encoded).to match 'Row 20: whatever'
    end
  end
end
