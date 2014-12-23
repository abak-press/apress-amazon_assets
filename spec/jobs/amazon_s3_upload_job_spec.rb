require 'spec_helper'

describe AmazonS3UploadJob do
  context 'when asset not found' do
    it { expect { described_class.execute(0, 'Apress::AmazonAssets::PrivateAsset') }.to_not raise_error }
  end

  context 'when asset found' do
    let(:asset) { Apress::AmazonAssets::PublicAsset.create }

    it { expect_any_instance_of(Apress::AmazonAssets::PublicAsset).to receive(:copy_to_remote) }

    after { described_class.execute(asset.id, 'Apress::AmazonAssets::PublicAsset') }
  end
end
