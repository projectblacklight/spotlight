module Spotlight
  class Attachment < ActiveRecord::Base
    mount_uploader :file, AttachmentUploader

    def as_json(options = nil)
      file.as_json(options).merge(:name => name, :uid => uid, :id => id, :class => self.class.to_s)
    end
  end
end
