module Swagger
  module V1
    module Models
      module Apress
        module AmazonAssets
          class Asset < ::Apress::Documentation::Swagger::Schema
            swagger_schema name.to_sym do
              property :id, type: :integer, format: :int64 do
                key :description, 'ИД ассета'
              end

              property :file, type: :string do
                key :description, 'URL фаила'
                key :example, 'http://s3.amazonaws.com/pulscen_development/public_assets/000/000/185/1.jpg'
              end

              property :origin_file_name, type: :string do
                key :description, 'Настоящее имя фаила'
                key :example, '1.jpg'
              end

              property :file_size, type: :integer do
                key :description, 'Размер фаила'
                key :example, 1111
              end

              property :file_content_type, type: :string do
                key :description, 'Тип фаила'
                key :example, 'image/jpeg'
              end
            end
          end
        end
      end
    end
  end
end
