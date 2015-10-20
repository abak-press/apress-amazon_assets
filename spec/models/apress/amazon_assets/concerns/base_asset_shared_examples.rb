# coding: utf-8
require 'fileutils'

shared_examples_for 'base asset' do |factory_name|
  subject { build factory_name }

  it { expect(subject).to belong_to(:attachable) }

  # в rails 3.1 метод respond_to? переопределен и принимает 1 аргумент, стабить не получается
  let!(:old_config) { Rails.application.config.amazon_assets }

  before do
    FileUtils.copy_file('spec/fixtures/assets/test.jpg', 'spec/fixtures/assets/картинка.jpg')
  end

  after do
    FileUtils.remove_file('spec/fixtures/assets/картинка.jpg', true)
    Rails.application.config.amazon_assets = old_config
  end

  describe 'validations' do
    context 'content type' do
      let(:png) { File.new('spec/fixtures/assets/test.png') }
      let(:jpg) { File.new('spec/fixtures/assets/test.jpg') }
      let(:txt) { File.new('spec/fixtures/assets/test.txt') }

      context 'when default content types used' do
        it { expect(subject.allowed_types).to eq %w(image/gif image/jpeg image/png) }

        context 'when allowed content type' do
          before { subject.local = png }

          it { expect(subject).to be_valid }
        end

        context 'when not allowed content type' do
          before { subject.local = txt }

          it { expect(subject).to have(1).error_on(:local_content_type) }
        end

        context 'when overridden' do
          before do
            Rails.application.config.amazon_assets = {
              defaults: {
                content_types: %w(image/png image/gif),
                max_size: 10.megabytes
              }
            }
          end

          it { expect(subject.allowed_types).to eq %w(image/png image/gif) }

          context 'when allowed content type' do
            before { subject.local = png }

            it { expect(subject).to be_valid }
          end

          context 'when not allowed content type' do
            before { subject.local = jpg }

            it { expect(subject).to have(1).error_on(:local_content_type) }
          end
        end
      end

      context 'when content types for attachable specified' do
        let(:attachable_type) { 'Foo::BarBaz' }

        before do
          allow(subject).to receive(:attachable_type).and_return attachable_type

          Rails.application.config.amazon_assets = {
            defaults: {
              content_types: %w(image/png image/jpeg image/gif),
              max_size: 10.megabytes
            },
            'foo/bar_baz' => {
              content_types: %w(application/xml text/plain),
              max_size: 10.megabytes
            }
          }
        end

        it { expect(subject.allowed_types).to eq %w(application/xml text/plain) }

        context 'when allowed content type' do
          before { subject.local = txt }

          it { expect(subject).to be_valid }
        end

        context 'when not allowed content type' do
          before { subject.local = png }

          it { expect(subject).to have(1).error_on(:local_content_type) }
        end
      end

      context 'when allowed types specified from Attachable.valid_content_types' do
        before do
          stub_const 'AttachableClass', Class.new
          AttachableClass.class_eval do
            def self.valid_content_types
              %w(text/plain)
            end
          end

          allow(subject).to receive(:attachable_type).and_return 'AttachableClass'
        end

        it { expect(subject.allowed_types).to eq %w(text/plain) }

        context 'when allowed content type' do
          before { subject.local = txt }

          it { expect(subject).to be_valid }
        end

        context 'when not allowed content type' do
          before { subject.local = png }

          it { expect(subject).to have(1).error_on(:local_content_type) }
        end

        context 'should override config option' do
          before do
            Rails.application.config.amazon_assets = {
              defaults: {
                content_types: %w(image/png image/jpeg image/gif),
                max_size: 10.megabytes
              },
              attachable: {
                content_types: %w(image/png)
              }
            }
          end

          context 'when allowed content type' do
            before { subject.local = txt }

            it { expect(subject).to be_valid }
          end

          context 'when not allowed content type' do
            before { subject.local = png }

            it { expect(subject).to have(1).error_on(:local_content_type) }
          end
        end
      end
    end

    context 'size' do
      context 'when default max size used' do
        context 'less than allowed size' do
          before do
            subject.local_file_size = 9
            subject.remote_file_size = 9
            subject.valid?
          end

          Then { expect(subject.allowed_size).to eq 10.megabytes }
          And  { expect(subject).to have(0).error_on(:local_file_size) }
          And  { expect(subject).to have(0).error_on(:remote_file_size) }
        end

        context 'equal to allowed size' do
          before do
            subject.local_file_size = 10.megabytes
            subject.remote_file_size = 10.megabytes
            subject.valid?
          end

          Then { expect(subject.allowed_size).to eq 10.megabytes }
          And  { expect(subject).to have(0).error_on(:local_file_size) }
          And  { expect(subject).to have(0).error_on(:remote_file_size) }
        end

        context 'more than allowed size' do
          before do
            subject.local_file_size = 11.megabytes
            subject.remote_file_size = 11.megabytes
            subject.valid?
          end

          Then { expect(subject.allowed_size).to eq 10.megabytes }
          And  { expect(subject).to have(1).error_on(:local_file_size) }
          And  { expect(subject).to have(1).error_on(:remote_file_size) }
        end

        context 'when overridden' do
          before do
            Rails.application.config.amazon_assets = {
              defaults: {
                content_types: %w(image/png image/jpeg image/gif),
                max_size: 100.megabytes
              }
            }
          end

          context 'less than allowed size' do
            before do
              subject.local_file_size = 99
              subject.remote_file_size = 99
              subject.valid?
            end

            Then { expect(subject.allowed_size).to eq 100.megabytes }
            And  { expect(subject).to have(0).error_on(:local_file_size) }
            And  { expect(subject).to have(0).error_on(:remote_file_size) }
          end

          context 'equal to allowed size' do
            before do
              subject.local_file_size = 100.megabytes
              subject.remote_file_size = 100.megabytes
              subject.valid?
            end

            Then { expect(subject.allowed_size).to eq 100.megabytes }
            And  { expect(subject).to have(0).error_on(:local_file_size) }
            And  { expect(subject).to have(0).error_on(:remote_file_size) }
          end

          context 'more than allowed size' do
            before do
              subject.local_file_size = 101.megabytes
              subject.remote_file_size = 101.megabytes
              subject.valid?
            end

            Then { expect(subject.allowed_size).to eq 100.megabytes }
            And  { expect(subject).to have(1).error_on(:local_file_size) }
            And  { expect(subject).to have(1).error_on(:remote_file_size) }
          end
        end
      end

      context 'when max size for attachable specified' do
        let(:attachable_type) { 'FooBarBaz' }

        before do
          allow(subject).to receive(:attachable_type).and_return attachable_type

          Rails.application.config.amazon_assets = {
            defaults: {
              content_types: %w(image/png image/jpeg image/gif),
              max_size: 100.megabytes
            },
            foo_bar_baz: {
              content_types: %w(application/xml text/plain),
              max_size: 200.megabytes
            }
          }
        end

        context 'less than allowed size' do
          before do
            subject.local_file_size = 199
            subject.remote_file_size = 199
            subject.valid?
          end

          Then { expect(subject.allowed_size).to eq 200.megabytes }
          And  { expect(subject).to have(0).error_on(:local_file_size) }
          And  { expect(subject).to have(0).error_on(:remote_file_size) }
        end

        context 'equal to allowed size' do
          before do
            subject.local_file_size = 200.megabytes
            subject.remote_file_size = 200.megabytes
            subject.valid?
          end

          Then { expect(subject.allowed_size).to eq 200.megabytes }
          And  { expect(subject).to have(0).error_on(:local_file_size) }
          And  { expect(subject).to have(0).error_on(:remote_file_size) }
        end

        context 'more than allowed size' do
          before do
            subject.local_file_size = 201.megabytes
            subject.remote_file_size = 201.megabytes
            subject.valid?
          end

          Then { expect(subject.allowed_size).to eq 200.megabytes }
          And  { expect(subject).to have(1).error_on(:local_file_size) }
          And  { expect(subject).to have(1).error_on(:remote_file_size) }
        end
      end
    end
  end

  describe 'callbacks' do
    describe '#prepare_file_name' do
      let(:file) { File.new('spec/fixtures/assets/test.txt') }

      before { subject.local = file }

      it { expect(subject.local_file_name).to match(/[0-9a-f]{4}__test\.txt/) }
      it { expect(subject.origin_file_name).to eq 'test.txt' }

      context 'when remote_file_name present' do
        subject { described_class.new remote_file_name: 'remote.txt' }

        it { expect(subject.local_file_name).to eq subject.remote_file_name }
        it { expect(subject.origin_file_name).to eq 'remote.txt' }
      end

      context 'when not allowed symbols in file name' do
        let(:file) { File.new('spec/fixtures/assets/test(123)') }

        it { expect(subject.local_file_name).to match(/[0-9a-f]{4}__test123/)  }
        it { expect(subject.origin_file_name).to eq 'test(123)' }
      end

      context 'when no allowed symbols in file name' do
        let(:file) { File.new('spec/fixtures/assets/###') }

        it { expect(subject.local_file_name).to match(/[0-9a-f]{4}__[0-9a-f]{6}/)  }
        it { expect(subject.origin_file_name).to eq '###' }
      end

      context 'when cyrilic filename' do
        let(:file) { File.new('spec/fixtures/assets/картинка.jpg') }

        it { expect(subject.local_file_name).to match(/[0-9a-f]{4}__kartinka.jpg/)  }
        it { expect(subject.origin_file_name).to eq 'картинка.jpg' }
      end

      context 'when filename has minus sign' do
        let(:file) { File.new('spec/fixtures/assets/test-test.txt') }

        it { expect(subject.local_file_name).to match(/[0-9a-f]{4}__test\-test.txt/)  }
        it { expect(subject.origin_file_name).to eq 'test-test.txt' }
      end
    end

    describe '#queue_upload_to_s3' do
      let(:file) { File.new('spec/fixtures/assets/test.png') }
      let(:upload_job) { double 'upload_job' }

      before do
        allow(upload_job).to receive(:enqueue)
        stub_const 'AmazonS3UploadJob', upload_job
      end

      context 'when local file changed' do
        before { subject.update_attributes! local: file }

        Then { expect(subject).to be_persisted }
        And  { expect(upload_job).to have_received(:enqueue).with(subject.id, described_class.name) }
      end

      context 'when local file changed to nil' do
        before { subject.update_attributes! local: nil }

        Then { expect(subject).to be_persisted }
        And  { expect(upload_job).to_not have_received(:enqueue) }
      end

      context 'when local file not changed' do
        before { subject.save! }

        Then { expect(subject).to be_persisted }
        And  { expect(upload_job).to_not have_received(:enqueue) }
      end
    end
  end

  describe '#copy_to_remote' do
    let(:file) { File.new('spec/fixtures/assets/test.png') }

    before do
      subject.local = file
      subject.save

      allow_any_instance_of(described_class).to receive(:queue_upload_to_s3)

      VCR.use_cassette 'copy_to_remote', erb: {path: subject.local.url.sub(%r{.*/system/}, '')} do
        subject.copy_to_remote
      end
    end

    Then { expect(subject.remote).to be_present }
    And  { expect(subject.remote_file_name).to eq subject.local_file_name }
    And  { expect(subject.remote_file_size).to eq subject.local_file_size }
    And  { expect(subject.remote_content_type).to eq subject.local_content_type }
  end

  describe '#file' do
    let(:file) { File.new('spec/fixtures/assets/test.png') }

    before do
      subject.local = file
      subject.remote = file
    end

    Then { expect(subject.file).to eq subject.remote }
    And  { expect(subject.file false).to eq subject.local }
  end

  describe '#file_name' do
    let(:file) { File.new('spec/fixtures/assets/test.png') }

    before do
      subject.save
      subject.local = file
      subject.remote = file
    end

    it { expect(subject.file_name).to eq subject.remote_file_name }
  end
end

