# coding: utf-8
require 'spec_helper'

RSpec.describe Apress::AmazonAssets::CleanPrivateAssetsJob do
  describe '.perform' do
    before do
      allow(Apress::AmazonAssets::CleanLocalFilesService).to receive_message_chain(:new, :call)
    end

    it do
      expect(Apress::AmazonAssets::CleanLocalFilesService).to receive(:new).with(
        Apress::AmazonAssets::PrivateAsset,
        Apress::AmazonAssets::PrivateAsset::STORAGE_TIME_OF_LOCAL_FILE
      )

      described_class.perform
    end
  end
end
