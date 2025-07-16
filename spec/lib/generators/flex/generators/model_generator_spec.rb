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

    it "calls flex:migration generator for Flex attributes" do
      generator.create_migration_file
      expect(generator).to have_received(:generate).with("flex:migration", "CreateDogs", "name:name", "owner:name")
    end

    it "calls active_record:migration generator for regular attributes" do
      generator.create_migration_file
      expect(generator).to have_received(:generate).with("active_record:migration", "CreateDogs", "age:integer")
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

    it "does not call flex:migration generator" do
      generator.create_migration_file
      expect(generator).not_to have_received(:generate).with(anything, anything, /name:name/)
    end

    it "calls active_record:migration generator for all attributes" do
      generator.create_migration_file
      expect(generator).to have_received(:generate).with("active_record:migration", "CreateCats", "name:string", "age:integer")
    end
  end

  describe "generating a model with mixed attributes" do
    let(:args) { [ "Person", "full_name:name", "email:string", "birth_date:date" ] }

    it "separates Flex and Rails attributes correctly" do
      generator.create_migration_file
      expect(generator).to have_received(:generate).with("flex:migration", "CreatePeople", "full_name:name")
      expect(generator).to have_received(:generate).with("active_record:migration", "CreatePeople", "email:string", "birth_date:date")
    end
  end

  describe "attribute parsing" do
    let(:args) { [ "Test", "name:name", "count:integer", "email:string" ] }

    it "handles regular Rails attributes correctly" do
      generator.create_migration_file
      expect(generator).to have_received(:generate).with("active_record:migration", "CreateTests", "count:integer", "email:string")
    end
  end
end
