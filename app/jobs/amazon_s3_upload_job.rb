# coding: utf-8
require 'resque-integration'

class AmazonS3UploadJob
  include Resque::Integration

  queue :upload
  unique { |id, class_name| [id, class_name] }

  # Запуск загрузки на амазон
  #
  # id         - Integer
  # class_name - String
  #
  # Returns nothing
  def self.execute(id, class_name)
    asset = class_name.constantize.find(id)
    file = asset.local.to_file(:original)
    asset.remote = file
    asset.save!
  ensure
    if defined?(file) && file && file.respond_to?(:close)
      file.close
    end
  end
end
