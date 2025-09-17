require "rails_helper"

RSpec.describe Flex::Attributes::DocumentAttribute do
  include ActiveJob::TestHelper
  let(:test_file) { Rack::Test::UploadedFile.new(File.expand_path("../../../fixtures/files/test.txt", __dir__), "text/plain") }
  let(:test_image) { Rack::Test::UploadedFile.new(File.expand_path("../../../fixtures/files/test.jpg", __dir__), "image/jpeg") }

  should_setup_active_storage = !ActiveRecord::Base.connection.table_exists?(:active_storage_blobs) ||
                                  !ActiveRecord::Base.connection.table_exists?(:active_storage_attachments) ||
                                  !ActiveRecord::Base.connection.table_exists?(:active_storage_variant_records)

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    # Create ActiveStorage tables

    if should_setup_active_storage
      ActiveRecord::Base.connection.create_table :active_storage_blobs, force: true do |t|
        t.string   :key,          null: false
        t.string   :filename,     null: false
        t.string   :content_type
        t.text     :metadata
        t.string   :service_name, null: false
        t.bigint   :byte_size,   null: false
        t.string   :checksum,    null: false

        t.timestamps

        t.index [ :key ], unique: true
      end

      ActiveRecord::Base.connection.create_table :active_storage_attachments, force: true do |t|
        t.string     :name,     null: false
        t.references :record,   null: false, polymorphic: true, index: false
        t.references :blob,     null: false

        t.timestamps

        t.index [ :record_type, :record_id, :name, :blob_id ], name: "index_active_storage_attachments_uniqueness", unique: true
      end

      ActiveRecord::Base.connection.create_table :active_storage_variant_records, force: true do |t|
        t.belongs_to :blob, null: false, index: false
        t.string :variation_digest, null: false

        t.index %i[ blob_id variation_digest ], name: "index_active_storage_variant_records_uniqueness", unique: true
      end
    end

    ActiveRecord::Base.connection.create_table :test_models, force: true do |t|
      t.timestamps
    end

    class TestModel < ApplicationRecord # rubocop:disable RSpec/LeakyConstantDeclaration
      include Flex::Attributes
      flex_attribute :documents, :document
      flex_attribute :profile_pictures, :document
    end
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    ActiveRecord::Base.connection.drop_table :test_models
    if should_setup_active_storage
      ActiveRecord::Base.connection.drop_table :active_storage_variant_records
      ActiveRecord::Base.connection.drop_table :active_storage_attachments
      ActiveRecord::Base.connection.drop_table :active_storage_blobs
    end
    Object.send(:remove_const, :TestModel) # rubocop:disable RSpec/RemoveConst
  end

  after do
    model.documents.purge
    model.profile_pictures.purge
  end

  let(:model) { TestModel.new } # rubocop:disable RSpec/ScatteredLet

  describe "attachment handling" do
    it "allows attaching single files" do
      model.documents.attach(test_file)
      model.profile_pictures.attach(test_image)

      expect(model.documents).to be_attached
      expect(model.documents.count).to eq(1)
      expect(model.documents.first.filename.to_s).to eq("test.txt")
      expect(model.documents.first.content_type).to eq("text/plain")

      expect(model.profile_pictures).to be_attached
      expect(model.profile_pictures.count).to eq(1)
      expect(model.profile_pictures.first.filename.to_s).to eq("test.jpg")
      expect(model.profile_pictures.first.content_type).to eq("image/jpeg")
    end

    it "allows attaching multiple files" do
      model.documents.attach([ test_file, test_image ])
      model.profile_pictures.attach([ test_image, test_file ])

      expect(model.documents).to be_attached
      expect(model.documents.count).to eq(2)
      expect(model.documents.first.content_type).to eq("text/plain")
      expect(model.documents.last.content_type).to eq("image/jpeg")

      expect(model.profile_pictures).to be_attached
      expect(model.profile_pictures.count).to eq(2)
      expect(model.profile_pictures.first.content_type).to eq("image/jpeg")
      expect(model.profile_pictures.last.content_type).to eq("text/plain")
    end

    it "supports multiple document attributes on the same model" do
      model.documents.attach(test_file)
      model.profile_pictures.attach(test_image)

      expect(model.documents).to be_attached
      expect(model.profile_pictures).to be_attached
      expect(model.documents.first.content_type).to eq("text/plain")
      expect(model.profile_pictures.first.content_type).to eq("image/jpeg")
    end
  end

  describe "file operations" do
    before do
      model.documents.attach(test_file)
      model.profile_pictures.attach(test_image)
    end

    it "allows purging attached files" do
      model.documents.purge
      model.profile_pictures.purge

      expect(model.documents).not_to be_attached
      expect(model.profile_pictures).not_to be_attached
    end

    it "provides access to blob attributes" do
      blob = model.documents.first.blob

      expect(blob).to respond_to(:byte_size)
      expect(blob).to respond_to(:checksum)
      expect(blob).to respond_to(:content_type)
      expect(blob).to respond_to(:filename)
    end
  end

  describe "persistence" do
    it "persists attached files" do
      model.documents.attach(test_file)
      model.profile_pictures.attach(test_image)
      model.save!

      reloaded_model = TestModel.find(model.id)
      expect(reloaded_model.documents).to be_attached
      expect(reloaded_model.documents.first.filename.to_s).to eq("test.txt")

      expect(reloaded_model.profile_pictures).to be_attached
      expect(reloaded_model.profile_pictures.first.filename.to_s).to eq("test.jpg")
    end

    it "allows replacing attached files" do
      model.documents.attach(test_file)
      model.save!

      model.documents.purge # Need to purge first to replace
      model.documents.attach(test_image)
      model.save!

      reloaded_model = TestModel.find(model.id)
      expect(reloaded_model.documents.count).to eq(1)
      expect(reloaded_model.documents.first.content_type).to eq("image/jpeg")
    end
  end

  describe "error handling" do
    it "handles attempting to attach to an unsaved record" do
      expect { model.documents.attach(test_file) }.not_to raise_error
      expect { model.profile_pictures.attach(test_image) }.not_to raise_error
    end

    it "handles invalid attachments" do
      expect { model.documents.attach(Object.new) }.to raise_error(ArgumentError, /Could not find or build blob/)
    end
  end
end
