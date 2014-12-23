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
    asset = class_name.constantize.where(id: id).first
    unless asset
      puts "#{class_name} with id #{id} not found. Skiping."
      return
    end

    asset.copy_to_remote
  end
end
