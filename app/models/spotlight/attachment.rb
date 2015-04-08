module Spotlight
  ##
  # Sir-trevor image upload attachments
  class Attachment < ActiveRecord::Base
    belongs_to :exhibit
    mount_uploader :file, Spotlight::AttachmentUploader

    def as_json(options = nil)
      file.as_json(options).merge(name: name, uid: uid, id: id, class: self.class.to_s)
    end
  end
end
