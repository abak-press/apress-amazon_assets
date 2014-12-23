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
        MAX_FILE_SIZE = 10.megabytes

        included do
          belongs_to :attachable, :polymorphic => true

          validate :validate_content_type
          validates_attachment_size :local, :less_than => MAX_FILE_SIZE, :message => "Прикреплен слишком тяжёлый файл"
          validates_attachment_size :remote, :less_than => MAX_FILE_SIZE, :message => "Прикреплен слишком тяжёлый файл"

          before_local_post_process :prepare_file_name
          after_save :store_need_upload
          after_commit :queue_upload_to_s3, :if => :local_updated_at_changed?

          alias_method :file=, :local=
        end

        module InstanceMethods
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
            @need_upload = local_updated_at_changed?
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
            if !allowed_types.any? { |t| t === local_content_type } && !(local_content_type.nil? || local_content_type.blank?)
              if errors.method(:add).arity == -2
                errors.add(:local_content_type, "Недопустимый формат файла")
              else
                errors.add(:local_content_type, :inclusion, :default => "Недопустимый формат файла", :value => local_content_type)
              end
            end
          end

          def allowed_types
            return @allowed_types if defined?(@allowed_types)

            assoc_method = :valid_content_types

            # проверяем непосредственно аттач, либо объект класса аттача (в таком порядке)
            # у кого первого есть метод valid_content_types, "тот и папа"
            entry =
              [attachable,
               (attachable_type.constantize if attachable_type.present? rescue
                 nil)
              ].select { |assoc_or_class|
                assoc_or_class.respond_to?(assoc_method)
              }.
                compact.
                first

            @allowed_types = entry ? entry.send(assoc_method) : []
          end
        end
      end
    end
  end
end