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
          belongs_to :attachable, :polymorphic => true

          validate :validate_content_type

          # TODO: после обновления пэперклипа на >= 3 можно заменить на
          # validates_attachment_size :local,
          #   :less_than => -> (record) { record.allowed_size },
          #   :message => "Прикреплен слишком тяжёлый файл"

          validates :local_file_size,
                    :allow_nil => true,
                    :inclusion => {
                      :in => proc { |record| 0..record.allowed_size },
                      :message => "Прикреплен слишком тяжёлый файл"
                    }

          validates :remote_file_size,
                    :allow_nil => true,
                    :inclusion => {
                      :in => proc { |record| 0..record.allowed_size },
                      :message => "Прикреплен слишком тяжёлый файл"
                    }

          before_local_post_process :prepare_file_name

          after_save :store_need_upload
          after_commit :queue_upload_to_s3

          alias_method :file=, :local=
        end

        # Copy local file to amazon
        #
        # Returns nothing
        def copy_to_remote
          original_file = local.to_file(:original)
          self.remote = original_file
          save!
        ensure
          if original_file && original_file.respond_to?(:close)
            original_file.close
          end
        end

        # Подготовим имя файла
        #
        # Returns nothing
        def prepare_file_name
          return unless local_file_name_changed?
          return if @file_name_prepared

          if remote_file_name.present?
            self.origin_file_name = remote_file_name
            local.instance_write(:file_name, remote_file_name)
            @file_name_prepared = true
            return
          end

          extname = File.extname(local_file_name).force_encoding("UTF-8")
          fname = File.basename(local_file_name).chomp(extname).force_encoding("UTF-8")
          fname = fname.gsub(/[^[:word:]-]/, '').to_url
          sold  = SecureRandom.hex.first(4)
          fname = "#{sold}__#{fname.presence || SecureRandom.hex.first(6)}#{extname}"

          self.origin_file_name = local_file_name
          local.instance_write(:file_name, fname)
          @file_name_prepared = true
        end

        # Установим имя файла
        #
        # file_name - String
        #
        # Returns String
        def set_file_name(file_name)
          self.remote_file_name = file_name
        end

        # Запомним для after_commit нужно ли загружать на амазон
        #
        # Returns nothing
        def store_need_upload
          @need_upload = local_updated_at_changed? && local?
          nil
        end

        # Поставить в очередь на загрузку на амазон
        #
        # Returns nothing
        def queue_upload_to_s3
          if @need_upload
            @need_upload = false
            ::AmazonS3UploadJob.enqueue(id, self.class.name)
          end

          nil
        end

        # Возвращает файл либо локальный либо с амазона
        #
        # remote_first - boolean (default: true)
        #
        # Returns paperclip attachment
        def file(remote_first = true)
          if remote_first
            remote? ? remote : local
          else
            local? ? local : remote
          end
        end

        def file_name
          _file = file
          File.basename(_file.path) if _file.present? && _file.path.present?
        end

        def validate_content_type
          type_is_allowed = allowed_types.any? { |t| t === local_content_type }

          if !type_is_allowed && !(local_content_type.nil? || local_content_type.blank?)
            if errors.method(:add).arity == -2
              errors.add(:local_content_type, "Недопустимый формат файла")
            else
              errors.add(
                :local_content_type,
                :inclusion,
                :default => "Недопустимый формат файла",
                :value => local_content_type
              )
            end
          end
        end

        # Public: Список разрешенных типов загружаемых файлов.
        #
        # Returns Array of allowed content types Strings.
        # TODO: до перехода на конфиги, чтобы не ломать существующий код оставлена старая логика
        def allowed_types
          return @allowed_types if defined?(@allowed_types)

          assoc_method = :valid_content_types

          # проверяем непосредственно аттач, либо объект класса аттача (в таком порядке)
          # у кого первого есть метод valid_content_types, "тот и папа"
          entry =
            [attachable, (attachable_type.constantize if attachable_type.present? rescue nil)].
              select { |assoc_or_class| assoc_or_class.respond_to?(assoc_method) }.
              compact.
              first

          @allowed_types = entry ? entry.send(assoc_method) : config_fetch(:content_types)
        end

        # Public: Максимальный размер загружаемых файлов.
        #
        # Returns Integer max size in bytes.
        def allowed_size
          @allowed_size ||= config_fetch(:max_size)
        end

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
      end
    end
  end
end
