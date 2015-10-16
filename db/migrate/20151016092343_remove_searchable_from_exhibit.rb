class RemoveSearchableFromExhibit < ActiveRecord::Migration
  def up
    Spotlight::Exhibit.where(searchable: false).find_each do |e|
      e.home_page.update(display_sidebar: false)
    end

    Spotlight::Exhibit.where(searchable: true).find_each do |e|
      key = e.blacklight_configuration.default_blacklight_config.default_search_field.key

      e.blacklight_configuration.search_fields[key] ||= {}
      e.blacklight_configuration.search_fields[key][:enabled] = true
    end

    remove_column :spotlight_exhibits, :searchable
  end

  def down
    add_column :spotlight_exhibits, :searchable, :boolean, default: true
  end
end
