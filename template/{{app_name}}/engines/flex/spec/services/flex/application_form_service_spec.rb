require 'rails_helper'

module Flex
  RSpec.describe ApplicationFormService do
    let(:repository) { instance_double('Repository') }
    let(:service) { described_class.new(repository: repository) }

    [nil, false, ''].each do |id|
      it "raises an error if the given id is falsy (#{id.inspect})" do
        expect { service.update_form(id, {}) }.to raise_error(ArgumentError)
      end
    end

    [nil, {}, false].each do |params|
      it "raises an error if params are not provided (#{params.inspect})" do
        expect { service.update_form(1, params) }.to raise_error(ArgumentError)
      end
    end

    it "raises an error if the application form is already submitted" do
      params = { status: ApplicationForm.statuses[:submitted] }
      id = rand(1..1000)
      
      allow(repository).to receive(:find_fields)
        .with(id, ['status'])
        .and_return(ApplicationForm.statuses[:submitted])
      
      expect { service.update_form(id, params) }.to raise_error(RuntimeError)
    end

    it "updates the application form with the given parameters if id and params are valid" do
      params = { status: ApplicationForm.statuses[:in_progress] }
      id = rand(1..1000)
      
      allow(repository).to receive(:find_fields)
        .with(id, ['status'])
        .and_return(ApplicationForm.statuses[:in_progress])
      expect(repository).to receive(:update).with(id, params)
      
      service.update_form(id, params)

      # then fetch from db

      # then make sure fetched model has correctly-updated data
    end

    [nil, false, ''].each do |id|
      it "raises an error if the given id is falsy for submit_form (#{id.inspect})" do
        expect { service.submit_form(id) }.to raise_error(ArgumentError)
      end
    end

    [
      { status: ApplicationForm.statuses[:in_progress] },
      {},
      { status: ApplicationForm.statuses[:submitted] },
      { status: nil }
    ].each do |params|
      it "always updates status to submitted regardless of the given params (#{params.inspect})" do
        id = rand(1..1000)
        
        allow(repository).to receive(:find_fields)
          .with(id, ['status'])
          .and_return(ApplicationForm.statuses[:in_progress])
        expect(repository).to receive(:update)
          .with(id, { status: ApplicationForm.statuses[:submitted] })
        
        service.submit_form(id, params: params)
      end
    end
  end
end
