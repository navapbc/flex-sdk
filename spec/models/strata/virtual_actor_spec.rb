# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::VirtualActor do
  describe 'as a marker module' do
    let(:virtual_class) do
      Class.new do
        include Strata::VirtualActor
      end
    end

    it 'is includable in any class without requiring methods' do
      expect(virtual_class.include?(described_class)).to be true
    end

    it 'adds no instance methods to the including class' do
      original_methods = Class.new.instance_methods
      expect(virtual_class.instance_methods - original_methods).to be_empty
    end
  end

  describe Strata::VirtualActor::Instance do
    subject(:instance) { described_class.new(actor_type: 'Api::Client') }

    describe '#actor_type' do
      it 'returns the type string passed in' do
        expect(instance.actor_type).to eq('Api::Client')
      end
    end

    describe '#display_name' do
      it 'demodulizes and humanizes the type' do
        expect(instance.display_name).to eq('Client')
      end

      it 'humanizes a snake_case suffix' do
        other = described_class.new(actor_type: 'Cron::DailyWorker')
        expect(other.display_name).to eq('Daily worker')
      end
    end

    describe '#==' do
      it 'is equal to another Instance with the same actor_type' do
        other = described_class.new(actor_type: 'Api::Client')
        expect(instance).to eq(other)
      end

      it 'is not equal to an Instance with a different actor_type' do
        other = described_class.new(actor_type: 'Cron::Worker')
        expect(instance).not_to eq(other)
      end

      it 'is not equal to an arbitrary object with a matching actor_type method' do
        impostor = Struct.new(:actor_type).new('Api::Client')
        expect(instance).not_to eq(impostor)
      end
    end

    describe '#persisted?' do
      it 'is false (it has no DB row)' do
        expect(instance.persisted?).to be false
      end
    end
  end
end
