# coding: utf-8
require 'spec_helper'

RSpec.describe Apress::AmazonAssets::AmazonAssetsHelper, type: :helper do
  describe '#attachments_fields' do
    let(:form) { double(ActionView::Helpers::FormBuilder) }

    let(:options) { {attachments: [], max_size: 0, max_count: 0, attach_to: nil, permitted_type: []} }

    it do
      expect(helper).to receive(:render).with(
        described_class::DEFAULT_ATTACHMENT_FIELDS_PATH, form: form, options: options
      )
      helper.attachments_fields(form, options)
    end
  end
end
