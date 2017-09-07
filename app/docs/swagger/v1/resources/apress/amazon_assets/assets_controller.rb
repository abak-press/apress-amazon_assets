module Swagger
  module V1
    module Resources
      module Apress
        module AmazonAssets
          class AssetsController < ::Apress::Documentation::Swagger::Schema
            swagger_path('/asssets/{id}') do
              operation :get do
                key :produces, ['application/json']

                key :description,
                    "-" \
                    "<h4>Allowed user roles:</h4> User."
                key :operationId, 'asssetShow'
                key :tags, ['amazon_assets']

                parameter do
                  key :name, :id
                  key :in, :path
                  key :description, "ИД ассета"
                  key :type, :integer
                  key :format, :int64
                end

                response 200 do
                  key :description, 'Success response'
                  schema type: 'object' do
                    property :asset do
                      key :'$ref', :'Swagger::V1::Models::Apress::AmazonAssets::Asset'
                    end
                  end
                end

                extend Swagger::V1::DefaultResponses::Unauthenticated
                extend Swagger::V1::DefaultResponses::NotFound
              end
            end
          end
        end
      end
    end
  end
end
