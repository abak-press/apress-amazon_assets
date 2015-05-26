# coding: utf-8
require 'active_support/concern'
require 'stringex'

module Apress
  module AmazonAssets
    module Concerns
      module BaseAsset
        extend ActiveSupport::Concern

        STORAGE_TIME_OF_LOCAL_FILE = 1.day
        STORAGE_TIME_OF_REMOTE_URL = 10.minutes

        included do
          belongs_to :attachable, polymorphic: true

          do_not_validate_attachment_file_type :local, :remote

          validate :validate_local_content_type

          validates_attachment_size :local, less_than: ->(record) { record.allowed_size },
                                            message: 'Прикреплен слишком тяжёлый файл'

          validates_attachment_size :remote, less_than: ->(record) { record.allowed_size },
                                             message: 'Прикреплен слишком тяжёлый файл'

          before_local_post_process :prepare_file_name

          after_save :store_need_upload
          after_commit :queue_upload_to_s3

          alias_method :file=, :local=
        end

        # Public: Максимальный размер загружаемых файлов.
        #
        # Returns Integer max size in bytes.
        def allowed_size
          @allowed_size ||= config_fetch(:max_size)
        end

        # Public: Список разрешенных типов загружаемых файлов.
        #
        # Returns Array of allowed content types Strings.
        def allowed_types
          @allowed_types ||= config_fetch(:content_types)
        end

        # Public: Загрузка локального файла на Amazon.
        #
        # Returns nothing.
        def copy_to_remote
          original_file = Paperclip.io_adapters.for(local)
          update_attributes! remote: original_file
        ensure
          original_file.close unless original_file.closed?
        end

        # Public: Возвращает файл, либо с амазона, либо локальный.
        #
        # remote_first - boolean (default: true).
        #
        # Returns paperclip attachment.
        def file(remote_first = true)
          if remote_first
            remote? ? remote : local
          else
            local? ? local : remote
          end
        end

        # Public: Возвращает имя файла, либо с амазона, либо локальное.
        #
        # Returns String or nil.
        def file_name
          current_file = file
          File.basename(current_file.path) if current_file && current_file.path.present?
        end

        private

        # Internal: Проектный конфиг для amazon_assets.
        #
        # Returns Hash.
        def config
          @config ||= Rails.application.config.amazon_assets.with_indifferent_access
        end

        # Internal: Извлечение опций из проектного конфига.
        # Если есть attachable_type и соответствующая секция в конфиге,
        # то опции берутся из нее, иначе из секции defaults.
        #
        # key - Symbol, ключ в конфиге.
        #
        # Returns option value.
        def config_fetch(key)
          attachable_type && config[attachable_type.underscore].try(:fetch, key, nil) || config[:defaults].fetch(key)
        end

        # Internal: Колбек для подготовки имени локального файла.
        #
        # Returns nothing.
        def prepare_file_name
          return unless local_file_name_changed?
          return if @file_name_prepared

          if remote_file_name.present?
            local.instance_write(:file_name, remote_file_name)
            @file_name_prepared = true
            return
          end

          extname = File.extname(local_file_name).force_encoding("UTF-8")
          fname = File.basename(local_file_name).chomp(extname).force_encoding("UTF-8")
          fname = fname.to_url.gsub(/[^a-zA-Z0-9_-]/, '')
          sold  = SecureRandom.hex.first(4)
          fname = "#{sold}__#{fname.presence || SecureRandom.hex.first(6)}#{extname}"

          local.instance_write(:file_name, fname)
          @file_name_prepared = true
        end

        # Internal: Флаг для after_commit колбека - нужно ли загружать на амазон.
        #
        # Returns nothing.
        def store_need_upload
          @need_upload = local_updated_at_changed?
          nil
        end

        # Internal: Колбек для постановки в очередь на загрузку на амазон.
        #
        # Returns nothing.
        def queue_upload_to_s3
          if @need_upload
            @need_upload = false
            ::AmazonS3UploadJob.enqueue(id, self.class.name)
          end
          nil
        end

        # Internal: Валидация типа локального файла.
        #
        # Returns nothing.
        def validate_local_content_type
          return if local_content_type.blank?

          if allowed_types.present? && !allowed_types.include?(local_content_type)
            [:local_content_type, :local].each { |attr| errors.add attr, 'Недопустимый формат файла' }
          end
        end
      end
    end
  end
end
