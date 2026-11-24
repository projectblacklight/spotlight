# frozen_string_literal: true

require 'rake'

namespace :spotlight_test do
  namespace :solr do
    desc 'Index test data into solr; must be run from within an app (see spotlight:fixtures)'
    task seed: [:environment] do
      docs = YAML.safe_load(File.open(File.expand_path(File.join('..', 'spec', 'fixtures', 'sample_solr_documents.yml'), Rails.root)))
      Blacklight.default_index.connection.add docs
      Blacklight.default_index.connection.commit
    end
  end

  desc 'Create a sample exhibit for development; run spotlight_test:solr:seed first'
  task seed_exhibit: [:environment] do
    exhibit = Spotlight::Exhibit.find_or_create_by!(slug: 'sample') do |e|
      e.title = 'Sample Exhibit'
      e.subtitle = 'Maps of the world'
      e.description = 'A sample exhibit for development.'
    end
    exhibit.update!(published: true)

    masthead = exhibit.masthead || exhibit.build_masthead
    masthead.update!(display: true,
                     iiif_tilesource: 'https://stacks.stanford.edu/image/iiif/jr961xz9944%2Fjr961xz9944_05_0001/info.json')
    exhibit.update!(masthead:)

    items = %w[gk446cj2442 jr961xz9944 rc221bv1386 sp821gh4463].each_with_index.to_h do |id, i|
      ["item_#{i}", { id:, display: 'true' }]
    end
    caption = { 'show-primary-caption' => 'true', 'primary-caption-field' => 'full_title_tesim' }
    intro = '<p>Welcome to the sample exhibit. These maps span several centuries.</p>'
    text_block = { type: 'text', data: { title: 'Introduction', text: intro, format: 'html' } }
    items_block = { type: 'solr_documents', data: { title: 'Featured maps', item: items, format: 'html', **caption } }
    features_block = { type: 'solr_documents_features', data: { title: 'Item features', item: items, format: 'html', **caption } }

    search = exhibit.searches.find_or_create_by!(slug: 'world-maps') do |s|
      s.title = 'World maps'
      s.query_params = { q: 'world' }
    end
    search.update!(published: true)
    browse_items = { 'item_0' => { id: search.slug, display: 'true' } }
    browse_block = { type: 'browse', data: { title: 'Browse', item: browse_items, 'display-item-counts' => 'true', format: 'html' } }

    exhibit.home_page.update!(content: { data: [text_block, browse_block] }.to_json, display_sidebar: true)

    feature = exhibit.feature_pages.find_or_create_by!(slug: 'featured-maps') { |p| p.title = 'Featured maps' }
    feature.update!(content: { data: [text_block, items_block, features_block] }.to_json, published: true, display_sidebar: true)

    about = exhibit.about_pages.find_or_create_by!(slug: 'about') { |p| p.title = 'About this exhibit' }
    about.update!(content: { data: [text_block] }.to_json, published: true)

    SolrDocument.find('gk446cj2442').tap do |doc|
      doc.update(exhibit, { 'exhibit_tag_list' => 'maps, world, sample tag' })
      doc.save
    end

    SolrDocument.find('jr961xz9944').tap do |doc|
      doc.update(exhibit, { 'sidecar' => { 'public' => false } })
      doc.save
    end
    Blacklight.default_index.connection.commit

    unless exhibit.contact_emails.exists?(email: 'exhibit_contact@example.com')
      contact_email = exhibit.contact_emails.build(email: 'exhibit_contact@example.com')
      contact_email.skip_confirmation!
      contact_email.save!
    end
  end
end
