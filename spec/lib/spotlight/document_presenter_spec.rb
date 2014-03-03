require 'spec_helper'

describe Spotlight::DocumentPresenter do
  let(:request_context) { double(:add_facet_params => '') }
  let(:document) { SolrDocument.new('full_title_tesim' => ['Main title & stuff'] )}
  let(:config) do
    Blacklight::Configuration.new.configure do |config|
      config.index.title_field = 'full_title_tesim'
    end
  end

  subject { Spotlight::DocumentPresenter.new(document, request_context, config) }

  describe "#raw_document_heading" do
    it "should not escape html" do
      subject.raw_document_heading.should == "Main title & stuff"
    end
  end
end
