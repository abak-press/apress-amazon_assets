module Apress
  module AmazonAssets
    module AmazonAssetsHelper
      DEFAULT_ATTACHMENT_FIELDS_PATH = 'apress/amazon_assets/attachments_fields'.freeze
      # Public: виджет прикрепления/удаления файлов
      #
      # form    - ActionView::Helpers::FormBuilder
      # options - Hash
      #           :attachments    - массив прикреплённыx фйолов
      #           :max_size       - максимальный размер файла в МБ
      #           :max_count      - максимальное допустимое количество файлов
      #           :attach_to      - наименование модели, к которой привязываем файлы
      #           :permitted_type - набор допустимых расширений прикрепляемых файлов
      #           :path           - путь к файлу, содержащему вёрстку виджета
      #
      # Returns String
      def attachments_fields(form, options = {})
        options[:path] ||= DEFAULT_ATTACHMENT_FIELDS_PATH

        if options[:attach_to]
          file_field_index = options[:attachments] ? options[:attachments].size : 0
          options[:name_template] = "#{options[:attach_to]}[attachments_attributes][%index%][%type%]"
          options[:file_field_name] = "#{options[:attach_to]}[attachments_attributes][#{file_field_index}][local]"
        end

        options[:attaching_disabled] = options[:attachments] && options[:attachments].size == options[:max_count]

        render options[:path], form: form, options: options
      end
    end
  end
end
