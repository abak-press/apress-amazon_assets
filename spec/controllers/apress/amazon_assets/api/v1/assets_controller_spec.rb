require 'spec_helper'

describe Apress::AmazonAssets::Api::V1::AssetsController, type: :controller do
  describe '#show' do
    before do
      allow(controller).to receive(:authenticate)
    end

    context 'when asest id present' do
      let(:asset) { create :public_asset }
      it 'returns 200' do
        get :show, format: :json, id: asset.id

        expect(response.status).to eq 200
      end
    end

    context 'when asest id does not exists' do
      let(:asset) { create :public_asset }
      it 'returns 404' do
        get :show, format: :json, id: -1

        expect(response.status).to eq 404
      end
    end
  end
end
