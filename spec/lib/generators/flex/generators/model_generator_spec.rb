require 'rails_helper'
require 'generators/flex/model/model_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe Flex::Generators::ModelGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new(args, options, destination_root: destination_root) }
  let(:args) { [ name ] }
  let(:options) { {} }
  let(:name) { 'TestModel' }

  before do
    FileUtils.mkdir_p("#{destination_root}/app/models")
    FileUtils.mkdir_p("#{destination_root}/db/migrate")
    allow(generator).to receive(:generate)
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "generating a model with Flex attributes" do
    let(:args) { [ "Dog", "name:name", "owner:name", "age:integer" ] }

    it "calls flex:migration generator for all attributes" do
      generator.create_migration_file
      expect(generator).to have_received(:generate).with("flex:migration", "CreateDogs", "name:name", "owner:name", "age:integer")
    end

    it "does not call active_record:migration generator" do
      generator.create_migration_file
      expect(generator).not_to have_received(:generate).with("active_record:migration", anything, anything)
    end

    it "creates model file with Flex::Attributes" do
      allow(generator).to receive(:generate).and_call_original
      allow(File).to receive(:join).and_call_original
      allow(generator).to receive(:template)

      generator.create_model_file
      expect(generator).to have_received(:template).with("model.rb.tt", "app/models/dog.rb")
    end
  end

  describe "generating a model with only regular Rails attributes" do
    let(:args) { [ "Cat", "name:string", "age:integer" ] }

    it "calls flex:migration generator for all attributes" do
      generator.create_migration_file
      expect(generator).to have_received(:generate).with("flex:migration", "CreateCats", "name:string", "age:integer")
    end

    it "does not call active_record:migration generator" do
      generator.create_migration_file
      expect(generator).not_to have_received(:generate).with("active_record:migration", anything, anything)
    end
  end

  describe "generating a model with mixed attributes" do
    let(:args) { [ "Person", "full_name:name", "email:string", "birth_date:date" ] }

    it "calls flex:migration generator for all attributes" do
      generator.create_migration_file
      expect(generator).to have_received(:generate).with("flex:migration", "CreatePeople", "full_name:name", "email:string", "birth_date:date")
    end

    it "does not call active_record:migration generator" do
      generator.create_migration_file
      expect(generator).not_to have_received(:generate).with("active_record:migration", anything, anything)
    end
  end

  describe "attribute parsing" do
    let(:args) { [ "Test", "name:name", "count:integer", "email:string" ] }

    it "handles all attributes correctly" do
      generator.create_migration_file
      expect(generator).to have_received(:generate).with("flex:migration", "CreateTests", "name:name", "count:integer", "email:string")
    end
  end
end
