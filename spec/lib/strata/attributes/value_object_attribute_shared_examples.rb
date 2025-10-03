# frozen_string_literal: true

RSpec.shared_examples "value object shared examples" do |
    attribute_module,
    value_class,
    attribute,
    valid_nested_attributes:,
    invalid_value: nil,
    nested_attributes_without_normalization: nil,
    array_values: []
  |
  let(:object) { TestRecord.new }
  valid_nested_attributes.each do |attr, value|
    let(attr) { value }
  end

  it "allows setting #{attribute} as nil" do
    object.public_send("#{attribute}=", nil)
    expect(object.public_send(attribute)).to be_nil
  end

  it "allows setting #{attribute} as a value object" do
    value_object = value_class.new(**valid_nested_attributes)
    object.public_send("#{attribute}=", value_object)

    expect(object.public_send(attribute)).to eq(value_class.new(**valid_nested_attributes))

    if attribute_module.attribute_type == :multi_column_value_object
      valid_nested_attributes.each do |nested_attribute, value|
        expect(object.public_send("#{attribute}_#{nested_attribute}")).to eq(value)
      end
    end
  end

  it "allows setting #{attribute} as a hash" do
    object.public_send("#{attribute}=", valid_nested_attributes)

    expect(object.public_send(attribute)).to eq(value_class.new(**valid_nested_attributes))

    if attribute_module.attribute_type == :multi_column_value_object
      valid_nested_attributes.each do |nested_attribute, value|
        expect(object.public_send("#{attribute}_#{nested_attribute}")).to eq(value)
      end
    end
  end

  if attribute_module.attribute_type == :multi_column_value_object
    it "allows setting nested #{attribute} attributes directly" do
      valid_nested_attributes.each do |attr, value|
        object.public_send("#{attribute}_#{attr}=", value)
      end
      expect(object.public_send(attribute)).to eq(value_class.new(**valid_nested_attributes))
    end
  end

  if nested_attributes_without_normalization.present?
    it "preserves values exactly as entered without normalization" do
      object.public_send("#{attribute}=", nested_attributes_without_normalization)

      expect(object.public_send(attribute)).to eq(value_class.new(**nested_attributes_without_normalization))

      if attribute_module.attribute_type == :multi_column_value_object
        nested_attributes_without_normalization.each do |nested_attribute, value|
          expect(object.public_send("#{attribute}_#{nested_attribute}")).to eq(value)
        end
      end
    end
  end

  it "persists and loads #{attribute} object correctly" do
    value_object = value_class.new(**valid_nested_attributes)
    object.public_send("#{attribute}=", value_object)
    object.save!

    loaded_record = TestRecord.find(object.id)
    expect(loaded_record.public_send(attribute)).to be_a(value_class)
    expect(loaded_record.public_send(attribute)).to eq(value_object)

    if attribute_module.attribute_type == :multi_column_value_object
      valid_nested_attributes.each do |nested_attribute, value|
        expect(loaded_record.public_send("#{attribute}_#{nested_attribute}")).to eq(value)
      end
    end
  end

  if array_values.present?
    describe "array: true" do
      attribute_pluralized = "#{attribute.to_s.pluralize}"

      it "allows setting an array of #{attribute_pluralized}" do
        object.public_send("#{attribute_pluralized}=", array_values)

        expect(object.public_send(attribute_pluralized)).to be_an(Array)
        expect(object.public_send(attribute_pluralized).size).to eq(array_values.size)
        expect(object.public_send(attribute_pluralized)).to eq(array_values)
        array_values.each_with_index do |value, index|
          expect(object.public_send(attribute_pluralized)[index]).to be_a(value_class)
          expect(object.public_send(attribute_pluralized)[index]).to eq(value)
        end
      end

      if invalid_value.present?
        it "validates each #{attribute} in the array" do
          object.public_send("#{attribute_pluralized}=", [ invalid_value, *array_values ])

          expect(object).not_to be_valid
          expect(object.errors[attribute_pluralized.to_sym]).to include("contains one or more invalid items")
        end
      end

      it "persists and loads arrays of value objects" do
        object.public_send("#{attribute_pluralized}=", array_values)

        object.save!
        loaded_record = TestRecord.find(object.id)

        expect(loaded_record.public_send(attribute_pluralized)).to be_an(Array)
        expect(loaded_record.public_send(attribute_pluralized).size).to eq(array_values.size)
        expect(loaded_record.public_send(attribute_pluralized)).to eq(array_values)
        array_values.each_with_index do |value, index|
          expect(loaded_record.public_send(attribute_pluralized)[index]).to be_a(value_class)
          expect(loaded_record.public_send(attribute_pluralized)[index]).to eq(value)
        end
      end
    end
  end
end
