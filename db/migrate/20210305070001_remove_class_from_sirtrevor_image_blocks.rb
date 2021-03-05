# frozen_string_literal: true

# Remove the class field from the block; ostruct 0.3 helpfully allows it to override
# this field and that confuses sir trevor..
class RemoveClassFromSirtrevorImageBlocks < ActiveRecord::Migration[5.2]
  def up
    Spotlight::Page.reset_column_information
    image = SirTrevorRails::Block.block_class('image')

    Spotlight::Page.find_each do |page|
      next unless page.content.any? { |block| block.is_a? image }
      page.content.select { |block| block.is_a?(image) && block.respond_to?(:class=) }.each do |block|
        block.delete_field(:class)
        block.attachment = Spotlight::Attachment.find(block.id).to_global_id rescue nil
      end

      page.update(content: page.content)
    end
  end
end
