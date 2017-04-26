Apress::Documentation.build(:'apress-amazon_assets') do
  document(:http_api, title: 'HTTP API') do
    document(:v1, title: 'Версия 1') do
      swagger_bind do
        business_desc 'Просмотр ассета'

        publicity 'Защищенный'

        consumers 'Нет'

        tests 'В геме apress-amazon_assets'

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

            extend Swagger::DefaultResponses::Unauthenticated
            extend Swagger::DefaultResponses::NotFound
          end
        end
      end
    end
  end
end
