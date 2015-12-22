# coding: utf-8

module Apress
  module AmazonAssets
    class CleanLocalFilesService
      # Чистка локальных файлов по дате обновления
      # scope - начальный скоуп
      # storage_time_of_local_file - время хранения локальных файлов
      def initialize(scope, storage_time_of_local_file)
        @scope = scope
        @storage_time_of_local_file = storage_time_of_local_file
      end

      def call
        @scope
          .where(
            "remote_file_name IS NOT NULL AND local_file_name IS NOT NULL AND local_updated_at < ?",
            @storage_time_of_local_file.ago.utc
          )
          .find_each do |asset|
          asset.local = nil
          asset.save(:validate => false)
        end
      end
    end
  end
end
