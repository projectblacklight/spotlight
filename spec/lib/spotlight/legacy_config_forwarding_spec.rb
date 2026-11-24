# frozen_string_literal: true

RSpec.describe Spotlight::LegacyConfigForwarding do
  let(:config) { Spotlight::Engine.config }

  around do |example|
    original = config.spotlight.solr_batch_size
    example.run
  ensure
    config.spotlight.solr_batch_size = original
  end

  before do
    allow(Spotlight.deprecator).to receive(:warn)
  end

  it 'forwards reads of known settings to config.spotlight with a deprecation warning' do
    expect(config.solr_batch_size).to eq config.spotlight.solr_batch_size
    expect(Spotlight.deprecator).to have_received(:warn).with(/config\.solr_batch_size is deprecated.*config\.spotlight\.solr_batch_size/)
  end

  it 'forwards writes of known settings to config.spotlight with a deprecation warning' do
    config.solr_batch_size = 7

    expect(config.spotlight.solr_batch_size).to eq 7
    expect(Spotlight.deprecator).to have_received(:warn).with(/config\.solr_batch_size is deprecated/)
  end

  it 'forwards settings whose default is nil' do
    expect(config).to respond_to(:default_blacklight_config)
    expect(config).to respond_to(:default_blacklight_config=)
  end

  it 'does not forward unknown settings' do
    expect(config).not_to respond_to(:not_a_spotlight_setting)
    expect { config.not_a_spotlight_setting }.to raise_error(NoMethodError)
    expect(Spotlight.deprecator).not_to have_received(:warn)
  end

  it 'does not interfere with real configuration methods' do
    expect(config.root).to eq Spotlight::Engine.root
    expect(Spotlight.deprecator).not_to have_received(:warn)
  end
end
