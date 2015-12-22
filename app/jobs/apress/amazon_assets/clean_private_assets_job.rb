# coding: utf-8

module Apress
  module AmazonAssets
    class CleanPrivateAssetsJob
      include Resque::Integration

      unique

      def self.execute
        CleanLocalFilesService.new(PrivateAsset, PrivateAsset::STORAGE_TIME_OF_LOCAL_FILE).call
      end
    end
  end
end
