require 'rails_helper'

RSpec.describe Flex::ModelGenerator, type: :generator do
  destination File.expand_path("../../../dummy", __dir__)

  before do
    prepare_destination
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "generating a model with Flex attributes" do
    before do
      run_generator [ "Dog", "name:name", "owner:name", "age:integer" ]
    end

    it "creates a model file with Flex::Attributes included" do
      expect(file("app/models/dog.rb")).to exist
      expect(file("app/models/dog.rb")).to contain("include Flex::Attributes")
      expect(file("app/models/dog.rb")).to contain("flex_attribute :name, :name")
      expect(file("app/models/dog.rb")).to contain("flex_attribute :owner, :name")
    end

    it "generates Flex migration for name attributes" do
      migration_files = Dir.glob(File.join(destination_root, "db/migrate/*create_dogs*.rb"))
      expect(migration_files).not_to be_empty

      migration_content = File.read(migration_files.first)
      expect(migration_content).to include("t.string :name_first")
      expect(migration_content).to include("t.string :name_middle")
      expect(migration_content).to include("t.string :name_last")
      expect(migration_content).to include("t.string :owner_first")
      expect(migration_content).to include("t.string :owner_middle")
      expect(migration_content).to include("t.string :owner_last")
    end
  end

  describe "generating a model with only regular Rails attributes" do
    before do
      run_generator [ "Cat", "name:string", "age:integer" ]
    end

    it "creates a model file without Flex::Attributes" do
      expect(file("app/models/cat.rb")).to exist
      expect(file("app/models/cat.rb")).not_to contain("include Flex::Attributes")
      expect(file("app/models/cat.rb")).not_to contain("flex_attribute")
    end
  end

  describe "generating a model with mixed attributes" do
    before do
      run_generator [ "Person", "full_name:name", "email:string", "birth_date:date" ]
    end

    it "creates a model file with Flex::Attributes for name attributes only" do
      expect(file("app/models/person.rb")).to exist
      expect(file("app/models/person.rb")).to contain("include Flex::Attributes")
      expect(file("app/models/person.rb")).to contain("flex_attribute :full_name, :name")
      expect(file("app/models/person.rb")).not_to contain("flex_attribute :email")
      expect(file("app/models/person.rb")).not_to contain("flex_attribute :birth_date")
    end
  end
end
