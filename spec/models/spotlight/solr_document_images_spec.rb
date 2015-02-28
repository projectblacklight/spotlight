require "spec_helper"

describe Spotlight::SolrDocument::SpotlightImages do
  let(:subject) {
    SolrDocument.new(
      Spotlight::Engine.config.full_image_field   => ['http://lorempixel.com/800/500/'],
      Spotlight::Engine.config.thumbnail_field    => ['http://lorempixel.com/400/240/'],
      Spotlight::Engine.config.square_image_field => ['http://lorempixel.com/200/200/'],
    )
  }
  it 'should be a Versions class' do
    expect(subject.spotlight_image_versions).to be_a Spotlight::SolrDocument::SpotlightImages::Versions
  end
  it 'should map image urls in the document to the appropriate version' do
    expect(subject.spotlight_image_versions.full).to eq ['http://lorempixel.com/800/500/']
    expect(subject.spotlight_image_versions.thumb).to eq ['http://lorempixel.com/400/240/']
    expect(subject.spotlight_image_versions.square).to eq ['http://lorempixel.com/200/200/']
  end
  it 'should include the version keys in the versions array' do
    [:full, :thumb, :square].each do |version|
      expect(subject.spotlight_image_versions.versions).to include version
    end
  end
  it 'should include newly configured image versions' do
    Spotlight::ImageDerivatives.spotlight_image_derivatives << {
      version: :tiny,
      field: :new_image_field
    }
    subject = SolrDocument.new(new_image_field: ['abc'])
    expect(subject.spotlight_image_versions.tiny).to eq ['abc']
    Spotlight::ImageDerivatives.spotlight_image_derivatives.delete_if do |d|
      d[:version] == :tiny
    end
  end
end
