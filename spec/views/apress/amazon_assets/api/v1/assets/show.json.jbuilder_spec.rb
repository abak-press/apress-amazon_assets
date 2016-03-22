require 'spec_helper'

RSpec.describe 'apress/amazon_assets/api/v1/assets/show.json.jbuilder', type: :view do
  let(:schema) do
    {
      type: 'object',
      required: %w(asset),
      properties: {
        asset: {
          type: 'object',
          required: %w(
            id
            file
            origin_file_name
            file_size
            file_content_type
          ),
          id: {type: 'integer'},
          file: {type: 'string'},
          origin_file_name: {type: 'string'},
          file_size: {type: 'integer'},
          file_content_type: {type: 'string'}
        }
      }
    }.with_indifferent_access
  end

  let(:asset) { create(:public_asset) }

  before do
    assign(:asset, asset)
    render template: "apress/amazon_assets/api/v1/assets/show", formats: :json, hander: :jbuilder
  end

  it 'renders json schema' do
    expect(rendered).to match_json_schema(schema)
  end
end
