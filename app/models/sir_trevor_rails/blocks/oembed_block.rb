module SirTrevorRails::Blocks
  class OembedBlock < SirTrevorRails::Block

    def text_align
      as_json[:data].find { |k,v| k =~ /text-align/ }.try(:last)
    end
  end
end